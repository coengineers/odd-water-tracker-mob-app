import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class WeeklyStatsRow extends StatelessWidget {
  const WeeklyStatsRow({
    super.key,
    required this.dailyTotals,
    required this.targetMl,
  });

  final Map<String, int> dailyTotals;
  final int targetMl;

  @override
  Widget build(BuildContext context) {
    final last7 = _last7Days();
    int sum = 0;
    int daysHit = 0;
    for (final day in last7) {
      final ml = dailyTotals[day] ?? 0;
      sum += ml;
      if (ml >= targetMl) daysHit++;
    }
    final avg = sum ~/ 7;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'Avg / day', value: '$avg ml'),
          _Stat(label: 'Days on target', value: '$daysHit / 7'),
        ],
      ),
    );
  }

  List<String> _last7Days() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return d.toIso8601String().substring(0, 10);
    });
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space1),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
