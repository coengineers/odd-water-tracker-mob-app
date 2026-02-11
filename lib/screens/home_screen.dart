import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/repository_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/water_providers.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Column(
            children: [
              // Progress section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space6),
                  child: Column(
                    children: [
                      Text(
                        'Today\'s Progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      todayTotal.when(
                        data: (total) => dailyTarget.when(
                          data: (target) => Text(
                            '$total / $target ml',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: total >= target
                                      ? AppColors.success
                                      : AppColors.primary,
                                ),
                          ),
                          loading: () =>
                              const CircularProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                        ),
                        loading: () =>
                            const CircularProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space6),

              // Quick-add buttons
              Text(
                'Quick Add',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.space3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAddButton(
                    amountMl: 250,
                    onPressed: () => _addWater(ref, 250),
                  ),
                  _QuickAddButton(
                    amountMl: 500,
                    onPressed: () => _addWater(ref, 500),
                  ),
                  _QuickAddButton(
                    amountMl: 750,
                    onPressed: () => _addWater(ref, 750),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space6),

              // Streak display
              streaks.when(
                data: (s) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${s.current}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            Text(
                              'Current Streak',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${s.longest}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            Text(
                              'Longest Streak',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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

class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({
    required this.amountMl,
    required this.onPressed,
  });

  final int amountMl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Text('${amountMl}ml'),
    );
  }
}
