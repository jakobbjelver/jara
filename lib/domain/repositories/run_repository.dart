import '../entities/run.dart';

/// Abstract repository interface for run data operations.
///
/// Defined in the domain layer. Implemented in the data layer.
abstract class RunRepository {
  /// Persists a run to storage.
  Future<void> saveRun(Run run);

  /// Retrieves a single run by ID.
  Future<Run?> getRun(String id);

  /// Returns paginated run history, newest first.
  Future<List<Run>> getRunHistory({int limit = 50, int offset = 0});

  /// Searches runs by text in notes or date range.
  Future<List<Run>> searchRuns(String query);

  /// Reactively watches all runs, newest first.
  Stream<List<Run>> watchRunHistory();

  /// Deletes a run permanently.
  Future<void> deleteRun(String id);

  /// Returns the total number of runs stored.
  Future<int> getRunCount();
}
