import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/settings_repository.dart';
import '../repositories/water_entry_repository.dart';
import '../repositories/water_stats_repository.dart';
import 'database_provider.dart';

part 'repository_providers.g.dart';

@Riverpod(keepAlive: true)
WaterEntryRepository waterEntryRepository(Ref ref) {
  return WaterEntryRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
WaterStatsRepository waterStatsRepository(Ref ref) {
  return WaterStatsRepository(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
}
