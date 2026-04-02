import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/enums.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.read<SettingsProvider>();
    final isExpense = transaction.type == TransactionType.expense;

    return Slidable(
      key: ValueKey(transaction.id),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          if (onEdit != null)
            CustomSlidableAction(
              onPressed: (_) => onEdit!(),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              foregroundColor: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, size: 22),
                  SizedBox(height: 4),
                  Text('Edit', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          if (onDelete != null)
            CustomSlidableAction(
              onPressed: (_) => onDelete!(),
              backgroundColor: AppTheme.expense.withOpacity(0.1),
              foregroundColor: AppTheme.expense,
              borderRadius: BorderRadius.circular(16),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, size: 22),
                  SizedBox(height: 4),
                  Text('Delete', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: transaction.category.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  transaction.category.icon,
                  color: transaction.category.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.note.isNotEmpty
                          ? transaction.note
                          : transaction.category.label,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${transaction.category.label} · ${DateFormat('dd MMM').format(transaction.date)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${isExpense ? '-' : '+'}${settings.formatAmount(transaction.amount)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isExpense ? AppTheme.expense : AppTheme.income,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
