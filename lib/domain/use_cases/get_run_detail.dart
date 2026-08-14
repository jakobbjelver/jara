import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/repositories/run_repository.dart';

/// Retrieves a single run by ID.
class GetRunDetail {
  final RunRepository _repository;

  const GetRunDetail(this._repository);

  Future<Run?> call(String id) async {
    return _repository.getRun(id);
  }
}
