import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';
import '../models/enums.dart';

/// PROVIDING READY MADE DATA FOR EASY TESTING AND EXPLORING THE APP

class SeedData {
  static const _uuid = Uuid();

  static List<Transaction> getSampleTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: _uuid.v4(),
        amount: 50000,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: DateTime(now.year, now.month, 1),
        note: 'Monthly salary',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 450,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(days: 1)),
        note: 'Lunch at office canteen',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 2500,
        type: TransactionType.expense,
        category: TransactionCategory.transport,
        date: now.subtract(const Duration(days: 1)),
        note: 'Uber to client meeting',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 1200,
        type: TransactionType.expense,
        category: TransactionCategory.entertainment,
        date: now.subtract(const Duration(days: 2)),
        note: 'Movie tickets',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 3500,
        type: TransactionType.expense,
        category: TransactionCategory.shopping,
        date: now.subtract(const Duration(days: 3)),
        note: 'New headphones',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 800,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(days: 3)),
        note: 'Groceries',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 5000,
        type: TransactionType.expense,
        category: TransactionCategory.bills,
        date: now.subtract(const Duration(days: 5)),
        note: 'Electricity bill',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 15000,
        type: TransactionType.income,
        category: TransactionCategory.freelance,
        date: now.subtract(const Duration(days: 5)),
        note: 'Website project payment',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 600,
        type: TransactionType.expense,
        category: TransactionCategory.health,
        date: now.subtract(const Duration(days: 6)),
        note: 'Pharmacy',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 2000,
        type: TransactionType.expense,
        category: TransactionCategory.education,
        date: now.subtract(const Duration(days: 7)),
        note: 'Online course subscription',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 350,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(days: 8)),
        note: 'Coffee & snacks',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 4500,
        type: TransactionType.expense,
        category: TransactionCategory.shopping,
        date: now.subtract(const Duration(days: 10)),
        note: 'Clothes shopping',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 1500,
        type: TransactionType.expense,
        category: TransactionCategory.transport,
        date: now.subtract(const Duration(days: 12)),
        note: 'Metro pass renewal',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 8000,
        type: TransactionType.expense,
        category: TransactionCategory.bills,
        date: now.subtract(const Duration(days: 15)),
        note: 'Internet + phone bill',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 700,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(days: 18)),
        note: 'Dinner with friends',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 50000,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: DateTime(now.year, now.month - 1, 1),
        note: 'Last month salary',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 3000,
        type: TransactionType.expense,
        category: TransactionCategory.entertainment,
        date: now.subtract(const Duration(days: 20)),
        note: 'Concert tickets',
      ),
      Transaction(
        id: _uuid.v4(),
        amount: 5000,
        type: TransactionType.income,
        category: TransactionCategory.investment,
        date: now.subtract(const Duration(days: 22)),
        note: 'Dividend payout',
      ),
    ];
  }

  static List<SavingsGoal> getSampleGoals() {
    final now = DateTime.now();
    return [
      SavingsGoal(
        id: _uuid.v4(),
        title: 'Emergency Fund',
        targetAmount: 100000,
        savedAmount: 45000,
        deadline: DateTime(now.year, now.month + 4, 1),
        emoji: '🛡️',
      ),
      SavingsGoal(
        id: _uuid.v4(),
        title: 'New MacBook',
        targetAmount: 150000,
        savedAmount: 72000,
        deadline: DateTime(now.year, now.month + 6, 1),
        emoji: '💻',
      ),
      SavingsGoal(
        id: _uuid.v4(),
        title: 'Goa Trip',
        targetAmount: 25000,
        savedAmount: 18000,
        deadline: DateTime(now.year, now.month + 2, 15),
        emoji: '🏖️',
      ),
    ];
  }
}
