import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:jara/core/constants/app_constants.dart';

/// About section — app version, license, and repository link.
///
/// Grayscale-at-rest: no accent color at rest.
/// Version is hardcoded to match pubspec.yaml (1.0.0+1).
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  static const _appVersion = '1.0.0';
  static const _repoUrl = 'https://github.com/jakobbjelver/jara';
  static const _licenseUrl = 'https://www.gnu.org/licenses/gpl-3.0.html';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Container(
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

  void _openUrl(BuildContext context, String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
