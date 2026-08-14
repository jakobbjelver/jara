import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/domain/repositories/run_repository.dart';
import 'package:jara/domain/use_cases/export_run.dart';
import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// Export section — exports all runs in the selected format.
///
/// Offers GPX, TCX, and CSV as three OutlinedButton tiles.
/// Grayscale-at-rest: icons use onSurfaceVariant.
class ExportSection extends ConsumerWidget {
  const ExportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ExportTile(
            label: 'Export All as GPX',
            icon: Icons.map_outlined,
            format: ExportFormat.gpx,
            repository: ref.watch(runRepositoryProvider),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ExportTile(
            label: 'Export All as TCX',
            icon: Icons.fitness_center_outlined,
            format: ExportFormat.tcx,
            repository: ref.watch(runRepositoryProvider),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ExportTile(
            label: 'Export All as CSV',
            icon: Icons.table_chart_outlined,
            format: ExportFormat.csv,
            repository: ref.watch(runRepositoryProvider),
          ),
        ],
      ),
    );
  }
}

// ── Single export tile ────────────────────────────────

class _ExportTile extends ConsumerWidget {
  final String label;
  final IconData icon;
  final ExportFormat format;
  final RunRepository repository;

  const _ExportTile({
    required this.label,
    required this.icon,
    required this.format,
    required this.repository,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: () => _exportAll(context),
      icon: Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
      label: Text(label),
    );
  }

  Future<void> _exportAll(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Loading runs...'),
          duration: Duration(seconds: 1),
        ),
      );

      final runs = await repository.getRunHistory(limit: 1000);

      if (runs.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No runs to export.')),
        );
        return;
      }

      final exportRun = const ExportRun();
      final paths = await exportRun.exportAll(runs, format);

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Exported ${paths.length} of ${runs.length} runs.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }
}
