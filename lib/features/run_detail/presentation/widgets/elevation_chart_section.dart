import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:jara/core/constants/app_constants.dart';
import 'package:jara/core/theme/app_colors.dart';
import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/entities/route_point.dart';
import 'package:jara/shared/widgets/section_header.dart';

/// Displays a line chart of elevation over distance.
///
/// Only shown when the run has at least 2 route points with elevation data.
class ElevationChartSection extends StatelessWidget {
  final Run run;

  const ElevationChartSection({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = _computeElevationPoints(run.routePoints);
    if (points.length < 2) return const SizedBox.shrink();

    final elevations = points.map((p) => p.y).toList();
    final minElev = elevations.reduce(min);
    final maxElev = elevations.reduce(max);
    final range = maxElev - minElev;
    final yMin = (minElev - range * 0.1).clamp(0.0, double.infinity);
    final yMax = maxElev + range * 0.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Elevation'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: _totalDistanceKm(run.routePoints),
                minY: yMin,
                maxY: yMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _niceInterval(range),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.colorScheme.outlineVariant,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: theme.colorScheme.outlineVariant),
                    bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                titlesData: _buildElevationTitles(theme),
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.warning,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.warning.withValues(alpha: 0.12),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.round()} m\n${spot.x.toStringAsFixed(2)} km',
                        TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  /// Extracts (distanceKm, elevationM) data points from route points.
  List<FlSpot> _computeElevationPoints(List<RoutePoint> points) {
    final spots = <FlSpot>[];
    double cumulativeDistance = 0;

    for (int i = 0; i < points.length; i++) {
      if (i > 0) {
        final prev = points[i - 1];
        final curr = points[i];
        cumulativeDistance += _haversineDistance(
          prev.latitude,
          prev.longitude,
          curr.latitude,
          curr.longitude,
        );
      }
      final elev = points[i].elevation;
      if (elev != null) {
        spots.add(FlSpot(cumulativeDistance / 1000, elev));
      }
    }
    return spots;
  }

  double _totalDistanceKm(List<RoutePoint> points) {
    double dist = 0;
    for (int i = 1; i < points.length; i++) {
      dist += _haversineDistance(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
    }
    return dist / 1000;
  }

  /// Haversine distance in meters between two lat/lng coordinates.
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _degToRad(double deg) => deg * pi / 180;

  /// Computes a nice axis interval for ~5 grid lines.
  static double _niceInterval(double range) {
    if (range <= 0) return 10;
    final raw = range / 5;
    final magnitude = pow(10, (log(raw) / ln10).floor()).toDouble();
    final residual = raw / magnitude;
    late double nice;
    if (residual <= 1.5) {
      nice = magnitude;
    } else if (residual <= 3.5) {
      nice = 2 * magnitude;
    } else if (residual <= 7.5) {
      nice = 5 * magnitude;
    } else {
      nice = 10 * magnitude;
    }
    return nice;
  }

  FlTitlesData _buildElevationTitles(ThemeData theme) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameWidget: Text(
          'm',
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          getTitlesWidget: (value, meta) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              value.round().toString(),
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        axisNameWidget: Text(
          'km',
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: _bottomInterval(_totalDistanceKm(run.routePoints)),
          getTitlesWidget: (value, meta) => Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  static double _bottomInterval(double totalKm) {
    if (totalKm <= 1) return 0.2;
    if (totalKm <= 5) return 0.5;
    if (totalKm <= 10) return 1;
    if (totalKm <= 42) return 5;
    return 10;
  }
}
