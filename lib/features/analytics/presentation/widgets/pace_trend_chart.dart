import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/features/analytics/presentation/providers/analytics_provider.dart';

/// Line chart showing pace trend over time.
///
/// Lower pace (seconds/km) = faster, so the y-axis is inverted
/// visually: lower values appear higher on the chart.
class PaceTrendChart extends StatelessWidget {
  final List<PaceTrendPoint> data;
  final double averagePaceSecondsPerKm;
  final Color accentColor;
  final bool isDark;

  const PaceTrendChart({
    super.key,
    required this.data,
    required this.averagePaceSecondsPerKm,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _EmptyChart(
        message: 'No pace data yet.\nComplete runs to see your pace trend.',
      );
    }

    final textColor = isDark ? AppColors.gray300 : AppColors.gray600;
    final gridColor = isDark ? AppColors.gray800 : AppColors.gray200;

    // Find pace range. We invert the Y axis so "faster" (lower pace) is higher.
    final paces = data.map((p) => p.paceSecondsPerKm).toList();
    final minPace = paces.reduce((a, b) => a < b ? a : b);
    final maxPace = paces.reduce((a, b) => a > b ? a : b);
    // Add padding to the range so data isn't pinned to edges
    final rangePad = (maxPace - minPace) * 0.15;
    final yMin = minPace - rangePad;
    final yMax = maxPace + rangePad;

    // Build spot data — map each point to (index, pace)
    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].paceSecondsPerKm),
    );

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: yMin,
          maxY: yMax,
          lineBarsData: [
            // Average pace reference line
            LineChartBarData(
              spots: [
                FlSpot(0, averagePaceSecondsPerKm),
                FlSpot((data.length - 1).toDouble(), averagePaceSecondsPerKm),
              ],
              isCurved: false,
              color: AppColors.gray400.withValues(alpha: 0.5),
              barWidth: 1,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              dashArray: [6, 4],
              belowBarData: BarAreaData(show: false),
            ),
            // Pace trend line
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: accentColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: data.length <= 15,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 3,
                      color: accentColor,
                      strokeWidth: 0,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: accentColor.withValues(alpha: 0.08),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              tooltipRoundedRadius: 8,
              getTooltipColor: (spot) =>
                  isDark ? AppColors.gray700 : AppColors.gray800,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final point = data[spot.spotIndex];
                  final minutes = (point.paceSecondsPerKm / 60).floor();
                  final seconds = (point.paceSecondsPerKm % 60).round();
                  final paceStr =
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} /km';
                  final dateStr = '${point.date.month}/${point.date.day}';
                  return LineTooltipItem(
                    '$dateStr\n$paceStr',
                    TextStyle(
                      color: isDark ? AppColors.gray100 : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: _computeBottomInterval(data.length),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '${data[idx].date.month}/${data[idx].date.day}',
                      style: TextStyle(fontSize: 10, color: textColor),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value <= 0) return const SizedBox.shrink();
                  final minutes = (value / 60).floor();
                  final seconds = (value % 60).round();
                  return Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 10, color: textColor),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: gridColor, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  /// Compute a reasonable interval for bottom axis labels to avoid crowding.
  double _computeBottomInterval(int count) {
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 30) return 5;
    return (count / 7).ceilToDouble();
  }
}

/// Placeholder shown when there's no pace trend data.
class _EmptyChart extends StatelessWidget {
  final String message;
  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
