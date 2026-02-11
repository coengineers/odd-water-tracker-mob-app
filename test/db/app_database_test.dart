import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/db/app_database.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('initialises in-memory without errors', () {
      expect(db, isNotNull);
    });

    test('schemaVersion is 2', () {
      expect(db.schemaVersion, equals(2));
    });

    test('water_entries table accepts valid data', () async {
      await db.into(db.waterEntries).insert(
            WaterEntriesCompanion.insert(
              id: 'test-id-1',
              entryTs: '2025-01-15T10:30:00.000',
              entryDate: '2025-01-15',
              amountMl: 500,
              createdAt: '2025-01-15T10:30:00.000',
            ),
          );

      final entries = await db.select(db.waterEntries).get();
      expect(entries, hasLength(1));
      expect(entries.first.amountMl, equals(500));
      expect(entries.first.entryDate, equals('2025-01-15'));
    });

    test('user_settings table accepts valid data', () async {
      // The default settings are seeded by beforeOpen
      final settings = await db.select(db.userSettings).get();
      expect(settings, hasLength(1));
      expect(settings.first.dailyTargetMl, equals(2000));
    });

    test('default settings row is seeded with id=1', () async {
      final row = await (db.select(db.userSettings)
            ..where((t) => t.id.equals(1)))
          .getSingleOrNull();
      expect(row, isNotNull);
      expect(row!.dailyTargetMl, equals(2000));
    });
  });
}
