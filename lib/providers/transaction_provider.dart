import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

class TransactionProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Transaction> _transactions = [];
  String _searchQuery = '';
  TransactionType? _filterType;
  TransactionCategory? _filterCategory;

  TransactionProvider(this._storage) {
    _loadTransactions();
  }

  // ── Getters ────────────────────────────────────────────────

  List<Transaction> get transactions => _filteredTransactions;

  List<Transaction> get allTransactions => List.unmodifiable(_transactions);

  String get searchQuery => _searchQuery;
  TransactionType? get filterType => _filterType;
  TransactionCategory? get filterCategory => _filterCategory;

  List<Transaction> get _filteredTransactions {
    var list = List<Transaction>.from(_transactions);

    if (_filterType != null) {
      list = list.where((t) => t.type == _filterType).toList();
    }
    if (_filterCategory != null) {
      list = list.where((t) => t.category == _filterCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) =>
          t.note.toLowerCase().contains(q) ||
          t.category.label.toLowerCase().contains(q) ||
          t.amount.toString().contains(q)).toList();
    }

    return list;
  }

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  double get thisMonthIncome => _thisMonth
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get thisMonthExpenses => _thisMonth
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get lastMonthExpenses => _lastMonth
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  List<Transaction> get _thisMonth {
    final now = DateTime.now();
    return _transactions.where((t) =>
        t.date.year == now.year && t.date.month == now.month).toList();
  }

  List<Transaction> get _lastMonth {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month - 1);
    return _transactions.where((t) =>
        t.date.year == last.year && t.date.month == last.month).toList();
  }

  List<Transaction> get thisWeekTransactions {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _transactions.where((t) => t.date.isAfter(start) || _isSameDay(t.date, start)).toList();
  }

  List<Transaction> get lastWeekTransactions {
    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfThisWeek.year, startOfThisWeek.month, startOfThisWeek.day);
    final startOfLastWeek = start.subtract(const Duration(days: 7));
    return _transactions.where((t) =>
        (t.date.isAfter(startOfLastWeek) || _isSameDay(t.date, startOfLastWeek)) &&
        t.date.isBefore(start)).toList();
  }

  double get thisWeekExpenses => thisWeekTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get lastWeekExpenses => lastWeekTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  Map<TransactionCategory, double> get expensesByCategory {
    final map = <TransactionCategory, double>{};
    for (final t in _thisMonth.where((t) => t.type == TransactionType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  /// Returns daily expenses for the last 7 days
  List<MapEntry<DateTime, double>> get dailyExpensesLast7Days {
    final now = DateTime.now();
    final result = <MapEntry<DateTime, double>>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final total = _transactions
          .where((t) =>
              t.type == TransactionType.expense && _isSameDay(t.date, day))
          .fold(0.0, (sum, t) => sum + t.amount);
      result.add(MapEntry(day, total));
    }
    return result;
  }

  TransactionCategory? get topCategory {
    final cats = expensesByCategory;
    return cats.isNotEmpty ? cats.keys.first : null;
  }

  int get totalTransactionCount => _transactions.length;

  double get avgDailyExpense {
    if (_thisMonth.isEmpty) return 0;
    final now = DateTime.now();
    final daysInMonth = now.day;
    return thisMonthExpenses / daysInMonth;
  }

  // ── Actions ────────────────────────────────────────────────

  void _loadTransactions() {
    _transactions = _storage.getAllTransactions();
    notifyListeners();
  }

  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    required TransactionCategory category,
    required DateTime date,
    String note = '',
  }) async {
    final tx = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );
    await _storage.saveTransaction(tx);
    _transactions.insert(0, tx);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction tx) async {
    await _storage.saveTransaction(tx);
    final idx = _transactions.indexWhere((t) => t.id == tx.id);
    if (idx >= 0) {
      _transactions[idx] = tx;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    }
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _storage.deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(TransactionType? type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterCategory(TransactionCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = null;
    _filterCategory = null;
    notifyListeners();
  }

  Future<void> seedData(List<Transaction> transactions) async {
    for (final tx in transactions) {
      await _storage.saveTransaction(tx);
    }
    _transactions = _storage.getAllTransactions();
    notifyListeners();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
