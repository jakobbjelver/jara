import 'package:uuid/uuid.dart';

import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/repositories/run_repository.dart';

/// Starts a new run.
class StartRun {
  final RunRepository _repository;

  const StartRun(this._repository);

  /// Creates a new [Run] with [startTime] set to now and saves it.
  Future<Run> call() async {
    final now = DateTime.now();
    final run = Run(
      id: const Uuid().v4(),
      startTime: now,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.saveRun(run);
    return run;
  }
}
