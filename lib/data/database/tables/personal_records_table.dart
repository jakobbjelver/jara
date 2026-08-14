import 'package:drift/drift.dart';

/// Personal records table (V1.5 — table exists from V1, unused until V1.5).
@DataClassName('PersonalRecordData')
class PersonalRecords extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get distanceKey => text()();
  TextColumn get runId => text()();
  IntColumn get timeSeconds => integer()();
  RealColumn get paceSecondsPerKm => real()();
  DateTimeColumn get achievedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
