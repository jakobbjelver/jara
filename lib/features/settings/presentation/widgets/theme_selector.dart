import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// Theme selector tile — shows current theme and cycles on tap.
///
/// Grayscale-at-rest: the leading icon uses onSurfaceVariant.
/// The trailing chevron hints at the cycling interaction.
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeProvider);

    return ListTile(
      leading: Icon(
        currentTheme.isDark
            ? Icons.dark_mode_outlined
            : Icons.light_mode_outlined,
        color: theme.colorScheme.onSurfaceVariant,
        size: 22,
      ),
      title: Text('Theme', style: theme.textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currentTheme.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.chevron_right,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: () {
        ref.read(themeProvider.notifier).cycleTheme();
      },
    );
  }
}
