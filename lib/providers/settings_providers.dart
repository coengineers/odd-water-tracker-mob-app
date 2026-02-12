import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'repository_providers.dart';

part 'settings_providers.g.dart';

@riverpod
Future<int> dailyTarget(Ref ref) {
  return ref.watch(settingsRepositoryProvider).getTarget();
}
