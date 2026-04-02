import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/charts.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import '../../models/enums.dart';
import '../transactions/add_edit_transaction_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txProvider = context.watch<TransactionProvider>();
    final goalProvider = context.watch<GoalProvider>();
    final settings = context.watch<SettingsProvider>();

    final greeting = _getGreeting();
    final name = settings.userName.isNotEmpty ? settings.userName : 'there';

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting,',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Balance Card ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D7C66), Color(0xFF14A88A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Total Balance',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      settings.formatAmountFull(txProvider.balance),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _BalanceStat(
                          label: 'Income',
                          amount: settings.formatAmount(txProvider.thisMonthIncome),
                          icon: Icons.arrow_downward_rounded,
                          iconColor: AppTheme.income,
                        ),
                        const SizedBox(width: 24),
                        _BalanceStat(
                          label: 'Expenses',
                          amount: settings.formatAmount(txProvider.thisMonthExpenses),
                          icon: Icons.arrow_upward_rounded,
                          iconColor: AppTheme.expense,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Budget Progress ─────────────────────────────────
          if (settings.monthlyBudget > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _BudgetProgress(
                  spent: txProvider.thisMonthExpenses,
                  budget: settings.monthlyBudget,
                  currency: settings.currency,
                ),
              ),
            ),

          // ── Quick Stats Grid ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      label: 'This month',
                      value: settings.formatAmount(txProvider.thisMonthExpenses),
                      icon: Icons.calendar_today_rounded,
                      color: AppTheme.expense,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      label: 'Savings goal',
                      value: '${(goalProvider.overallProgress * 100).toStringAsFixed(0)}%',
                      icon: Icons.savings_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Weekly Spending Chart ───────────────────────────
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
                    Row(
                      children: [
                        Text(
                          'This Week',
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _weekChangeColor(txProvider).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _weekChangeText(txProvider),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _weekChangeColor(txProvider),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    WeeklySpendingChart(
                      data: txProvider.dailyExpensesLast7Days,
                      currency: settings.currency,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Recent Transactions ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Text('Recent Activity', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Switch to transactions tab - handled by parent
                    },
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (txProvider.allTransactions.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.receipt_long_rounded,
                title: 'No transactions yet',
                subtitle: 'Tap + to add your first transaction',
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tx = txProvider.allTransactions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TransactionTile(
                      transaction: tx,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddEditTransactionScreen(transaction: tx),
                        ),
                      ),
                    ),
                  );
                },
                childCount: txProvider.allTransactions.length.clamp(0, 5),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Color _weekChangeColor(TransactionProvider provider) {
    final thisWeek = provider.thisWeekExpenses;
    final lastWeek = provider.lastWeekExpenses;
    if (lastWeek == 0) return AppTheme.primary;
    return thisWeek <= lastWeek ? AppTheme.income : AppTheme.expense;
  }

  String _weekChangeText(TransactionProvider provider) {
    final thisWeek = provider.thisWeekExpenses;
    final lastWeek = provider.lastWeekExpenses;
    if (lastWeek == 0) return 'New week';
    final pct = ((thisWeek - lastWeek) / lastWeek * 100).abs();
    if (thisWeek <= lastWeek) {
      return '↓ ${pct.toStringAsFixed(0)}%';
    }
    return '↑ ${pct.toStringAsFixed(0)}%';
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color iconColor;

  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  final double spent;
  final double budget;
  final String currency;

  const _BudgetProgress({
    required this.spent,
    required this.budget,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = spent > budget;
    final color = isOver
        ? AppTheme.expense
        : progress > 0.8
            ? AppTheme.warning
            : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOver ? Icons.warning_rounded : Icons.account_balance_rounded,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text('Monthly Budget', style: theme.textTheme.titleSmall),
              const Spacer(),
              Text(
                '$currency${spent.toStringAsFixed(0)} / $currency${budget.toStringAsFixed(0)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isOver
                ? 'Over budget by $currency${(spent - budget).toStringAsFixed(0)}'
                : '$currency${(budget - spent).toStringAsFixed(0)} remaining',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
