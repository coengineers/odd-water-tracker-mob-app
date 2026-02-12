import 'package:drift/drift.dart';

class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dailyTargetMl =>
      integer().check(dailyTargetMl.isBetweenValues(250, 10000))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
}
