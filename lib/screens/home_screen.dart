import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repository_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/water_providers.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/custom_amount_sheet.dart';
import '../widgets/progress_ring.dart';
import '../widgets/quick_add_button.dart';
import '../widgets/streak_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _addWater(WidgetRef ref, int amountMl) {
    ref.read(waterEntryRepositoryProvider).add(amountMl: amountMl).then((_) {
      ref.invalidate(todayTotalProvider);
      ref.invalidate(todayEntriesProvider);
      ref.invalidate(streaksProvider);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTotal = ref.watch(todayTotalProvider);
    final dailyTarget = ref.watch(dailyTargetProvider);
    final streaks = ref.watch(streaksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WaterLog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Semantics(
        label: 'Home screen',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            children: [
              // Progress ring
              todayTotal.when(
                data: (total) => dailyTarget.when(
                  data: (target) =>
                      ProgressRing(consumed: total, target: target),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
              const SizedBox(height: AppSpacing.space2),

              // Daily target label
              dailyTarget.when(
                data: (target) => Text(
                  'Daily Target: $target ml',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.space3),

              // Empty state prompt
              todayTotal.when(
                data: (total) => total == 0
                    ? Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.space3,
                        ),
                        child: Text(
                          'Start tracking by logging your first glass!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              // Quick-add buttons
              Wrap(
                spacing: AppSpacing.space3,
                runSpacing: AppSpacing.space3,
                alignment: WrapAlignment.center,
                children: [
                  QuickAddButton(
                    label: 'Glass',
                    icon: Icons.local_drink_outlined,
                    amountMl: 250,
                    onPressed: () => _addWater(ref, 250),
                  ),
                  QuickAddButton(
                    label: 'Bottle',
                    icon: Icons.water_drop_outlined,
                    amountMl: 500,
                    onPressed: () => _addWater(ref, 500),
                  ),
                  QuickAddButton(
                    label: 'Large',
                    icon: Icons.water_outlined,
                    amountMl: 750,
                    onPressed: () => _addWater(ref, 750),
                  ),
                  QuickAddButton(
                    label: 'Custom',
                    icon: Icons.edit_outlined,
                    onPressed: () async {
                      final amount = await CustomAmountSheet.show(context);
                      if (amount != null) {
                        _addWater(ref, amount);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space6),

              // Streak display
              streaks.when(
                data: (s) => StreakCard(current: s.current, longest: s.longest),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
