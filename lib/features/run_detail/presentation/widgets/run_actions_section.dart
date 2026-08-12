import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/use_cases/export_run.dart';
import 'package:jara/features/run_detail/presentation/providers/run_detail_provider.dart';
import 'package:jara/shared/widgets/section_header.dart';

/// Export and delete actions for a completed run.
///
/// Provides GPX, TCX, and CSV export buttons plus a destructive
/// delete action in red.
class RunActionsSection extends ConsumerWidget {
  final Run run;

  const RunActionsSection({super.key, required this.run});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Actions'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ExportButton(
                label: 'Export GPX',
                icon: Icons.map_outlined,
                format: ExportFormat.gpx,
                run: run,
              ),
              _ExportButton(
                label: 'Export TCX',
                icon: Icons.fitness_center_outlined,
                format: ExportFormat.tcx,
                run: run,
              ),
              _ExportButton(
                label: 'Export CSV',
                icon: Icons.table_chart_outlined,
                format: ExportFormat.csv,
                run: run,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            label: const Text(
              'Delete Run',
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              foregroundColor: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Run'),
        content: Text(
          'Permanently delete this ${run.formattedDistance} run '
          'from ${run.formattedDate}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _performDelete(context, ref);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(BuildContext context, WidgetRef ref) async {
    try {
      final deleteRun = ref.read(deleteRunForDetailProvider);
      await deleteRun(run.id);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Run deleted.')));
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }
}

/// Single export button that triggers [ExportRun] and opens the file picker.
class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final ExportFormat format;
  final Run run;

  const _ExportButton({
    required this.label,
    required this.icon,
    required this.format,
    required this.run,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _export(context),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Future<void> _export(BuildContext context) async {
    try {
      final exportRun = const ExportRun();
      final path = await exportRun(run, format);
      if (path != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Exported $label to $path')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }
}
