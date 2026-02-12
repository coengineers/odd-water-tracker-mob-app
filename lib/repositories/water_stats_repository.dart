import 'package:drift/drift.dart';

import '../db/app_database.dart';

class WaterStatsRepository {
  WaterStatsRepository(this._db);

  final AppDatabase _db;

  Future<int> getTodayTotal() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final result =
        await (_db.selectOnly(_db.waterEntries)
              ..addColumns([_db.waterEntries.amountMl.sum()])
              ..where(_db.waterEntries.entryDate.equals(today)))
            .getSingleOrNull();
    return result?.read(_db.waterEntries.amountMl.sum()) ?? 0;
  }

  Future<Map<String, int>> getDailyTotals(
    String rangeStart,
    String rangeEnd,
  ) async {
    final query = _db.selectOnly(_db.waterEntries)
      ..addColumns([
        _db.waterEntries.entryDate,
        _db.waterEntries.amountMl.sum(),
      ])
      ..where(
        _db.waterEntries.entryDate.isBiggerOrEqualValue(rangeStart) &
            _db.waterEntries.entryDate.isSmallerOrEqualValue(rangeEnd),
      )
      ..groupBy([_db.waterEntries.entryDate]);

    final rows = await query.get();
    final map = <String, int>{};
    for (final row in rows) {
      final date = row.read(_db.waterEntries.entryDate);
      final total = row.read(_db.waterEntries.amountMl.sum());
      if (date != null && total != null) {
        map[date] = total;
      }
    }
    return map;
  }

  Future<Map<String, int>> getWeeklySummary(String endingOnDate) async {
    final end = DateTime.parse(endingOnDate);
    final start = end.subtract(const Duration(days: 6));
    final startStr = start.toIso8601String().substring(0, 10);
    return getDailyTotals(startStr, endingOnDate);
  }

  Future<Map<String, int>> getMonthlyTotals(int year, int month) async {
    final startStr =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final endDate = DateTime(
      nextYear,
      nextMonth,
      1,
    ).subtract(const Duration(days: 1));
    final endStr = endDate.toIso8601String().substring(0, 10);
    return getDailyTotals(startStr, endStr);
  }

  Future<({int current, int longest})> getStreaks(
    String todayDate,
    int targetMl,
  ) async {
    // Get all daily totals up to today, ordered descending
    final query = _db.selectOnly(_db.waterEntries)
      ..addColumns([
        _db.waterEntries.entryDate,
        _db.waterEntries.amountMl.sum(),
      ])
      ..where(_db.waterEntries.entryDate.isSmallerOrEqualValue(todayDate))
      ..groupBy([_db.waterEntries.entryDate])
      ..orderBy([OrderingTerm.desc(_db.waterEntries.entryDate)]);

    final rows = await query.get();

    // Build a set of dates that met the target
    final metDates = <String>{};
    for (final row in rows) {
      final date = row.read(_db.waterEntries.entryDate);
      final total = row.read(_db.waterEntries.amountMl.sum());
      if (date != null && total != null && total >= targetMl) {
        metDates.add(date);
      }
    }

    if (metDates.isEmpty) {
      return (current: 0, longest: 0);
    }

    // Calculate current streak (consecutive days ending at today)
    int current = 0;
    var checkDate = DateTime.parse(todayDate);
    while (metDates.contains(checkDate.toIso8601String().substring(0, 10))) {
      current++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Calculate longest streak
    int longest = 0;
    int streak = 0;
    // Sort dates ascending
    final sortedDates = metDates.toList()..sort();
    for (int i = 0; i < sortedDates.length; i++) {
      if (i == 0) {
        streak = 1;
      } else {
        final prev = DateTime.parse(sortedDates[i - 1]);
        final curr = DateTime.parse(sortedDates[i]);
        if (curr.difference(prev).inDays == 1) {
          streak++;
        } else {
          streak = 1;
        }
      }
      if (streak > longest) {
        longest = streak;
      }
    }

    return (current: current, longest: longest);
  }
}
