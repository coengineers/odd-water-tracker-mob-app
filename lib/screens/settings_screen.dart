import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../debug/seed_data.dart';
import '../providers/database_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/water_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/edit_target_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _invalidateAll(WidgetRef ref) {
    ref.invalidate(dailyTargetProvider);
    ref.invalidate(streaksProvider);
    ref.invalidate(todayTotalProvider);
    ref.invalidate(todayEntriesProvider);
    ref.invalidate(weeklySummaryProvider);
    ref.invalidate(monthlyTotalsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyTarget = ref.watch(dailyTargetProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Semantics(
        label: 'Settings screen',
        child: ListView(
          children: [
            // Daily Target
            dailyTarget.when(
              data: (target) => ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Daily Target'),
                subtitle: Text('$target ml'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final newTarget = await EditTargetSheet.show(
                    context,
                    currentTarget: target,
                  );
                  if (newTarget != null) {
                    await ref
                        .read(settingsRepositoryProvider)
                        .setTarget(newTarget);
                    ref.invalidate(dailyTargetProvider);
                    ref.invalidate(streaksProvider);
                  }
                },
              ),
              loading: () => const ListTile(
                leading: Icon(Icons.flag_outlined),
                title: Text('Daily Target'),
                subtitle: Text('Loading...'),
              ),
              error: (e, _) => ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Daily Target'),
                subtitle: Text('Error: $e'),
              ),
            ),

            // Reset All Data
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Reset All Data',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset All Data?'),
                    content: const Text(
                      'This will delete all water entries and reset your daily target to 2000 ml. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref
                              .read(settingsRepositoryProvider)
                              .resetAllData()
                              .then((_) {
                                _invalidateAll(ref);
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('All data reset'),
                                  ),
                                );
                                navigator.pop();
                              });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // About
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About'),
              subtitle: Text('WaterLog v1.0 — Offline water tracker'),
            ),

            // Seed Sample Data (debug only)
            if (kDebugMode)
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: const Text('Seed Sample Data'),
                onTap: () {
                  final db = ref.read(appDatabaseProvider);
                  final messenger = ScaffoldMessenger.of(context);
                  seedSampleData(db).then((_) {
                    _invalidateAll(ref);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Sample data seeded')),
                    );
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
