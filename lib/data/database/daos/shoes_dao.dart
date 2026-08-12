import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/shoes_table.dart';

part 'shoes_dao.g.dart';

@DriftAccessor(tables: [Shoes])
class ShoesDao extends DatabaseAccessor<AppDatabase> with _$ShoesDaoMixin {
  ShoesDao(super.db);

  Future<List<ShoeData>> getAllShoes() {
    return (select(
      shoes,
    )..orderBy([(s) => OrderingTerm.desc(s.createdAt)])).get();
  }

  Future<ShoeData?> getShoeById(String id) {
    return (select(shoes)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertShoe(Insertable<ShoeData> shoe) {
    return into(shoes).insert(shoe);
  }

  Future<int> deleteShoe(String id) {
    return (delete(shoes)..where((s) => s.id.equals(id))).go();
  }

  Stream<List<ShoeData>> watchAllShoes() {
    return (select(
      shoes,
    )..orderBy([(s) => OrderingTerm.desc(s.createdAt)])).watch();
  }
}
