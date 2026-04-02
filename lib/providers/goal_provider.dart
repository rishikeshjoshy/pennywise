import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/goal_model.dart';
import '../services/storage_service.dart';

class GoalProvider extends ChangeNotifier {
  final StorageService _storage;
  List<SavingsGoal> _goals = [];

  GoalProvider(this._storage) {
    _loadGoals();
  }

  List<SavingsGoal> get goals => List.unmodifiable(_goals);

  List<SavingsGoal> get activeGoals =>
      _goals.where((g) => !g.isCompleted).toList();

  List<SavingsGoal> get completedGoals =>
      _goals.where((g) => g.isCompleted).toList();

  double get totalSaved =>
      _goals.fold(0.0, (sum, g) => sum + g.savedAmount);

  double get totalTargeted =>
      _goals.fold(0.0, (sum, g) => sum + g.targetAmount);

  double get overallProgress =>
      totalTargeted > 0 ? (totalSaved / totalTargeted).clamp(0.0, 1.0) : 0.0;

  void _loadGoals() {
    _goals = _storage.getAllGoals();
    notifyListeners();
  }

  Future<void> addGoal({
    required String title,
    required double targetAmount,
    required DateTime deadline,
    String emoji = '🎯',
  }) async {
    final goal = SavingsGoal(
      id: const Uuid().v4(),
      title: title,
      targetAmount: targetAmount,
      deadline: deadline,
      emoji: emoji,
    );
    await _storage.saveGoal(goal);
    _goals.add(goal);
    _goals.sort((a, b) => a.deadline.compareTo(b.deadline));
    notifyListeners();
  }

  Future<void> addToGoal(String goalId, double amount) async {
    final idx = _goals.indexWhere((g) => g.id == goalId);
    if (idx < 0) return;

    final goal = _goals[idx];
    final newSaved = (goal.savedAmount + amount).clamp(0.0, goal.targetAmount);
    final updated = goal.copyWith(
      savedAmount: newSaved,
      isCompleted: newSaved >= goal.targetAmount,
    );
    await _storage.saveGoal(updated);
    _goals[idx] = updated;
    notifyListeners();
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    await _storage.saveGoal(goal);
    final idx = _goals.indexWhere((g) => g.id == goal.id);
    if (idx >= 0) _goals[idx] = goal;
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await _storage.deleteGoal(id);
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  Future<void> seedData(List<SavingsGoal> goals) async {
    for (final goal in goals) {
      await _storage.saveGoal(goal);
    }
    _goals = _storage.getAllGoals();
    notifyListeners();
  }
}
