import 'package:drift/drift.dart';

import '../db/app_database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<int> getTarget() async {
    final row = await (_db.select(
      _db.userSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    return row?.dailyTargetMl ?? 2000;
  }

  Future<void> setTarget(int dailyTargetMl) async {
    if (dailyTargetMl < 250 || dailyTargetMl > 10000) {
      throw ArgumentError.value(
        dailyTargetMl,
        'dailyTargetMl',
        'Must be between 250 and 10000',
      );
    }

    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.userSettings)..where((t) => t.id.equals(1))).write(
      UserSettingsCompanion(
        dailyTargetMl: Value(dailyTargetMl),
        updatedAt: Value(now),
      ),
    );
  }
}
