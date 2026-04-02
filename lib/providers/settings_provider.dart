import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  SettingsProvider(this._storage);

  bool get isDarkMode => _storage.isDarkMode;
  String get currency => _storage.currency;
  String get userName => _storage.userName;
  bool get isOnboarded => _storage.isOnboarded;
  double get monthlyBudget => _storage.monthlyBudget;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleDarkMode() async {
    await _storage.setDarkMode(!isDarkMode);
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    await _storage.setCurrency(value);
    notifyListeners();
  }

  Future<void> setUserName(String value) async {
    await _storage.setUserName(value);
    notifyListeners();
  }

  Future<void> setOnboarded() async {
    await _storage.setOnboarded(true);
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double value) async {
    await _storage.setMonthlyBudget(value);
    notifyListeners();
  }

  String formatAmount(double amount) {
    if (amount >= 100000) {
      return '$currency${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$currency${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}';
  }

  String formatAmountFull(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    // Indian number formatting
    if (intPart.length <= 3) {
      return '$currency$intPart${decPart == '00' ? '' : '.$decPart'}';
    }
    final last3 = intPart.substring(intPart.length - 3);
    var remaining = intPart.substring(0, intPart.length - 3);
    var formatted = '';
    while (remaining.length > 2) {
      formatted = ',${remaining.substring(remaining.length - 2)}$formatted';
      remaining = remaining.substring(0, remaining.length - 2);
    }
    formatted = '$remaining$formatted,$last3';
    return '$currency$formatted${decPart == '00' ? '' : '.$decPart'}';
  }
}
