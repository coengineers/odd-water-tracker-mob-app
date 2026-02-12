import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';
import '../providers/water_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/weekly_stats_row.dart';

class WeeklyScreen extends ConsumerWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyData = ref.watch(weeklySummaryProvider);
    final dailyTarget = ref.watch(dailyTargetProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Summary')),
      body: Semantics(
        label: 'Weekly summary screen',
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: weeklyData.when(
            data: (totals) => dailyTarget.when(
              data: (target) {
                if (totals.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bar_chart_outlined,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Text(
                          'No data this week',
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
                return Column(
                  children: [
                    Card(
                      child: WeeklyBarChart(
                        dailyTotals: totals,
                        targetMl: target,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Card(
                      child: WeeklyStatsRow(
                        dailyTotals: totals,
                        targetMl: target,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ),
    );
  }
}
