import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/entities/route_point.dart';
import 'package:jara/domain/entities/lap.dart';
import 'package:jara/domain/repositories/run_repository.dart';

/// Stops a run and saves final data.
class StopRun {
  final RunRepository _repository;

  const StopRun(this._repository);

  Future<Run> call({
    required Run run,
    required double distanceMeters,
    required double avgPaceSecondsPerKm,
    required List<RoutePoint> routePoints,
    required List<Lap> laps,
  }) async {
    final now = DateTime.now();
    final durationSeconds = now.difference(run.startTime).inSeconds;

    final completed = run.copyWith(
      endTime: now,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      avgPaceSecondsPerKm: avgPaceSecondsPerKm,
      routePoints: routePoints,
      laps: laps,
      updatedAt: now,
    );

    await _repository.saveRun(completed);
    return completed;
  }
}
