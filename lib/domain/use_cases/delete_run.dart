import 'package:jara/domain/repositories/run_repository.dart';

/// Deletes a run by ID.
class DeleteRun {
  final RunRepository _repository;

  const DeleteRun(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteRun(id);
  }
}
