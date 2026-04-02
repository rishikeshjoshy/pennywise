import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../models/enums.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late TransactionType _type;
  late TransactionCategory _category;
  late DateTime _date;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.transaction != null;
    _type = widget.transaction?.type ?? TransactionType.expense;
    _category = widget.transaction?.category ?? TransactionCategory.food;
    _date = widget.transaction?.date ?? DateTime.now();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _type == TransactionType.expense ? 0 : 1,
    );

    if (_isEditing) {
      _amountController.text = widget.transaction!.amount.toStringAsFixed(
        widget.transaction!.amount == widget.transaction!.amount.roundToDouble() ? 0 : 2,
      );
      _noteController.text = widget.transaction!.note;
    }

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _type = _tabController.index == 0
            ? TransactionType.expense
            : TransactionType.income;
        // Reset category when switching type
        _category = _type == TransactionType.expense
            ? TransactionCategory.food
            : TransactionCategory.salary;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories =
        _type == TransactionType.expense ? expenseCategories : incomeCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // ── Type Tabs ────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: _type == TransactionType.expense
                      ? AppTheme.expense.withOpacity(0.12)
                      : AppTheme.income.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _type == TransactionType.expense
                        ? AppTheme.expense.withOpacity(0.3)
                        : AppTheme.income.withOpacity(0.3),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                dividerHeight: 0,
                labelColor: _type == TransactionType.expense
                    ? AppTheme.expense
                    : AppTheme.income,
                unselectedLabelColor: theme.textTheme.bodySmall?.color,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Expense'),
                  Tab(text: 'Income'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Amount Input ─────────────────────────────
            Text('Amount', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: !_isEditing,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: '0',
                prefixText: '₹ ',
                prefixStyle: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter amount';
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) return 'Enter a valid amount';
                return null;
              },
            ),

            const SizedBox(height: 24),

            // ── Category ─────────────────────────────────
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withOpacity(0.12)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: cat.color.withOpacity(0.4))
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon, size: 18, color: cat.color),
                        const SizedBox(width: 8),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? cat.color
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Date ─────────────────────────────────────
            Text('Date', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(_date),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Note ─────────────────────────────────────
            Text('Note (optional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'What was this for?',
              ),
            ),

            const SizedBox(height: 36),

            // ── Save Button ──────────────────────────────
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
                child: Text(
                  _isEditing ? 'Update Transaction' : 'Add Transaction',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TransactionProvider>();
    final amount = double.parse(_amountController.text);

    if (_isEditing) {
      final updated = widget.transaction!.copyWith(
        amount: amount,
        type: _type,
        category: _category,
        date: _date,
        note: _noteController.text.trim(),
      );
      await provider.updateTransaction(updated);
    } else {
      await provider.addTransaction(
        amount: amount,
        type: _type,
        category: _category,
        date: _date,
        note: _noteController.text.trim(),
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Transaction updated' : 'Transaction added'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
