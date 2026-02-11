import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/db/app_database.dart';
import 'package:water_log/repositories/water_entry_repository.dart';

void main() {
  group('WaterEntryRepository', () {
    late AppDatabase db;
    late WaterEntryRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = WaterEntryRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('add() creates entry with correct fields', () async {
      final ts = DateTime(2025, 3, 15, 10, 30);
      final entry = await repo.add(amountMl: 500, entryTs: ts);

      expect(entry.amountMl, equals(500));
      expect(entry.entryDate, equals('2025-03-15'));
      expect(entry.entryTs, startsWith('2025-03-15T10:30:00'));
      expect(entry.id, isNotEmpty);
      expect(entry.createdAt, isNotEmpty);
    });

    test('add() derives entryDate from entryTs', () async {
      final ts = DateTime(2025, 12, 31, 23, 59);
      final entry = await repo.add(amountMl: 250, entryTs: ts);

      expect(entry.entryDate, equals('2025-12-31'));
    });

    test('add() uses DateTime.now() when entryTs omitted', () async {
      final entry = await repo.add(amountMl: 300);
      final today = DateTime.now().toIso8601String().substring(0, 10);

      expect(entry.entryDate, equals(today));
    });

    test('add() throws for amountMl < 1', () {
      expect(
        () => repo.add(amountMl: 0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('add() throws for amountMl > 5000', () {
      expect(
        () => repo.add(amountMl: 5001),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('listByDate() returns entries newest-first', () async {
      final ts1 = DateTime(2025, 3, 15, 8, 0);
      final ts2 = DateTime(2025, 3, 15, 12, 0);
      final ts3 = DateTime(2025, 3, 15, 16, 0);

      await repo.add(amountMl: 250, entryTs: ts1);
      await repo.add(amountMl: 500, entryTs: ts2);
      await repo.add(amountMl: 750, entryTs: ts3);

      final entries = await repo.listByDate('2025-03-15');
      expect(entries, hasLength(3));
      // Newest first
      expect(entries[0].amountMl, equals(750));
      expect(entries[1].amountMl, equals(500));
      expect(entries[2].amountMl, equals(250));
    });

    test('listByDate() returns empty list for no data', () async {
      final entries = await repo.listByDate('2025-01-01');
      expect(entries, isEmpty);
    });

    test('delete() removes entry and returns true', () async {
      final entry = await repo.add(amountMl: 500);
      final deleted = await repo.delete(entry.id);

      expect(deleted, isTrue);

      final entries = await repo.listByDate(entry.entryDate);
      expect(entries, isEmpty);
    });

    test('delete() returns false for non-existent id', () async {
      final deleted = await repo.delete('non-existent-id');
      expect(deleted, isFalse);
    });
  });
}
