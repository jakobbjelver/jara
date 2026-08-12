import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/runs_table.dart';

part 'runs_dao.g.dart';

@DriftAccessor(tables: [Runs])
class RunsDao extends DatabaseAccessor<AppDatabase> with _$RunsDaoMixin {
  RunsDao(super.db);

  /// Returns all runs ordered by start time descending.
  Future<List<RunData>> getAllRuns({int limit = 50, int offset = 0}) {
    return (select(runs)
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Returns a single run by ID.
  Future<RunData?> getRunById(String id) {
    return (select(runs)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a new run.
  Future<void> insertRun(Insertable<RunData> run) {
    return into(runs).insert(run);
  }

  /// Updates an existing run.
  Future<bool> updateRun(Insertable<RunData> run) {
    return update(runs).replace(run);
  }

  /// Deletes a run by ID.
  Future<int> deleteRun(String id) {
    return (delete(runs)..where((r) => r.id.equals(id))).go();
  }

  /// Searches runs by text query (matches notes field).
  Future<List<RunData>> searchRuns(String query) {
    return (select(runs)
          ..where((r) => r.notes.like('%$query%'))
          ..orderBy([(r) => OrderingTerm.desc(r.startTime)]))
        .get();
  }

  /// Reactively watches all runs.
  Stream<List<RunData>> watchAllRuns() {
    return (select(
      runs,
    )..orderBy([(r) => OrderingTerm.desc(r.startTime)])).watch();
  }

  /// Returns the total number of runs.
  Future<int> getRunCount() {
    return runs.count().getSingle();
  }
}
