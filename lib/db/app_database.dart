import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/user_settings.dart';
import 'tables/water_entries.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [WaterEntries, UserSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _createIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createAll();
          await _createIndexes();
        }
      },
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await _seedDefaultSettings();
      },
    );
  }

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_water_entries_entry_date '
      'ON water_entries (entry_date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_water_entries_entry_ts '
      'ON water_entries (entry_ts)',
    );
  }

  Future<void> _seedDefaultSettings() async {
    final now = DateTime.now().toIso8601String();
    await customStatement(
      'INSERT OR IGNORE INTO user_settings (id, daily_target_ml, created_at, updated_at) '
      "VALUES (1, 2000, '$now', '$now')",
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'water_log.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
