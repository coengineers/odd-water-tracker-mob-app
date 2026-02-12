import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.dailyTotals,
    required this.targetMl,
  });

  final Map<String, int> dailyTotals;
  final int targetMl;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<String> _last7Days() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return d.toIso8601String().substring(0, 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _last7Days();

    return Semantics(
      label: 'Weekly water intake bar chart',
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _maxY(days),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) return const SizedBox.shrink();
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= 7) {
                        return const SizedBox.shrink();
                      }
                      final date = DateTime.parse(days[idx]);
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.space1),
                        child: Text(
                          _dayLabels[date.weekday - 1],
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: targetMl.toDouble(),
                    color: AppColors.textMuted,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                      labelResolver: (_) => 'Target',
                    ),
                  ),
                ],
              ),
              barGroups: List.generate(7, (i) {
                final ml = dailyTotals[days[i]] ?? 0;
                final hitTarget = ml >= targetMl;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: ml.toDouble(),
                      color: hitTarget ? AppColors.success : AppColors.primary,
                      width: 16,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusSm),
                        topRight: Radius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  double _maxY(List<String> days) {
    double max = targetMl.toDouble();
    for (final day in days) {
      final ml = (dailyTotals[day] ?? 0).toDouble();
      if (ml > max) max = ml;
    }
    return max * 1.15;
  }
}
