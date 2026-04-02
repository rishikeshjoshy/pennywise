class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final DateTime createdAt;
  final String emoji;
  final bool isCompleted;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.deadline,
    DateTime? createdAt,
    this.emoji = '🎯',
    this.isCompleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress => targetAmount > 0
      ? (savedAmount / targetAmount).clamp(0.0, 1.0)
      : 0.0;

  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  double get dailyTarget {
    final days = daysRemaining;
    if (days <= 0) return 0;
    final remaining = targetAmount - savedAmount;
    return remaining > 0 ? remaining / days : 0;
  }

  bool get isOverdue => DateTime.now().isAfter(deadline) && !isCompleted;

  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    String? emoji,
    bool? isCompleted,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt,
      emoji: emoji ?? this.emoji,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'deadline': deadline.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'emoji': emoji,
      'isCompleted': isCompleted,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] as String,
      title: map['title'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      savedAmount: (map['savedAmount'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      emoji: map['emoji'] as String? ?? '🎯',
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}

class NoSpendChallenge {
  final String id;
  final int targetDays;
  final DateTime startDate;
  final List<DateTime> successDays;
  final List<DateTime> failDays;
  final bool isActive;

  NoSpendChallenge({
    required this.id,
    required this.targetDays,
    required this.startDate,
    this.successDays = const [],
    this.failDays = const [],
    this.isActive = true,
  });

  int get currentStreak {
    if (successDays.isEmpty) return 0;
    final sorted = List<DateTime>.from(successDays)
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime check = DateTime.now();
    for (final day in sorted) {
      if (_isSameDay(day, check) || _isSameDay(day, check.subtract(const Duration(days: 1)))) {
        streak++;
        check = day;
      } else {
        break;
      }
    }
    return streak;
  }

  int get totalDaysElapsed => DateTime.now().difference(startDate).inDays + 1;

  double get completionRate =>
      totalDaysElapsed > 0 ? successDays.length / totalDaysElapsed : 0;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetDays': targetDays,
      'startDate': startDate.toIso8601String(),
      'successDays': successDays.map((d) => d.toIso8601String()).toList(),
      'failDays': failDays.map((d) => d.toIso8601String()).toList(),
      'isActive': isActive,
    };
  }

  factory NoSpendChallenge.fromMap(Map<String, dynamic> map) {
    return NoSpendChallenge(
      id: map['id'] as String,
      targetDays: map['targetDays'] as int,
      startDate: DateTime.parse(map['startDate'] as String),
      successDays: (map['successDays'] as List<dynamic>?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          [],
      failDays: (map['failDays'] as List<dynamic>?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          [],
      isActive: map['isActive'] as bool? ?? true,
    );
  }
}
