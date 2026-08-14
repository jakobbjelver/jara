import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// About section — app version, license, and repository link.
///
/// Grayscale-at-rest: no accent color at rest.
/// Version is hardcoded to match pubspec.yaml (1.0.0+1).
///
/// Hidden Developer section (SELF-IMPROVEMENT.md §4): tapping the version
/// chip 7 times opens a dialog to enter the human maintainer token. The token
/// is stored locally and sent as the `X-Jara-Maintainer` header on Change
/// Requests — the ONLY maintainer signal. No visual hint marks the entry.
class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

  static const _appVersion = '1.0.0';
  static const _repoUrl = 'https://github.com/jakobbjelver/jara';
  static const _licenseUrl = 'https://www.gnu.org/licenses/gpl-3.0.html';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tapGate = _TapGate(
      onUnlock: () => _showDeveloperDialog(context, ref),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── App name + version ──
          Row(
            children: [
              Icon(
                Icons.directions_run,
                size: 28,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'JARA',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: tapGate.register,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'v$_appVersion',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Just Another Running App',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Privacy-first, open-source running tracker.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── License ──
          _AboutLinkTile(
            icon: Icons.description_outlined,
            label: 'GNU General Public License v3.0',
            onTap: () => _openUrl(context, _licenseUrl),
          ),
          const SizedBox(height: AppSpacing.xs),

          // ── Repository ──
          _AboutLinkTile(
            icon: Icons.code,
            label: 'Source Code',
            subtitle: 'github.com/jakobbjelver/jara',
            onTap: () => _openUrl(context, _repoUrl),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Footer ──
          Center(
            child: Text(
              'Made with ❤️ for runners',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeveloperDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final existing = await ref
        .read(settingsRepositoryProvider)
        .getMaintainerToken();
    if (existing != null) controller.text = existing;

    if (!context.mounted) return;

    final token = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Maintainer Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entered once and stored on this device. Change Requests '
              'submitted from this device are tagged as maintainer reports.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Token',
                hintText: 'Maintainer token',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (token != null && token.isNotEmpty && context.mounted) {
      await ref.read(settingsRepositoryProvider).setMaintainerToken(token);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maintainer token saved'),
            backgroundColor: Color(0xFF616161),
          ),
        );
      }
    }
  }

  void _openUrl(BuildContext context, String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

/// Counts taps within a rolling window and fires [onUnlock] at the 7th tap.
/// Resets when taps are more than 3 seconds apart.
class _TapGate {
  _TapGate({required this.onUnlock});

  static const int tapsRequired = 7;
  static const Duration window = Duration(seconds: 3);

  final VoidCallback onUnlock;
  DateTime? _firstTap;
  int _count = 0;

  void register() {
    final now = DateTime.now();
    if (_firstTap == null || now.difference(_firstTap!) > window) {
      _firstTap = now;
      _count = 0;
    }
    _count += 1;
    if (_count == tapsRequired) {
      _firstTap = null;
      _count = 0;
      onUnlock();
    }
  }
}

// ── About link tile ────────────────────────────────────

class _AboutLinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  const _AboutLinkTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label, style: theme.textTheme.bodyMedium),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.open_in_new,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
