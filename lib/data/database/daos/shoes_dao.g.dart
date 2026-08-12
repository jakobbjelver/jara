// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shoes_dao.dart';

// ignore_for_file: type=lint
mixin _$ShoesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShoesTable get shoes => attachedDatabase.shoes;
  ShoesDaoManager get managers => ShoesDaoManager(this);
}

class ShoesDaoManager {
  final _$ShoesDaoMixin _db;
  ShoesDaoManager(this._db);
  $$ShoesTableTableManager get shoes =>
      $$ShoesTableTableManager(_db.attachedDatabase, _db.shoes);
}
