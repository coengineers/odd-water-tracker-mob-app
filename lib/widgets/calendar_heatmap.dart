import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CalendarHeatmap extends StatefulWidget {
  const CalendarHeatmap({
    super.key,
    required this.dailyTotals,
    required this.targetMl,
    required this.year,
    required this.month,
  });

  final Map<String, int> dailyTotals;
  final int targetMl;
  final int year;
  final int month;

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  String? _selectedDay;

  int get _daysInMonth {
    final nextMonth = widget.month == 12 ? 1 : widget.month + 1;
    final nextYear = widget.month == 12 ? widget.year + 1 : widget.year;
    return DateTime(
      nextYear,
      nextMonth,
      1,
    ).subtract(const Duration(days: 1)).day;
  }

  /// Monday = 0, Sunday = 6
  int get _startWeekday {
    return DateTime(widget.year, widget.month, 1).weekday - 1;
  }

  String _dateStr(int day) {
    final y = widget.year.toString().padLeft(4, '0');
    final m = widget.month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Color _cellColor(int ml) {
    if (ml == 0) return AppColors.bgSurfaceHover;
    final fraction = ml / widget.targetMl;
    if (fraction <= 0.25) return AppColors.primary.withValues(alpha: 0.2);
    if (fraction <= 0.50) return AppColors.primary.withValues(alpha: 0.4);
    if (fraction <= 0.75) return AppColors.primary.withValues(alpha: 0.6);
    if (fraction < 1.0) return AppColors.primary.withValues(alpha: 0.8);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth;
    final offset = _startWeekday;
    final totalCells = offset + days;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day-of-week headers
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DayHeader('M'),
              _DayHeader('T'),
              _DayHeader('W'),
              _DayHeader('T'),
              _DayHeader('F'),
              _DayHeader('S'),
              _DayHeader('S'),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),

          // Calendar grid
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: List.generate(totalCells, (index) {
              if (index < offset) {
                return const SizedBox.shrink();
              }
              final day = index - offset + 1;
              final dateStr = _dateStr(day);
              final ml = widget.dailyTotals[dateStr] ?? 0;
              final hitTarget = ml >= widget.targetMl && ml > 0;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = _selectedDay == dateStr ? null : dateStr;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _cellColor(ml),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Center(
                    child: hitTarget
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: AppColors.success,
                          )
                        : Text(
                            '$day',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),

          // Tooltip
          if (_selectedDay != null) ...[
            const SizedBox(height: AppSpacing.space3),
            _TooltipCard(
              dateStr: _selectedDay!,
              ml: widget.dailyTotals[_selectedDay!] ?? 0,
              targetMl: widget.targetMl,
            ),
          ],
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TooltipCard extends StatelessWidget {
  const _TooltipCard({
    required this.dateStr,
    required this.ml,
    required this.targetMl,
  });

  final String dateStr;
  final int ml;
  final int targetMl;

  @override
  Widget build(BuildContext context) {
    final hitTarget = ml >= targetMl && ml > 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space3),
        child: Row(
          children: [
            Text(
              dateStr,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.space3),
            Text(
              '$ml ml',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
            const Spacer(),
            if (hitTarget)
              const Icon(Icons.check_circle, color: AppColors.success, size: 18)
            else
              Text(
                'Below target',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}
