import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class QuickAddButton extends StatelessWidget {
  const QuickAddButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.amountMl,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final int? amountMl;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add $label ${amountMl ?? ""} ml',
      child: SizedBox(
        width: 76,
        child: Material(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.space3,
                horizontal: AppSpacing.space2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.space1),
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  if (amountMl != null) ...[
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      '$amountMl ml',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
