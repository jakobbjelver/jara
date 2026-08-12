import 'package:jara/domain/entities/run.dart';

/// Represents a single week's mileage for charting.
class WeeklyMileage {
  final DateTime weekStart;
  final double distanceKm;

  const WeeklyMileage({required this.weekStart, required this.distanceKm});
}

/// A pace data point for trend charts.
class PaceTrendPoint {
  final DateTime date;
  final double paceSecondsPerKm;

  const PaceTrendPoint({required this.date, required this.paceSecondsPerKm});
}

/// Aggregated analytics data computed from a list of [Run] entities.
class RunAnalytics {
  final double totalDistanceKm;
  final Duration totalDuration;
  final double avgPaceSecondsPerKm;
  final int totalRuns;
  final List<WeeklyMileage> weeklyMileage;
  final List<PaceTrendPoint> paceTrend;

  const RunAnalytics({
    required this.totalDistanceKm,
    required this.totalDuration,
    required this.avgPaceSecondsPerKm,
    required this.totalRuns,
    required this.weeklyMileage,
    required this.paceTrend,
  });

  static const empty = RunAnalytics(
    totalDistanceKm: 0,
    totalDuration: Duration.zero,
    avgPaceSecondsPerKm: 0,
    totalRuns: 0,
    weeklyMileage: [],
    paceTrend: [],
  );
}

/// Pure functions for computing analytics from a list of [Run] entities.
///
/// All methods are stateless and testable in isolation — no dependencies
/// on Riverpod, repositories, or UI code.
class AnalyticsCalculator {
  const AnalyticsCalculator._();

  /// Compute full analytics for the given [runs].
  ///
  /// Returns [RunAnalytics.empty] if the list is empty.
  static RunAnalytics compute(List<Run> runs) {
    if (runs.isEmpty) return RunAnalytics.empty;

    return RunAnalytics(
      totalDistanceKm: _totalDistanceKm(runs),
      totalDuration: _totalDuration(runs),
      avgPaceSecondsPerKm: _avgPace(runs),
      totalRuns: runs.length,
      weeklyMileage: _weeklyMileage(runs),
      paceTrend: _paceTrend(runs),
    );
  }

  /// Total distance across all runs (km).
  static double _totalDistanceKm(List<Run> runs) {
    return runs.fold<double>(
      0,
      (sum, r) => sum + (r.distanceMeters ?? 0) / 1000,
    );
  }

  /// Total running duration.
  static Duration _totalDuration(List<Run> runs) {
    final seconds = runs.fold<int>(
      0,
      (sum, r) => sum + (r.durationSeconds ?? 0),
    );
    return Duration(seconds: seconds);
  }

  /// Average pace in seconds per km across runs that have pace data.
  static double _avgPace(List<Run> runs) {
    final paces = runs
        .where(
          (r) => r.avgPaceSecondsPerKm != null && r.avgPaceSecondsPerKm! > 0,
        )
        .map((r) => r.avgPaceSecondsPerKm!)
        .toList();

    if (paces.isEmpty) return 0;

    return paces.reduce((a, b) => a + b) / paces.length;
  }

  /// Weekly mileage breakdown for the last 12 weeks.
  static List<WeeklyMileage> _weeklyMileage(List<Run> runs) {
    final weekly = <WeeklyMileage>[];
    final now = DateTime.now();

    for (int i = 11; i >= 0; i--) {
      final weekStart = DateTime(
        now.year,
        now.month,
        now.day - now.weekday + 1 - (i * 7),
      );
      final weekEnd = weekStart.add(const Duration(days: 7));

      final km = runs
          .where(
            (r) =>
                r.startTime.isAfter(weekStart) && r.startTime.isBefore(weekEnd),
          )
          .fold<double>(0, (sum, r) => sum + (r.distanceMeters ?? 0) / 1000);

      weekly.add(WeeklyMileage(weekStart: weekStart, distanceKm: km));
    }

    return weekly;
  }

  /// Pace trend over time, sorted by date ascending.
  static List<PaceTrendPoint> _paceTrend(List<Run> runs) {
    final trend =
        runs
            .where(
              (r) =>
                  r.avgPaceSecondsPerKm != null && r.avgPaceSecondsPerKm! > 0,
            )
            .map(
              (r) => PaceTrendPoint(
                date: r.startTime,
                paceSecondsPerKm: r.avgPaceSecondsPerKm!,
              ),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return trend;
  }
}

// ── Convenience top-level functions for quick access ──────────────────

/// Compute total distance in km across [runs].
double totalDistanceKm(List<Run> runs) =>
    runs.fold(0.0, (sum, r) => sum + (r.distanceMeters ?? 0) / 1000);

/// Compute total duration as [Duration] across [runs].
Duration totalDuration(List<Run> runs) {
  final seconds = runs.fold(0, (sum, r) => sum + (r.durationSeconds ?? 0));
  return Duration(seconds: seconds);
}

/// Average pace in seconds per km across [runs] that have pace data.
/// Returns 0 if no runs have pace data.
double averagePace(List<Run> runs) {
  final paces = runs
      .where((r) => r.avgPaceSecondsPerKm != null && r.avgPaceSecondsPerKm! > 0)
      .map((r) => r.avgPaceSecondsPerKm!)
      .toList();
  if (paces.isEmpty) return 0;
  return paces.reduce((a, b) => a + b) / paces.length;
}

/// Best (fastest) pace in seconds per km among [runs].
/// Returns double.infinity if no runs have pace data.
double bestPace(List<Run> runs) {
  final paces = runs
      .where((r) => r.avgPaceSecondsPerKm != null && r.avgPaceSecondsPerKm! > 0)
      .map((r) => r.avgPaceSecondsPerKm!)
      .toList();
  if (paces.isEmpty) return double.infinity;
  return paces.reduce((a, b) => a < b ? a : b);
}

/// Total elevation gain in meters across [runs].
double totalElevationGain(List<Run> runs) =>
    runs.fold(0.0, (sum, r) => sum + (r.elevationGainMeters ?? 0));
