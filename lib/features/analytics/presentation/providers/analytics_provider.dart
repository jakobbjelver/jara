import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:jara/features/settings/presentation/providers/settings_provider.dart';

/// Analytics data computed from run history.
class AnalyticsData {
  final double totalDistanceKm;
  final Duration totalDuration;
  final double avgPaceSecondsPerKm;
  final int totalRuns;
  final List<WeeklyMileage> weeklyMileage;
  final List<PaceTrendPoint> paceTrend;

  const AnalyticsData({
    required this.totalDistanceKm,
    required this.totalDuration,
    required this.avgPaceSecondsPerKm,
    required this.totalRuns,
    required this.weeklyMileage,
    required this.paceTrend,
  });

  static const empty = AnalyticsData(
    totalDistanceKm: 0,
    totalDuration: Duration.zero,
    avgPaceSecondsPerKm: 0,
    totalRuns: 0,
    weeklyMileage: [],
    paceTrend: [],
  );
}

class WeeklyMileage {
  final DateTime weekStart;
  final double distanceKm;
  const WeeklyMileage({required this.weekStart, required this.distanceKm});
}

class PaceTrendPoint {
  final DateTime date;
  final double paceSecondsPerKm;
  const PaceTrendPoint({required this.date, required this.paceSecondsPerKm});
}

final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  final db = ref.watch(databaseProvider);
  final runDatas = await db.runsDao.getAllRuns(limit: 200);

  if (runDatas.isEmpty) return AnalyticsData.empty;

  final totalKm = runDatas.fold<double>(
    0,
    (sum, r) => sum + (r.distanceMeters ?? 0) / 1000,
  );
  final totalSeconds = runDatas.fold<int>(
    0,
    (sum, r) => sum + (r.durationSeconds ?? 0),
  );

  final paces = runDatas
      .where((r) => r.avgPaceSecondsPerKm != null && r.avgPaceSecondsPerKm! > 0)
      .map((r) => r.avgPaceSecondsPerKm!)
      .toList();
  final avgPace = paces.isNotEmpty
      ? paces.reduce((a, b) => a + b) / paces.length
      : 0.0;

  // Weekly mileage — last 12 weeks
  final weekly = <WeeklyMileage>[];
  final now = DateTime.now();
  for (int i = 11; i >= 0; i--) {
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day - now.weekday + 1 - i * 7,
    );
    final weekEnd = weekStart.add(const Duration(days: 7));
    final km = runDatas
        .where(
          (r) =>
              r.startTime.isAfter(weekStart) && r.startTime.isBefore(weekEnd),
        )
        .fold<double>(0, (sum, r) => sum + (r.distanceMeters ?? 0) / 1000);
    weekly.add(WeeklyMileage(weekStart: weekStart, distanceKm: km));
  }

  // Pace trend
  final trend =
      runDatas
          .where(
            (r) => r.avgPaceSecondsPerKm != null && r.avgPaceSecondsPerKm! > 0,
          )
          .map(
            (r) => PaceTrendPoint(
              date: r.startTime,
              paceSecondsPerKm: r.avgPaceSecondsPerKm!,
            ),
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  return AnalyticsData(
    totalDistanceKm: totalKm,
    totalDuration: Duration(seconds: totalSeconds),
    avgPaceSecondsPerKm: avgPace,
    totalRuns: runDatas.length,
    weeklyMileage: weekly,
    paceTrend: trend,
  );
});
