import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class WeeklySpendingChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> data;
  final String currency;

  const WeeklySpendingChart({
    super.key,
    required this.data,
    this.currency = '₹',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = data.fold(0.0, (max, e) => e.value > max ? e.value : max);
    final roundedMax = maxY == 0 ? 1000.0 : (maxY * 1.3);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: roundedMax,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.surface,
              tooltipRoundedRadius: 10,
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '$currency${rod.toY.toStringAsFixed(0)}',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox();
                  final day = data[idx].key;
                  final isToday = _isToday(day);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      isToday ? 'Today' : DateFormat('EEE').format(day),
                      style: TextStyle(
                        color: isToday
                            ? AppTheme.primary
                            : theme.textTheme.bodySmall?.color,
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final idx = entry.key;
            final value = entry.value.value;
            final isToday = _isToday(entry.value.key);

            return BarChartGroupData(
              x: idx,
              barRods: [
                BarChartRodData(
                  toY: value == 0 ? roundedMax * 0.02 : value,
                  color: isToday
                      ? AppTheme.primary
                      : value == 0
                          ? theme.colorScheme.surfaceContainerHighest
                          : AppTheme.primary.withOpacity(0.3),
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                    bottom: Radius.circular(2),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 400),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;
  final Map<String, Color> colors;

  const CategoryPieChart({
    super.key,
    required this.data,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (sum, v) => sum + v);
    if (total == 0) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No data')),
      );
    }

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: data.entries.map((entry) {
            final pct = (entry.value / total * 100);
            return PieChartSectionData(
              value: entry.value,
              color: colors[entry.key] ?? Colors.grey,
              radius: 32,
              title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          startDegreeOffset: -90,
        ),
        swapAnimationDuration: const Duration(milliseconds: 400),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }
}
