import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/features/analytics/presentation/providers/analytics_provider.dart';

/// Bar chart showing weekly mileage over the last 12 weeks.
///
/// Grayscale bars with the accent color highlighting the current week.
class WeeklyMileageChart extends StatelessWidget {
  final List<WeeklyMileage> data;
  final Color accentColor;
  final bool isDark;

  const WeeklyMileageChart({
    super.key,
    required this.data,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _EmptyChart(
        message:
            'No mileage data yet.\nStart running to see your weekly progress.',
      );
    }

    final textColor = isDark ? AppColors.gray300 : AppColors.gray600;
    final gridColor = isDark ? AppColors.gray800 : AppColors.gray200;

    // Find the current week's index (the week containing today)
    final now = DateTime.now();
    final currentWeekStart = DateTime(
      now.year,
      now.month,
      now.day - now.weekday + 1,
    );
    int currentWeekIndex = -1;
    double maxKm = 0;
    for (int i = 0; i < data.length; i++) {
      if (data[i].distanceKm > maxKm) maxKm = data[i].distanceKm;
      if (data[i].weekStart.year == currentWeekStart.year &&
          data[i].weekStart.month == currentWeekStart.month &&
          data[i].weekStart.day == currentWeekStart.day) {
        currentWeekIndex = i;
      }
    }
    // Ensure there's always room for the label bar
    maxKm = maxKm < 1 ? 1 : maxKm * 1.15;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxKm,
          barGroups: List.generate(data.length, (i) {
            final isCurrentWeek = i == currentWeekIndex;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].distanceKm,
                  color: isCurrentWeek ? accentColor : AppColors.gray400,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxKm,
                    color: gridColor,
                  ),
                ),
              ],
            );
          }),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              tooltipRoundedRadius: 8,
              getTooltipColor: (group) =>
                  isDark ? AppColors.gray700 : AppColors.gray800,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final week = data[group.x];
                final dateStr = '${week.weekStart.month}/${week.weekStart.day}';
                return BarTooltipItem(
                  '$dateStr\n${week.distanceKm.toStringAsFixed(1)} km',
                  TextStyle(
                    color: isDark ? AppColors.gray100 : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                );
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
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  if (idx % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  final week = data[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '${week.weekStart.month}/${week.weekStart.day}',
                      style: TextStyle(fontSize: 10, color: textColor),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(fontSize: 10, color: textColor),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxKm <= 5 ? 1 : maxKm / 5,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: gridColor, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

/// Placeholder shown when there's no weekly mileage data.
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
