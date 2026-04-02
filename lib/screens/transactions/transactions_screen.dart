import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/enums.dart';
import '../../models/transaction_model.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txProvider = context.watch<TransactionProvider>();
    final settings = context.read<SettingsProvider>();
    final transactions = txProvider.transactions;

    // Group by date
    final grouped = <String, List<Transaction>>{};
    for (final tx in transactions) {
      final key = _dateGroupKey(tx.date);
      grouped.putIfAbsent(key, () => []).add(tx);
    }

    return SafeArea(
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text('Transactions', style: theme.textTheme.headlineMedium),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        _searchController.clear();
                        txProvider.clearFilters();
                      }
                    });
                  },
                  icon: Icon(
                    _showSearch ? Icons.close_rounded : Icons.search_rounded,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // ── Search Bar ──────────────────────────────────
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: txProvider.setSearchQuery,
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                ),
              ),
            ),

          // ── Filter Chips ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: txProvider.filterType == null,
                    onTap: () => txProvider.setFilterType(null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Income',
                    selected: txProvider.filterType == TransactionType.income,
                    onTap: () => txProvider.setFilterType(
                      txProvider.filterType == TransactionType.income
                          ? null
                          : TransactionType.income,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Expense',
                    selected: txProvider.filterType == TransactionType.expense,
                    onTap: () => txProvider.setFilterType(
                      txProvider.filterType == TransactionType.expense
                          ? null
                          : TransactionType.expense,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ..._buildCategoryChips(txProvider),
                ],
              ),
            ),
          ),

          // ── Transaction List ────────────────────────────
          Expanded(
            child: transactions.isEmpty
                ? EmptyState(
                    icon: _showSearch
                        ? Icons.search_off_rounded
                        : Icons.receipt_long_rounded,
                    title: _showSearch ? 'No results found' : 'No transactions yet',
                    subtitle: _showSearch
                        ? 'Try a different search term'
                        : 'Add your first transaction with the + button',
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final dateKey = grouped.keys.elementAt(index);
                      final items = grouped[dateKey]!;
                      final dayTotal = items.fold(0.0, (sum, tx) =>
                          sum + (tx.type == TransactionType.expense ? -tx.amount : tx.amount));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                            child: Row(
                              children: [
                                Text(
                                  dateKey,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${dayTotal >= 0 ? '+' : ''}${settings.formatAmount(dayTotal)}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: dayTotal >= 0
                                        ? const Color(0xFF06D6A0)
                                        : const Color(0xFFEF476F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...items.map((tx) => TransactionTile(
                                transaction: tx,
                                onTap: () => _editTransaction(tx),
                                onEdit: () => _editTransaction(tx),
                                onDelete: () => _deleteTransaction(tx),
                              )),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryChips(TransactionProvider provider) {
    final categories = provider.filterType == TransactionType.income
        ? incomeCategories
        : provider.filterType == TransactionType.expense
            ? expenseCategories
            : TransactionCategory.values;

    return categories.map((cat) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: _FilterChip(
          label: cat.label,
          selected: provider.filterCategory == cat,
          onTap: () => provider.setFilterCategory(
            provider.filterCategory == cat ? null : cat,
          ),
        ),
      );
    }).toList();
  }

  String _dateGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(date.year, date.month, date.day);

    if (txDay == today) return 'TODAY';
    if (txDay == today.subtract(const Duration(days: 1))) return 'YESTERDAY';
    if (date.year == now.year) return DateFormat('dd MMM').format(date).toUpperCase();
    return DateFormat('dd MMM yyyy').format(date).toUpperCase();
  }

  void _editTransaction(Transaction tx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(transaction: tx),
      ),
    );
  }

  void _deleteTransaction(Transaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TransactionProvider>().deleteTransaction(tx.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Transaction deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF476F),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.12)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? theme.colorScheme.primary
                : theme.textTheme.bodySmall?.color,
          ),
        ),
      ),
    );
  }
}
