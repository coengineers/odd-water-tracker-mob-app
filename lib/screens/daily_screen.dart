import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repository_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/water_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/progress_bar.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref, {
    required String id,
    required int amountMl,
    required String time,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: Text('Remove ${amountMl}ml logged at $time?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(waterEntryRepositoryProvider).delete(id).then((_) {
                ref.invalidate(todayTotalProvider);
                ref.invalidate(todayEntriesProvider);
                ref.invalidate(streaksProvider);
              });
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTotal = ref.watch(todayTotalProvider);
    final todayEntries = ref.watch(todayEntriesProvider);
    final dailyTarget = ref.watch(dailyTargetProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily')),
      body: Semantics(
        label: 'Daily screen',
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today total header
              todayTotal.when(
                data: (total) => Text(
                  'Today: $total ml',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: AppSpacing.space3),

              // Progress bar
              todayTotal.when(
                data: (total) => dailyTarget.when(
                  data: (target) =>
                      ProgressBar(consumed: total, target: target),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.space4),

              // Entries list
              Expanded(
                child: todayEntries.when(
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.water_drop_outlined,
                              size: 64,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: AppSpacing.space3),
                            Text(
                              'No entries yet today',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.space2),
                            Text(
                              'Log water from the Home tab to start tracking!',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final time = entry.entryTs.substring(11, 16);
                        return ListTile(
                          leading: const Icon(Icons.water_drop_outlined),
                          title: Text('${entry.amountMl}ml at $time'),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                          ),
                          onTap: () => _showDeleteConfirmation(
                            context,
                            ref,
                            id: entry.id,
                            amountMl: entry.amountMl,
                            time: time,
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
