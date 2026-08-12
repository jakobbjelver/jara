import 'package:drift/drift.dart';

/// Runs table with forward-looking schema — includes V1.5 columns from day 1.
@DataClassName('RunData')
class Runs extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  RealColumn get distanceMeters => real().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get avgPaceSecondsPerKm => real().nullable()();
  TextColumn get routePointsJson => text().nullable()();
  TextColumn get lapsJson => text().nullable()();
  RealColumn get elevationGainMeters => real().nullable()();
  RealColumn get elevationLossMeters => real().nullable()();
  IntColumn get avgHeartRate => integer().nullable()();
  IntColumn get maxHeartRate => integer().nullable()();
  TextColumn get heartRateZonesJson => text().nullable()();
  RealColumn get avgCadence => real().nullable()();
  TextColumn get shoeId => text().nullable()();
  TextColumn get weatherJson => text().nullable()();
  RealColumn get weatherTempCelsius => real().nullable()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
