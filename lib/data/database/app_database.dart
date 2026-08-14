import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'tables/runs_table.dart';
import 'tables/shoes_table.dart';
import 'tables/personal_records_table.dart';
import 'daos/runs_dao.dart';
import 'daos/shoes_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Runs, Shoes, PersonalRecords],
  daos: [RunsDao, ShoesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'jara.sqlite'));
      return NativeDatabase(file);
    });
  }
}
