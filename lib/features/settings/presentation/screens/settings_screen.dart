import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/shared/widgets/section_header.dart';
import 'package:jara/features/settings/presentation/widgets/theme_selector.dart';
import 'package:jara/features/settings/presentation/widgets/backup_section.dart';
import 'package:jara/features/settings/presentation/widgets/export_section.dart';
import 'package:jara/features/settings/presentation/widgets/change_request_section.dart';
import 'package:jara/features/settings/presentation/widgets/about_section.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// Settings screen — grayscale-at-rest, 4px spacing.
///
/// Sections (per GOAL.md §7.5):
/// - Theme: light / dark / named themes
/// - Run Preferences: auto-pause threshold, audio cues, distance unit
/// - Data: export all runs, import, backup, restore
/// - Change Request: report bug, request feature
/// - About: version, license, repo
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoPauseAsync = ref.watch(autoPauseThresholdProvider);
    final audioCueAsync = ref.watch(audioCueIntervalProvider);
    final distanceUnitAsync = ref.watch(distanceUnitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          // ── Theme ──
          const SectionHeader(title: 'Theme'),
          const ThemeSelector(),
          const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),

          // ── Run Preferences ──
          const SectionHeader(title: 'Run Preferences'),
          _RunPrefTile(
            icon: Icons.speed,
            label: 'Auto-Pause Speed',
            value: autoPauseAsync.valueOrNull != null
                ? '${autoPauseAsync.value!.toStringAsFixed(1)} km/h'
                : '—',
            onTap: () => _showAutoPausePicker(context, ref),
          ),
          _RunPrefTile(
            icon: Icons.volume_up_outlined,
            label: 'Audio Cues',
            value: switch (audioCueAsync.valueOrNull ?? 0) {
              0 => 'Off',
              1 => 'Every 30 sec',
              2 => 'Every 1 min',
              3 => 'Every 1 km',
              4 => 'Every 5 min',
              _ => 'Off',
            },
            onTap: () => _showAudioCuePicker(context, ref),
          ),
          _RunPrefTile(
            icon: Icons.straighten_outlined,
            label: 'Distance Unit',
            value: (distanceUnitAsync.valueOrNull ?? 'km') == 'km'
                ? 'Kilometers'
                : 'Miles',
            onTap: () => _showUnitPicker(context, ref),
          ),
          const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),

          // ── Data ──
          const SectionHeader(title: 'Data'),
          const BackupSection(),
          const SizedBox(height: AppSpacing.sm),
          const ExportSection(),
          const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),

          // ── Change Request ──
          const SectionHeader(title: 'Change Request'),
          const ChangeRequestSection(),
          const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),

          // ── About ──
          const SectionHeader(title: 'About'),
          const AboutSection(),
        ],
      ),
    );
  }

  // ── Preference pickers ─────────────────────────────────

  Future<void> _showAutoPausePicker(BuildContext context, WidgetRef ref) async {
    final options = [1.0, 1.5, 2.0, 2.5, 3.0, 4.0];
    final current = ref.read(autoPauseThresholdProvider).valueOrNull ?? 2.0;

    final selected = await showModalBottomSheet<double>(
      context: context,
      builder: (context) => _OptionsSheet(
        title: 'Auto-Pause Speed',
        subtitle: 'Pause when speed drops below this for 5 seconds',
        options: options,
        current: current,
        label: (v) => '${v.toStringAsFixed(1)} km/h',
      ),
    );

    if (selected != null) {
      await ref.read(autoPauseThresholdProvider.notifier).set(selected);
    }
  }

  Future<void> _showAudioCuePicker(BuildContext context, WidgetRef ref) async {
    // 0 = off, 1 = 30s, 2 = 1min, 3 = 1km, 4 = 5min
    final options = [0, 1, 2, 3, 4];
    final current = ref.read(audioCueIntervalProvider).valueOrNull ?? 0;

    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => _OptionsSheet(
        title: 'Audio Cue Frequency',
        subtitle: 'Announce time, distance, and average pace during runs',
        options: options,
        current: current,
        label: (v) => switch (v) {
          0 => 'Off',
          1 => 'Every 30 sec',
          2 => 'Every 1 min',
          3 => 'Every 1 km',
          4 => 'Every 5 min',
          _ => 'Off',
        },
      ),
    );

    if (selected != null) {
      await ref.read(audioCueIntervalProvider.notifier).set(selected);
    }
  }

  Future<void> _showUnitPicker(BuildContext context, WidgetRef ref) async {
    final current = ref.read(distanceUnitProvider).valueOrNull ?? 'km';

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _OptionsSheet(
        title: 'Distance Unit',
        subtitle: 'Used for stats, splits, and audio cues',
        options: const ['km', 'mi'],
        current: current,
        label: (v) => v == 'km' ? 'Kilometers' : 'Miles',
      ),
    );

    if (selected != null) {
      await ref.read(distanceUnitProvider.notifier).set(selected);
    }
  }
}

/// Generic option picker bottom sheet.
class _OptionsSheet<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<T> options;
  final T current;
  final String Function(T) label;

  const _OptionsSheet({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.current,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          for (final option in options)
            ListTile(
              title: Text(label(option)),
              trailing: option == current
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(option),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ── Run preference tile ─────────────────────────────────

class _RunPrefTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _RunPrefTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 22),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
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
      onTap: onTap,
    );
  }
}
