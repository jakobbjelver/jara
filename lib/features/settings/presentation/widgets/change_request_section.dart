import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/core/utils/log_ring_buffer.dart';
import 'package:jara/domain/repositories/settings_repository.dart';
import 'package:jara/features/settings/domain/change_request_model.dart';
import 'package:jara/features/settings/domain/change_request_service.dart';
import 'package:jara/features/settings/domain/maintainer_token_resolver.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';
import 'package:jara/features/settings/presentation/screens/my_reports_screen.dart';

/// Screenshot size cap — mirrors the worker's 5 MB limit (ADR-009).
const int _kMaxScreenshotBytes = 5 * 1024 * 1024;

/// Change request section — Report Bug and Request Feature buttons, a
/// "My Reports" status entry, and a screenshot attachment in the form.
///
/// Each button opens a bottom sheet with a form:
/// - type (bug/feature)
/// - title
/// - description
/// - steps to reproduce + expected vs actual (PLAN-002 §1.9)
/// - opt-in diagnostic logs for bug reports (ring buffer, consent toggle,
///   default on — attached automatically in debug builds)
/// - optional screenshot (file_picker → worker R2 upload → screenshot_url)
///
/// Submits via [ChangeRequestService] with the maintainer token header
/// resolved by [MaintainerTokenResolver], and shows a receipt
/// ("Report #`<id>` submitted") on success.
class ChangeRequestSection extends ConsumerWidget {
  const ChangeRequestSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(settingsRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => _openSheet(context, repo, 'bug'),
            icon: const Icon(Icons.bug_report_outlined, size: 18),
            label: const Text('Report Bug'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _openSheet(context, repo, 'feature'),
            icon: const Icon(Icons.lightbulb_outlined, size: 18),
            label: const Text('Request Feature'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MyReportsScreen(),
              ),
            ),
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: const Text('My Reports'),
          ),
        ],
      ),
    );
  }

  void _openSheet(
    BuildContext context,
    SettingsRepository repo,
    String initialType,
  ) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final stepsController = TextEditingController();
    final expectedController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var type = initialType;
    var includeLogs = true;
    // Screenshot attachment state (ADR-009): picked bytes + content type.
    Uint8List? screenshotBytes;
    String? screenshotContentType;
    String? screenshotName;
    var uploadingScreenshot = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          final isBug = type == 'bug';

          Future<void> pickScreenshot() async {
            // Capture the messenger BEFORE the await — contexts must not
            // cross async gaps.
            final messenger = ScaffoldMessenger.of(ctx);
            final result = await FilePicker.platform.pickFiles(
              type: FileType.image,
              withData: true,
            );
            if (result == null || result.files.isEmpty) return;
            final file = result.files.single;
            final bytes = file.bytes;
            if (bytes == null) return;

            if (bytes.length > _kMaxScreenshotBytes) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Image too large (max 5 MB)'),
                  backgroundColor: AppColors.warning,
                ),
              );
              return;
            }

            // Only png/jpeg/webp — the worker's allowlist (ADR-009).
            final ext = file.extension?.toLowerCase() ?? '';
            final contentType = switch (ext) {
              'png' => 'image/png',
              'jpg' || 'jpeg' => 'image/jpeg',
              'webp' => 'image/webp',
              _ => null,
            };
            if (contentType == null) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Unsupported image type (PNG, JPG, or WEBP)'),
                  backgroundColor: AppColors.warning,
                ),
              );
              return;
            }

            setSheetState(() {
              screenshotBytes = bytes;
              screenshotContentType = contentType;
              screenshotName = file.name;
            });
          }

          void clearScreenshot() {
            setSheetState(() {
              screenshotBytes = null;
              screenshotContentType = null;
              screenshotName = null;
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Handle bar ──
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Title ──
                    Text(
                      isBug ? 'Report a Bug' : 'Request a Feature',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Help us improve JARA. Your report is anonymous.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Type toggle ──
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'bug',
                          label: Text('Bug'),
                          icon: Icon(Icons.bug_report_outlined),
                        ),
                        ButtonSegment(
                          value: 'feature',
                          label: Text('Feature'),
                          icon: Icon(Icons.lightbulb_outlined),
                        ),
                      ],
                      selected: {type},
                      onSelectionChanged: (sel) {
                        setSheetState(() => type = sel.first);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Title field ──
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Brief summary of the issue or idea',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Title required';
                        }
                        if (v.trim().length < 5) {
                          return 'At least 5 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Description field ──
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'What happened, or what should exist?',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Description required';
                        }
                        if (v.trim().length < 10) {
                          return 'At least 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Steps to reproduce ──
                    TextFormField(
                      controller: stepsController,
                      decoration: const InputDecoration(
                        labelText: 'Steps to Reproduce',
                        hintText: '1. …\n2. …\n(optional, helps a lot)',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Expected vs actual ──
                    TextFormField(
                      controller: expectedController,
                      decoration: const InputDecoration(
                        labelText: 'Expected vs Actual',
                        hintText:
                            'What you expected, and what happened instead '
                            '(optional)',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Diagnostic logs consent ──
                    // Bug reports only. Debug builds attach logs automatically
                    // (maintainer-route advantage) and show no toggle.
                    if (isBug && !kDebugMode) ...[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Include diagnostic logs'),
                        subtitle: const Text(
                          'Attaches the last ~200 app log lines. Contains '
                          'no personal data — only app diagnostics.',
                        ),
                        value: includeLogs,
                        onChanged: (v) => setSheetState(() => includeLogs = v),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],

                    // ── Screenshot attachment (ADR-009) ──
                    if (screenshotBytes == null)
                      OutlinedButton.icon(
                        onPressed: uploadingScreenshot
                            ? null
                            : () async {
                                setSheetState(
                                  () => uploadingScreenshot = true,
                                );
                                await pickScreenshot();
                                setSheetState(
                                  () => uploadingScreenshot = false,
                                );
                              },
                        icon: const Icon(Icons.add_photo_alternate_outlined,
                            size: 18),
                        label: const Text('Attach Screenshot (optional)'),
                      )
                    else ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.memory(
                                screenshotBytes!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                screenshotName ?? 'Screenshot attached',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'Remove screenshot',
                              onPressed: clearScreenshot,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],

                    const SizedBox(height: AppSpacing.sm),

                    // ── Submit button ──
                    FilledButton.icon(
                      onPressed: () => _submit(
                        ctx,
                        context,
                        type,
                        titleController.text.trim(),
                        descriptionController.text.trim(),
                        stepsController.text.trim(),
                        expectedController.text.trim(),
                        includeLogs: isBug && (kDebugMode || includeLogs),
                        repo: repo,
                        screenshotBytes: screenshotBytes,
                        screenshotContentType: screenshotContentType,
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit(
    BuildContext sheetCtx,
    BuildContext screenCtx,
    String type,
    String title,
    String description,
    String steps,
    String expected, {
    required bool includeLogs,
    required SettingsRepository repo,
    Uint8List? screenshotBytes,
    String? screenshotContentType,
  }) async {
    final service = const ChangeRequestService();
    final resolver = const MaintainerTokenResolver();

    // Capture screen size before any awaits (context must not cross gaps).
    final screenSize = MediaQuery.sizeOf(screenCtx);

    // Get device token (UUID, generated on first submit — plan §8.1)
    String? deviceToken = await repo.getDeviceToken();
    if (deviceToken == null) {
      deviceToken = const Uuid().v4();
      await repo.setDeviceToken(deviceToken);
    }

    // Optional screenshot: upload first (ADR-009), then reference the URL
    // in the CR. A failed upload degrades to a text-only report.
    String? screenshotUrl;
    if (screenshotBytes != null && screenshotContentType != null) {
      screenshotUrl = await service.uploadScreenshot(
        bytes: screenshotBytes,
        contentType: screenshotContentType,
        deviceToken: deviceToken,
      );
      if (screenshotUrl == null && screenCtx.mounted) {
        ScaffoldMessenger.of(screenCtx).showSnackBar(
          const SnackBar(
            content: Text('Screenshot upload failed — submitting without it'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }

    // Maintainer token — the ONLY maintainer signal (SELF-IMPROVEMENT.md §4).
    final maintainerToken = await resolver.resolve(repo);

    // Collect device info automatically (plan §8.1)
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    String deviceModel = 'unknown';
    try {
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceModel = '${android.manufacturer} ${android.model}';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceModel = ios.utsname.machine;
      } else {
        deviceModel = Platform.operatingSystem;
      }
    } catch (_) {
      // Device info is best-effort — never block a submission on it.
    }

    final request = ChangeRequest(
      deviceToken: deviceToken,
      type: type,
      title: title,
      description: description,
      stepsToReproduce: steps.isEmpty ? null : steps,
      expectedActual: expected.isEmpty ? null : expected,
      logs: includeLogs ? _boundedLogDump() : null,
      appVersion: packageInfo.version,
      osVersion: Platform.operatingSystemVersion,
      deviceModel: deviceModel,
      screenSize: '${screenSize.width.round()}x${screenSize.height.round()}',
      locale: Platform.localeName,
      screenshotUrl: screenshotUrl,
    );

    final result = await service.submit(
      request,
      maintainerToken: maintainerToken,
    );

    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();

    if (screenCtx.mounted) {
      final messenger = ScaffoldMessenger.of(screenCtx);
      if (result.isSuccess) {
        final id = result.id;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              result.isDuplicate
                  ? 'Already reported as #$id'
                  : 'Report #$id submitted',
            ),
            backgroundColor: Colors.grey.shade800,
          ),
        );
      } else if (result.error != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed: ${result.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Rate limited. Please try again later.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  /// Ring buffer dump, capped under the worker's `logs` field cap (30 KB).
  String _boundedLogDump() {
    final dump = LogRingBuffer.instance.dump();
    return dump.length > 25000 ? dump.substring(0, 25000) : dump;
  }
}
