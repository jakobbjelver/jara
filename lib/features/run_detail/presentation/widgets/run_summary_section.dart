import 'package:flutter/material.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/core/theme/app_text_styles.dart';
import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/entities/lap.dart';
import 'package:jara/shared/widgets/section_header.dart';

/// Displays distance, duration, avg pace, and an optional lap/splits table.
class RunSummarySection extends StatelessWidget {
  final Run run;

  const RunSummarySection({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Summary'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _SummaryRow(
            children: [
              _SummaryTile(
                icon: Icons.straighten,
                label: 'Distance',
                value: run.formattedDistance,
              ),
              _SummaryTile(
                icon: Icons.timer_outlined,
                label: 'Duration',
                value: run.formattedDuration,
              ),
              _SummaryTile(
                icon: Icons.speed,
                label: 'Avg Pace',
                value: run.formattedPace,
              ),
            ],
          ),
        ),
        if (run.elevationGainMeters != null ||
            run.elevationLossMeters != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _SummaryRow(
              children: [
                if (run.elevationGainMeters != null)
                  _SummaryTile(
                    icon: Icons.trending_up,
                    label: 'Gain',
                    value: '${run.elevationGainMeters!.round()} m',
                  ),
                if (run.elevationLossMeters != null)
                  _SummaryTile(
                    icon: Icons.trending_down,
                    label: 'Loss',
                    value: '${run.elevationLossMeters!.round()} m',
                  ),
                if (run.avgHeartRate != null)
                  _SummaryTile(
                    icon: Icons.favorite_border,
                    label: 'Avg HR',
                    value: '${run.avgHeartRate} bpm',
                  ),
              ],
            ),
          ),
        ],
        if (run.laps.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Splits'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _LapsTable(laps: run.laps),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

/// Three-column row for summary stat tiles.
class _SummaryRow extends StatelessWidget {
  final List<Widget> children;

  const _SummaryRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children.map((child) => Expanded(child: child)).toList(),
    );
  }
}

/// Single stat tile: icon, label, value.
class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppTextStyles.runStatSecondary(context)),
        Text(label, style: AppTextStyles.caption(context)),
      ],
    );
  }
}

/// Lap / split table with number, distance, duration, and pace.
class _LapsTable extends StatelessWidget {
  final List<Lap> laps;

  const _LapsTable({required this.laps});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(0.5),
            1: FlexColumnWidth(1.0),
            2: FlexColumnWidth(1.0),
            3: FlexColumnWidth(1.0),
          },
          children: [
            _TableHeaderRow(
              labels: const ['#', 'Distance', 'Time', 'Pace'],
              style: AppTextStyles.caption(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            ...laps.map((lap) {
              final paceMin = (lap.paceSecondsPerKm / 60).floor();
              final paceSec = (lap.paceSecondsPerKm % 60).round();
              final durMin = (lap.durationSeconds / 60).floor();
              final durSec = lap.durationSeconds % 60;
              final distKm = lap.distanceMeters >= 1000
                  ? '${(lap.distanceMeters / 1000).toStringAsFixed(1)} km'
                  : '${lap.distanceMeters.round()} m';

              return _TableDataRow(
                cells: [
                  '${lap.number}',
                  distKm,
                  '${durMin.toString().padLeft(2, '0')}:${durSec.toString().padLeft(2, '0')}',
                  '${paceMin.toString().padLeft(2, '0')}:${paceSec.toString().padLeft(2, '0')} /km',
                ],
                style: AppTextStyles.bodySmall(context),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TableHeaderRow extends TableRow {
  _TableHeaderRow({required List<String> labels, required TextStyle style})
    : super(
        children: labels
            .map(
              (label) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(label, style: style),
              ),
            )
            .toList(),
      );
}

class _TableDataRow extends TableRow {
  _TableDataRow({required List<String> cells, required TextStyle style})
    : super(
        children: cells
            .map(
              (cell) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(cell, style: style),
              ),
            )
            .toList(),
      );
}
