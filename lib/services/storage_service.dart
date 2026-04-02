import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';

class StorageService {
  static const String _transactionsBox = 'transactions';
  static const String _goalsBox = 'goals';
  static const String _settingsBox = 'settings';

  late Box<String> _txBox;
  late Box<String> _goalBox;
  late Box<dynamic> _settingsBoxInstance;

  Future<void> init() async {
    await Hive.initFlutter();
    _txBox = await Hive.openBox<String>(_transactionsBox);
    _goalBox = await Hive.openBox<String>(_goalsBox);
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
  }

  // Transactions

  Future<void> saveTransaction(Transaction tx) async {
    await _txBox.put(tx.id, jsonEncode(tx.toMap()));
  }

  Future<void> deleteTransaction(String id) async {
    await _txBox.delete(id);
  }

  List<Transaction> getAllTransactions() {
    return _txBox.values
        .map((json) => Transaction.fromMap(jsonDecode(json) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  //  Goals

  Future<void> saveGoal(SavingsGoal goal) async {
    await _goalBox.put(goal.id, jsonEncode(goal.toMap()));
  }

  Future<void> deleteGoal(String id) async {
    await _goalBox.delete(id);
  }

  List<SavingsGoal> getAllGoals() {
    return _goalBox.values
        .map((json) => SavingsGoal.fromMap(jsonDecode(json) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  // Settings

  bool get isDarkMode => _settingsBoxInstance.get('darkMode', defaultValue: false) as bool;

  Future<void> setDarkMode(bool value) async {
    await _settingsBoxInstance.put('darkMode', value);
  }

  String get currency => _settingsBoxInstance.get('currency', defaultValue: '₹') as String;

  Future<void> setCurrency(String value) async {
    await _settingsBoxInstance.put('currency', value);
  }

  String get userName => _settingsBoxInstance.get('userName', defaultValue: '') as String;

  Future<void> setUserName(String value) async {
    await _settingsBoxInstance.put('userName', value);
  }

  bool get isOnboarded => _settingsBoxInstance.get('onboarded', defaultValue: false) as bool;

  Future<void> setOnboarded(bool value) async {
    await _settingsBoxInstance.put('onboarded', value);
  }

  double get monthlyBudget =>
      (_settingsBoxInstance.get('monthlyBudget', defaultValue: 0.0) as num).toDouble();

  Future<void> setMonthlyBudget(double value) async {
    await _settingsBoxInstance.put('monthlyBudget', value);
  }
}
