import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/goal_provider.dart';
import '../../services/seed_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          // ── Profile Section ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      settings.userName.isNotEmpty
                          ? settings.userName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.userName.isNotEmpty ? settings.userName : 'Set your name',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text('Penny Wise User', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editName(context, settings),
                  icon: const Icon(Icons.edit_rounded, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Appearance ──────────────────────────────────
          _SectionHeader(title: 'APPEARANCE'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  trailing: Switch.adaptive(
                    value: settings.isDarkMode,
                    onChanged: (_) => settings.toggleDarkMode(),
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Budget ──────────────────────────────────────
          _SectionHeader(title: 'BUDGET'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: _SettingsTile(
              icon: Icons.account_balance_rounded,
              title: 'Monthly Budget',
              subtitle: settings.monthlyBudget > 0
                  ? '${settings.currency}${settings.monthlyBudget.toStringAsFixed(0)}'
                  : 'Not set',
              onTap: () => _editBudget(context, settings),
            ),
          ),

          const SizedBox(height: 16),

          // ── Currency ────────────────────────────────────
          _SectionHeader(title: 'CURRENCY'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _CurrencyOption(label: '₹ Indian Rupee', value: '₹', settings: settings),
                const Divider(height: 0, indent: 56),
                _CurrencyOption(label: '\$ US Dollar', value: '\$', settings: settings),
                const Divider(height: 0, indent: 56),
                _CurrencyOption(label: '€ Euro', value: '€', settings: settings),
                const Divider(height: 0, indent: 56),
                _CurrencyOption(label: '£ British Pound', value: '£', settings: settings),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Data ────────────────────────────────────────
          _SectionHeader(title: 'DATA'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.download_rounded,
                  title: 'Load Sample Data',
                  subtitle: 'Add demo transactions & goals',
                  onTap: () => _loadSampleData(context),
                ),
                const Divider(height: 0, indent: 56),
                _SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  title: 'Clear All Data',
                  subtitle: 'Remove all transactions & goals',
                  titleColor: Colors.red,
                  onTap: () => _clearAllData(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── About ───────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  'Penny Wise',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0 • Made with Flutter',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _editName(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Your Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              settings.setUserName(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editBudget(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(
      text: settings.monthlyBudget > 0 ? settings.monthlyBudget.toStringAsFixed(0) : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Monthly Budget'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'Enter budget amount',
            prefixText: '${settings.currency} ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0;
              settings.setMonthlyBudget(val);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _loadSampleData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Load Sample Data'),
        content: const Text('This will add demo transactions and goals. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await context.read<TransactionProvider>().seedData(SeedData.getSampleTransactions());
              await context.read<GoalProvider>().seedData(SeedData.getSampleGoals());
              final settings = context.read<SettingsProvider>();
              if (settings.monthlyBudget == 0) {
                await settings.setMonthlyBudget(30000);
              }
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Sample data loaded!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: const Text('Load'),
          ),
        ],
      ),
    );
  }

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete all your transactions and goals. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final txProvider = context.read<TransactionProvider>();
              final goalProvider = context.read<GoalProvider>();
              for (final tx in txProvider.allTransactions) {
                await txProvider.deleteTransaction(tx.id);
              }
              for (final goal in goalProvider.goals) {
                await goalProvider.deleteGoal(goal.id);
              }
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All data cleared'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: titleColor ?? theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(color: titleColor),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: theme.textTheme.bodySmall?.color,
              ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  final String label;
  final String value;
  final SettingsProvider settings;

  const _CurrencyOption({
    required this.label,
    required this.value,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = settings.currency == value;
    return InkWell(
      onTap: () => settings.setCurrency(value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
