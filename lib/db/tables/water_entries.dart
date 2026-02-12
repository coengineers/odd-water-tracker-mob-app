import 'package:drift/drift.dart';

class WaterEntries extends Table {
  TextColumn get id => text()();
  TextColumn get entryTs => text()();
  TextColumn get entryDate => text()();
  IntColumn get amountMl =>
      integer().check(amountMl.isBetweenValues(1, 5000))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
