import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/repositories/run_repository.dart';

/// Resumes a paused run.
class ResumeRun {
  final RunRepository _repository;

  const ResumeRun(this._repository);

  Future<void> call(Run run) async {
    final updated = run.copyWith(updatedAt: DateTime.now());
    await _repository.saveRun(updated);
  }
}
