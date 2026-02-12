import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../db/app_database.dart';
import 'repository_providers.dart';

part 'water_providers.g.dart';

@riverpod
Future<int> todayTotal(Ref ref) {
  return ref.watch(waterStatsRepositoryProvider).getTodayTotal();
}

@riverpod
Future<List<WaterEntry>> todayEntries(Ref ref) {
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return ref.watch(waterEntryRepositoryProvider).listByDate(today);
}

@riverpod
Future<({int current, int longest})> streaks(Ref ref) {
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return settingsRepo.getTarget().then(
    (targetMl) =>
        ref.watch(waterStatsRepositoryProvider).getStreaks(today, targetMl),
  );
}

@riverpod
Future<Map<String, int>> weeklySummary(Ref ref) {
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return ref.watch(waterStatsRepositoryProvider).getWeeklySummary(today);
}

@riverpod
Future<Map<String, int>> monthlyTotals(Ref ref) {
  final now = DateTime.now();
  return ref
      .watch(waterStatsRepositoryProvider)
      .getMonthlyTotals(now.year, now.month);
}
