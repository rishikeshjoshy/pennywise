import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/enums.dart';
import '../../theme/app_theme.dart';
import '../../widgets/charts.dart';
import '../../widgets/empty_state.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txProvider = context.watch<TransactionProvider>();
    final settings = context.watch<SettingsProvider>();
    final categories = txProvider.expensesByCategory;

    if (txProvider.allTransactions.isEmpty) {
      return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Insights', style: theme.textTheme.headlineMedium),
              ),
            ),
            const Expanded(
              child: EmptyState(
                icon: Icons.insights_rounded,
                title: 'No insights yet',
                subtitle: 'Add some transactions to see\nyour spending patterns here',
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('Insights', style: theme.textTheme.headlineMedium),
            ),
          ),

          // ── Smart Insights Cards ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _InsightBanner(
                insights: _generateInsights(txProvider, settings),
              ),
            ),
          ),

          // ── Monthly Comparison ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _MonthlyComparison(
                thisMonth: txProvider.thisMonthExpenses,
                lastMonth: txProvider.lastMonthExpenses,
                settings: settings,
              ),
            ),
          ),

          // ── Weekly Comparison ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _WeeklyComparison(
                thisWeek: txProvider.thisWeekExpenses,
                lastWeek: txProvider.lastWeekExpenses,
                settings: settings,
              ),
            ),
          ),

          // ── Category Breakdown ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Spending by Category', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('This month', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 16),
                    if (categories.isNotEmpty)
                      CategoryPieChart(
                        data: {for (final e in categories.entries) e.key.label: e.value},
                        colors: {for (final e in categories.entries) e.key.label: e.key.color},
                      )
                    else
                      const SizedBox(
                        height: 120,
                        child: Center(child: Text('No expenses this month')),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Category List ───────────────────────────────
          if (categories.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: categories.entries.map((entry) {
                      final total = categories.values.fold(0.0, (s, v) => s + v);
                      final pct = total > 0 ? entry.value / total : 0.0;
                      return _CategoryRow(
                        category: entry.key,
                        amount: entry.value,
                        percentage: pct,
                        settings: settings,
                        isLast: entry.key == categories.keys.last,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

          // ── Daily Average ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.calculate_outlined,
                        color: AppTheme.warning,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Average Spend', style: theme.textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text('Based on this month', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      settings.formatAmount(txProvider.avgDailyExpense),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Transaction Stats ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Total Transactions',
                      value: txProvider.totalTransactionCount.toString(),
                      icon: Icons.format_list_numbered_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: 'Top Category',
                      value: txProvider.topCategory?.label ?? 'N/A',
                      icon: txProvider.topCategory?.icon ?? Icons.category_rounded,
                      color: txProvider.topCategory?.color ?? Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  List<_InsightData> _generateInsights(
    TransactionProvider tx,
    SettingsProvider settings,
  ) {
    final insights = <_InsightData>[];

    // Week comparison
    if (tx.lastWeekExpenses > 0) {
      final diff = tx.thisWeekExpenses - tx.lastWeekExpenses;
      final pct = (diff / tx.lastWeekExpenses * 100).abs();
      if (diff < 0) {
        insights.add(_InsightData(
          icon: Icons.trending_down_rounded,
          color: AppTheme.income,
          text: 'You spent ${pct.toStringAsFixed(0)}% less this week than last week. Keep it up!',
        ));
      } else if (diff > 0) {
        insights.add(_InsightData(
          icon: Icons.trending_up_rounded,
          color: AppTheme.expense,
          text: 'Spending is up ${pct.toStringAsFixed(0)}% this week compared to last week.',
        ));
      }
    }

    // Top category insight
    final topCat = tx.topCategory;
    if (topCat != null) {
      final catAmount = tx.expensesByCategory[topCat]!;
      insights.add(_InsightData(
        icon: topCat.icon,
        color: topCat.color,
        text: '${topCat.label} is your biggest expense this month at ${settings.formatAmount(catAmount)}.',
      ));
    }

    // Budget insight
    if (settings.monthlyBudget > 0) {
      final remaining = settings.monthlyBudget - tx.thisMonthExpenses;
      final now = DateTime.now();
      final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day;
      if (remaining > 0 && daysLeft > 0) {
        insights.add(_InsightData(
          icon: Icons.lightbulb_outline_rounded,
          color: AppTheme.warning,
          text: 'You can spend about ${settings.formatAmount(remaining / daysLeft)}/day to stay within budget.',
        ));
      }
    }

    if (insights.isEmpty) {
      insights.add(_InsightData(
        icon: Icons.auto_awesome_rounded,
        color: AppTheme.primary,
        text: 'Add more transactions to unlock personalized insights about your spending habits.',
      ));
    }

    return insights;
  }
}

class _InsightData {
  final IconData icon;
  final Color color;
  final String text;
  const _InsightData({required this.icon, required this.color, required this.text});
}

class _InsightBanner extends StatelessWidget {
  final List<_InsightData> insights;
  const _InsightBanner({required this.insights});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: insights.map((insight) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: insight.color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: insight.color.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: insight.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(insight.icon, color: insight.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MonthlyComparison extends StatelessWidget {
  final double thisMonth;
  final double lastMonth;
  final SettingsProvider settings;

  const _MonthlyComparison({
    required this.thisMonth,
    required this.lastMonth,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = lastMonth > 0
        ? ((thisMonth - lastMonth) / lastMonth * 100)
        : 0.0;
    final isDown = change <= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Month-over-Month', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CompareColumn(
                  label: 'This Month',
                  amount: settings.formatAmount(thisMonth),
                  color: theme.colorScheme.primary,
                  progress: lastMonth > 0
                      ? (thisMonth / (thisMonth > lastMonth ? thisMonth : lastMonth))
                          .clamp(0.0, 1.0)
                      : 0.5,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CompareColumn(
                  label: 'Last Month',
                  amount: settings.formatAmount(lastMonth),
                  color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                  progress: lastMonth > 0
                      ? (lastMonth / (thisMonth > lastMonth ? thisMonth : lastMonth))
                          .clamp(0.0, 1.0)
                      : 0.5,
                ),
              ),
            ],
          ),
          if (lastMonth > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isDown ? AppTheme.income : AppTheme.expense).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDown ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                    size: 16,
                    color: isDown ? AppTheme.income : AppTheme.expense,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${change.abs().toStringAsFixed(1)}% ${isDown ? 'less' : 'more'} than last month',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDown ? AppTheme.income : AppTheme.expense,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyComparison extends StatelessWidget {
  final double thisWeek;
  final double lastWeek;
  final SettingsProvider settings;

  const _WeeklyComparison({
    required this.thisWeek,
    required this.lastWeek,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Week', style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  settings.formatAmount(thisWeek),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Container(
            width: 1, height: 36,
            color: theme.dividerColor,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last Week', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    settings.formatAmount(lastWeek),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareColumn extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final double progress;

  const _CompareColumn({
    required this.label,
    required this.amount,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          amount,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final TransactionCategory category;
  final double amount;
  final double percentage;
  final SettingsProvider settings;
  final bool isLast;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.settings,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, color: category.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.label, style: theme.textTheme.titleSmall?.copyWith(fontSize: 13)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 4,
                        backgroundColor: category.color.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation(category.color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    settings.formatAmount(amount),
                    style: theme.textTheme.titleSmall?.copyWith(fontSize: 13),
                  ),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: theme.dividerColor),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
