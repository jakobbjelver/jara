import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/repositories/run_repository.dart';

/// Pauses a running run (records interim distance/pace).
class PauseRun {
  final RunRepository _repository;

  const PauseRun(this._repository);

  /// Updates the run's progress at pause time.
  Future<Run> call(
    Run run,
    double distanceMeters,
    double paceSecondsPerKm,
  ) async {
    final now = DateTime.now();
    final durationSeconds = now.difference(run.startTime).inSeconds;

    final updated = run.copyWith(
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      avgPaceSecondsPerKm: paceSecondsPerKm,
      updatedAt: now,
    );

    await _repository.saveRun(updated);
    return updated;
  }
}
