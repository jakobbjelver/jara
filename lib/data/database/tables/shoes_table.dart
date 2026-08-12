import 'package:drift/drift.dart';

/// Shoes table (V1.5 — table exists from V1, unused until V1.5).
@DataClassName('ShoeData')
class Shoes extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();
  RealColumn get initialMileageMeters =>
      real().withDefault(const Constant(0))();
  RealColumn get targetMileageMeters => real().nullable()();
  BoolColumn get retired => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
