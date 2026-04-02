import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/goal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../models/goal_model.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalProvider = context.watch<GoalProvider>();
    final settings = context.watch<SettingsProvider>();

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('Savings Goals', style: theme.textTheme.headlineMedium),
                  const Spacer(),
                  _AddGoalButton(onPressed: () => _showAddGoalSheet(context)),
                ],
              ),
            ),
          ),

          // ── Overall Progress ────────────────────────────
          if (goalProvider.goals.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _OverallProgress(
                  saved: goalProvider.totalSaved,
                  target: goalProvider.totalTargeted,
                  progress: goalProvider.overallProgress,
                  settings: settings,
                ),
              ),
            ),

          // ── Active Goals ────────────────────────────────
          if (goalProvider.activeGoals.isEmpty && goalProvider.completedGoals.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.flag_rounded,
                title: 'No goals yet',
                subtitle: 'Set a savings goal to start tracking\nyour progress toward something meaningful',
              ),
            )
          else ...[
            if (goalProvider.activeGoals.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'ACTIVE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final goal = goalProvider.activeGoals[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _GoalCard(
                        goal: goal,
                        settings: settings,
                        onAddMoney: () => _showAddMoneySheet(context, goal),
                        onDelete: () => _confirmDeleteGoal(context, goal),
                      ),
                    );
                  },
                  childCount: goalProvider.activeGoals.length,
                ),
              ),
            ],

            // ── Completed Goals ─────────────────────────────
            if (goalProvider.completedGoals.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Text(
                    'COMPLETED 🎉',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final goal = goalProvider.completedGoals[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _GoalCard(
                        goal: goal,
                        settings: settings,
                        onDelete: () => _confirmDeleteGoal(context, goal),
                      ),
                    );
                  },
                  childCount: goalProvider.completedGoals.length,
                ),
              ),
            ],
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AddGoalSheet(),
    );
  }

  void _showAddMoneySheet(BuildContext context, SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddMoneySheet(goal: goal),
    );
  }

  void _confirmDeleteGoal(BuildContext context, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Goal'),
        content: Text('Delete "${goal.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GoalProvider>().deleteGoal(goal.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AddGoalButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddGoalButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'New Goal',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverallProgress extends StatelessWidget {
  final double saved;
  final double target;
  final double progress;
  final SettingsProvider settings;

  const _OverallProgress({
    required this.saved,
    required this.target,
    required this.progress,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.08),
            theme.colorScheme.primary.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Savings',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${settings.formatAmount(saved)} of ${settings.formatAmount(target)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final SettingsProvider settings;
  final VoidCallback? onAddMoney;
  final VoidCallback? onDelete;

  const _GoalCard({
    required this.goal,
    required this.settings,
    this.onAddMoney,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = goal.isCompleted
        ? AppTheme.income
        : goal.isOverdue
            ? AppTheme.expense
            : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: goal.isCompleted
            ? Border.all(color: AppTheme.income.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      goal.isCompleted
                          ? 'Goal reached!'
                          : goal.isOverdue
                              ? 'Overdue'
                              : '${goal.daysRemaining} days left',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: goal.isCompleted
                            ? AppTheme.income
                            : goal.isOverdue
                                ? AppTheme.expense
                                : null,
                        fontWeight: goal.isCompleted || goal.isOverdue
                            ? FontWeight.w600
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                settings.formatAmount(goal.savedAmount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                ' / ${settings.formatAmount(goal.targetAmount)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          if (!goal.isCompleted && goal.dailyTarget > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  'Save ${settings.formatAmount(goal.dailyTarget)}/day to reach your goal',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
          if (!goal.isCompleted && onAddMoney != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onAddMoney,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Add Money',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Add Goal Bottom Sheet ──────────────────────────────────

class _AddGoalSheet extends StatefulWidget {
  const _AddGoalSheet();

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _deadline = DateTime.now().add(const Duration(days: 90));
  String _emoji = '🎯';

  final _emojis = ['🎯', '🛡️', '💻', '🏖️', '🚗', '🏠', '📚', '💰', '🎮', '👕', '💍', '🎓'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('New Savings Goal', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),

            // Emoji picker
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _emojis.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final e = _emojis[i];
                  final isSelected = e == _emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.12)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: theme.colorScheme.primary.withOpacity(0.4))
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Goal name'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(hintText: 'Target amount (₹)', prefixText: '₹ '),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter target amount';
                final amt = double.tryParse(v);
                if (amt == null || amt <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Deadline: ${DateFormat('dd MMM yyyy').format(_deadline)}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Create Goal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<GoalProvider>().addGoal(
          title: _titleController.text.trim(),
          targetAmount: double.parse(_amountController.text),
          deadline: _deadline,
          emoji: _emoji,
        );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Goal created!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

// ── Add Money Bottom Sheet ─────────────────────────────────

class _AddMoneySheet extends StatefulWidget {
  final SavingsGoal goal;
  const _AddMoneySheet({required this.goal});

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = widget.goal.targetAmount - widget.goal.savedAmount;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add to "${widget.goal.title}"',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              '₹${remaining.toStringAsFixed(0)} remaining to reach your goal',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                hintText: '0',
                prefixText: '₹ ',
                prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter amount';
                final amt = double.tryParse(v);
                if (amt == null || amt <= 0) return 'Enter a valid amount';
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Quick amount buttons
            Wrap(
              spacing: 8,
              children: [500, 1000, 2000, 5000].map((amt) {
                return ActionChip(
                  label: Text('₹$amt'),
                  onPressed: () {
                    _amountController.text = amt.toString();
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final amount = double.parse(_amountController.text);
                  await context.read<GoalProvider>().addToGoal(widget.goal.id, amount);
                  if (mounted) {
                    Navigator.pop(context);
                    final newSaved = widget.goal.savedAmount + amount;
                    if (newSaved >= widget.goal.targetAmount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('🎉 Goal completed! Congratulations!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                          backgroundColor: AppTheme.income,
                        ),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Add Money',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
