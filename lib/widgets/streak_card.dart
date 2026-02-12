import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.current, required this.longest});

  final int current;
  final int longest;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Current streak $current days, Longest streak $longest days',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StreakColumn(value: current, label: 'Current Streak'),
              _StreakColumn(value: longest, label: 'Longest Streak'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakColumn extends StatelessWidget {
  const _StreakColumn({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: AppColors.primary),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
