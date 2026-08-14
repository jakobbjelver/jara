import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/entities/lap.dart';
import 'package:jara/domain/repositories/run_repository.dart';

/// Adds a manual lap marker to a run.
class AddLap {
  final RunRepository _repository;

  const AddLap(this._repository);

  Future<Run> call({
    required Run run,
    required double distanceAtLap,
    required double paceAtLap,
  }) async {
    final now = DateTime.now();
    final lapSeconds = now.difference(run.startTime).inSeconds;

    final lap = Lap(
      number: run.laps.length + 1,
      distanceMeters: distanceAtLap,
      durationSeconds: lapSeconds,
      paceSecondsPerKm: paceAtLap,
    );

    final updated = run.copyWith(laps: [...run.laps, lap], updatedAt: now);

    await _repository.saveRun(updated);
    return updated;
  }
}
