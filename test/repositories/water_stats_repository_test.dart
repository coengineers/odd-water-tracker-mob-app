import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/db/app_database.dart';
import 'package:water_log/repositories/water_entry_repository.dart';
import 'package:water_log/repositories/water_stats_repository.dart';

void main() {
  group('WaterStatsRepository', () {
    late AppDatabase db;
    late WaterEntryRepository entryRepo;
    late WaterStatsRepository statsRepo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      entryRepo = WaterEntryRepository(db);
      statsRepo = WaterStatsRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('getTodayTotal() returns 0 with no entries', () async {
      final total = await statsRepo.getTodayTotal();
      expect(total, equals(0));
    });

    test('getTodayTotal() sums correctly', () async {
      await entryRepo.add(amountMl: 250);
      await entryRepo.add(amountMl: 500);
      await entryRepo.add(amountMl: 750);

      final total = await statsRepo.getTodayTotal();
      expect(total, equals(1500));
    });

    test('getDailyTotals() returns correct range', () async {
      await entryRepo.add(
        amountMl: 500,
        entryTs: DateTime(2025, 3, 10, 10, 0),
      );
      await entryRepo.add(
        amountMl: 300,
        entryTs: DateTime(2025, 3, 11, 10, 0),
      );
      await entryRepo.add(
        amountMl: 400,
        entryTs: DateTime(2025, 3, 12, 10, 0),
      );

      final totals = await statsRepo.getDailyTotals('2025-03-10', '2025-03-12');

      expect(totals, hasLength(3));
      expect(totals['2025-03-10'], equals(500));
      expect(totals['2025-03-11'], equals(300));
      expect(totals['2025-03-12'], equals(400));
    });

    test('getDailyTotals() excludes outside range', () async {
      await entryRepo.add(
        amountMl: 500,
        entryTs: DateTime(2025, 3, 9, 10, 0),
      );
      await entryRepo.add(
        amountMl: 300,
        entryTs: DateTime(2025, 3, 10, 10, 0),
      );
      await entryRepo.add(
        amountMl: 400,
        entryTs: DateTime(2025, 3, 13, 10, 0),
      );

      final totals = await statsRepo.getDailyTotals('2025-03-10', '2025-03-12');

      expect(totals, hasLength(1));
      expect(totals['2025-03-10'], equals(300));
    });

    test('getWeeklySummary() returns 7-day window', () async {
      // Add entries for a week
      for (int i = 0; i < 7; i++) {
        await entryRepo.add(
          amountMl: 100 * (i + 1),
          entryTs: DateTime(2025, 3, 10 + i, 10, 0),
        );
      }

      final summary = await statsRepo.getWeeklySummary('2025-03-16');
      expect(summary, hasLength(7));
      expect(summary['2025-03-10'], equals(100));
      expect(summary['2025-03-16'], equals(700));
    });

    test('getMonthlyTotals() returns correct month', () async {
      await entryRepo.add(
        amountMl: 500,
        entryTs: DateTime(2025, 2, 15, 10, 0),
      );
      await entryRepo.add(
        amountMl: 300,
        entryTs: DateTime(2025, 2, 20, 10, 0),
      );
      // Outside month
      await entryRepo.add(
        amountMl: 999,
        entryTs: DateTime(2025, 3, 1, 10, 0),
      );

      final totals = await statsRepo.getMonthlyTotals(2025, 2);
      expect(totals, hasLength(2));
      expect(totals['2025-02-15'], equals(500));
      expect(totals['2025-02-20'], equals(300));
      expect(totals.containsKey('2025-03-01'), isFalse);
    });

    test('getStreaks() returns (0, 0) for no data', () async {
      final result = await statsRepo.getStreaks('2025-03-15', 2000);
      expect(result.current, equals(0));
      expect(result.longest, equals(0));
    });

    test('getStreaks() calculates current streak', () async {
      // 3-day streak ending today
      final today = DateTime.now();
      for (int i = 2; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        await entryRepo.add(amountMl: 2000, entryTs: date);
      }

      final todayStr = today.toIso8601String().substring(0, 10);
      final result = await statsRepo.getStreaks(todayStr, 2000);
      expect(result.current, equals(3));
    });

    test('getStreaks() detects broken streak', () async {
      // Entries 3 days ago, 2 days ago, today (gap yesterday)
      final today = DateTime.now();
      await entryRepo.add(
        amountMl: 2000,
        entryTs: today.subtract(const Duration(days: 3)),
      );
      await entryRepo.add(
        amountMl: 2000,
        entryTs: today.subtract(const Duration(days: 2)),
      );
      await entryRepo.add(amountMl: 2000, entryTs: today);

      final todayStr = today.toIso8601String().substring(0, 10);
      final result = await statsRepo.getStreaks(todayStr, 2000);
      expect(result.current, equals(1)); // Only today
      expect(result.longest, equals(2)); // 3-day-ago + 2-day-ago
    });

    test('getStreaks() tracks longest streak', () async {
      // 5-day streak in the past, 2-day current
      final today = DateTime.now();
      // Past streak: 10 days ago to 6 days ago (5 days)
      for (int i = 10; i >= 6; i--) {
        await entryRepo.add(
          amountMl: 2000,
          entryTs: today.subtract(Duration(days: i)),
        );
      }
      // Current streak: yesterday + today (2 days)
      await entryRepo.add(
        amountMl: 2000,
        entryTs: today.subtract(const Duration(days: 1)),
      );
      await entryRepo.add(amountMl: 2000, entryTs: today);

      final todayStr = today.toIso8601String().substring(0, 10);
      final result = await statsRepo.getStreaks(todayStr, 2000);
      expect(result.current, equals(2));
      expect(result.longest, equals(5));
    });
  });
}
