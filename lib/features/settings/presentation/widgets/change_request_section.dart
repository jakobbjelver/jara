import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/features/settings/domain/change_request_model.dart';
import 'package:jara/features/settings/domain/change_request_service.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// Change request section — Report Bug and Request Feature buttons.
///
/// Each button opens a bottom sheet with a form:
/// - type (bug/feature)
/// - title
/// - description
/// - optional screenshot
///
/// Submits via [ChangeRequestService] and shows a success/error SnackBar.
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
        ],
      ),
    );
  }

  void _openSheet(
    BuildContext context,
    dynamic repo, // SettingsRepository
    String initialType,
  ) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var type = initialType;

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

          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
            ),
            child: Form(
              key: formKey,
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
                    type == 'bug' ? 'Report a Bug' : 'Request a Feature',
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
                      hintText: 'Steps to reproduce, expected behavior, etc.',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Description required';
                      }
                      if (v.trim().length < 10) return 'At least 10 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Submit button ──
                  FilledButton.icon(
                    onPressed: () => _submit(
                      ctx,
                      context,
                      type,
                      titleController.text.trim(),
                      descriptionController.text.trim(),
                      repo,
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                  ),
                ],
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
    dynamic repo, // SettingsRepository
  ) async {
    final service = const ChangeRequestService();

    // Get device token (or generate one)
    String? deviceToken = await repo.getDeviceToken();
    if (deviceToken == null) {
      deviceToken = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
      await repo.setDeviceToken(deviceToken);
    }

    final request = ChangeRequest(
      deviceToken: deviceToken,
      type: type,
      title: title,
      description: description,
      appVersion: '1.0.0',
      osVersion: Platform.operatingSystemVersion,
      deviceModel: 'unknown',
      screenSize: 'unknown',
      locale: Platform.localeName,
    );

    final result = await service.submit(request);

    if (sheetCtx.mounted) Navigator.of(sheetCtx).pop();

    if (screenCtx.mounted) {
      final messenger = ScaffoldMessenger.of(screenCtx);
      if (result.isSuccess) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              type == 'bug'
                  ? 'Bug report submitted. Thank you!'
                  : 'Feature request submitted. Thank you!',
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
}
