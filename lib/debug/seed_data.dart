import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

Future<void> seedSampleData(AppDatabase db) async {
  if (!kDebugMode) return;

  final random = Random();
  const uuid = Uuid();
  final now = DateTime.now();

  // Pick ~4 random days to skip (out of 30)
  final skipDays = <int>{};
  while (skipDays.length < 4) {
    skipDays.add(random.nextInt(30) + 1);
  }

  for (var daysAgo = 1; daysAgo <= 30; daysAgo++) {
    if (skipDays.contains(daysAgo)) continue;

    final day = now.subtract(Duration(days: daysAgo));
    final entryDate = day.toIso8601String().substring(0, 10);
    final entryCount = random.nextInt(4) + 2; // 2-5 entries

    for (var i = 0; i < entryCount; i++) {
      final hour = 7 + random.nextInt(14); // 7:00 - 20:59
      final minute = random.nextInt(60);
      final entryTime = DateTime(day.year, day.month, day.day, hour, minute);
      final amountMl =
          (random.nextInt(14) + 3) * 50; // 150-800 ml in 50ml steps

      await db
          .into(db.waterEntries)
          .insert(
            WaterEntriesCompanion.insert(
              id: uuid.v4(),
              entryTs: entryTime.toIso8601String(),
              entryDate: entryDate,
              amountMl: amountMl,
              createdAt: entryTime.toIso8601String(),
            ),
          );
    }
  }
}
