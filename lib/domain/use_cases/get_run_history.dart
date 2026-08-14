import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/repositories/run_repository.dart';

/// Retrieves paginated run history.
class GetRunHistory {
  final RunRepository _repository;

  const GetRunHistory(this._repository);

  Future<List<Run>> call({
    int limit = 50,
    int offset = 0,
    String? query,
  }) async {
    if (query != null && query.isNotEmpty) {
      return _repository.searchRuns(query);
    }
    return _repository.getRunHistory(limit: limit, offset: offset);
  }
}
