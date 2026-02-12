import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.consumed, required this.target});

  final int consumed;
  final int target;

  @override
  Widget build(BuildContext context) {
    final fraction = target > 0 ? min(consumed / target, 1.0) : 0.0;
    final targetMet = consumed >= target && target > 0;
    final fillColor = targetMet ? AppColors.success : AppColors.primary;

    return Semantics(
      label: '$consumed of $target ml consumed',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: SizedBox(
              height: 20,
              width: double.infinity,
              child: ColoredBox(
                color: AppColors.bgSurfaceHover,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: fraction,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            '$consumed / $target ml',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
