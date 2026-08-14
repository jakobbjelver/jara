import 'dart:async';

import 'package:jara/domain/entities/run.dart';
import 'package:jara/domain/repositories/run_repository.dart';
import 'package:jara/data/database/daos/runs_dao.dart';
import 'package:jara/data/mappers/run_mapper.dart';

/// Implements [RunRepository] using Drift SQLite.
class RunRepositoryImpl implements RunRepository {
  final RunsDao _dao;

  RunRepositoryImpl(this._dao);

  @override
  Future<void> saveRun(Run run) async {
    final companion = RunMapper.toCompanion(run);
    final existing = await _dao.getRunById(run.id);
    if (existing != null) {
      await _dao.updateRun(companion);
    } else {
      await _dao.insertRun(companion);
    }
  }

  @override
  Future<Run?> getRun(String id) async {
    final data = await _dao.getRunById(id);
    if (data == null) return null;
    return RunMapper.fromData(data);
  }

  @override
  Future<List<Run>> getRunHistory({int limit = 50, int offset = 0}) async {
    final dataList = await _dao.getAllRuns(limit: limit, offset: offset);
    return dataList.map((d) => RunMapper.fromData(d)).toList();
  }

  @override
  Future<List<Run>> searchRuns(String query) async {
    final dataList = await _dao.searchRuns(query);
    return dataList.map((d) => RunMapper.fromData(d)).toList();
  }

  @override
  Stream<List<Run>> watchRunHistory() {
    return _dao.watchAllRuns().map(
      (dataList) => dataList.map((d) => RunMapper.fromData(d)).toList(),
    );
  }

  @override
  Future<void> deleteRun(String id) async {
    await _dao.deleteRun(id);
  }

  @override
  Future<int> getRunCount() async {
    return _dao.getRunCount();
  }
}
