import 'package:flutter/material.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  food,
  transport,
  shopping,
  entertainment,
  bills,
  health,
  education,
  salary,
  freelance,
  investment,
  gift,
  other,
}

extension TransactionCategoryX on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.food:
        return 'Food & Dining';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.bills:
        return 'Bills & Utilities';
      case TransactionCategory.health:
        return 'Health';
      case TransactionCategory.education:
        return 'Education';
      case TransactionCategory.salary:
        return 'Salary';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investment:
        return 'Investment';
      case TransactionCategory.gift:
        return 'Gift';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant_rounded;
      case TransactionCategory.transport:
        return Icons.directions_car_rounded;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_rounded;
      case TransactionCategory.entertainment:
        return Icons.movie_rounded;
      case TransactionCategory.bills:
        return Icons.receipt_long_rounded;
      case TransactionCategory.health:
        return Icons.favorite_rounded;
      case TransactionCategory.education:
        return Icons.school_rounded;
      case TransactionCategory.salary:
        return Icons.account_balance_rounded;
      case TransactionCategory.freelance:
        return Icons.laptop_mac_rounded;
      case TransactionCategory.investment:
        return Icons.trending_up_rounded;
      case TransactionCategory.gift:
        return Icons.card_giftcard_rounded;
      case TransactionCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.food:
        return const Color(0xFFFF6B6B);
      case TransactionCategory.transport:
        return const Color(0xFF4ECDC4);
      case TransactionCategory.shopping:
        return const Color(0xFFFFBE0B);
      case TransactionCategory.entertainment:
        return const Color(0xFFFF006E);
      case TransactionCategory.bills:
        return const Color(0xFF8338EC);
      case TransactionCategory.health:
        return const Color(0xFFFF595E);
      case TransactionCategory.education:
        return const Color(0xFF1982C4);
      case TransactionCategory.salary:
        return const Color(0xFF06D6A0);
      case TransactionCategory.freelance:
        return const Color(0xFF118AB2);
      case TransactionCategory.investment:
        return const Color(0xFF073B4C);
      case TransactionCategory.gift:
        return const Color(0xFFEF476F);
      case TransactionCategory.other:
        return const Color(0xFF6C757D);
    }
  }
}

List<TransactionCategory> get expenseCategories => [
      TransactionCategory.food,
      TransactionCategory.transport,
      TransactionCategory.shopping,
      TransactionCategory.entertainment,
      TransactionCategory.bills,
      TransactionCategory.health,
      TransactionCategory.education,
      TransactionCategory.other,
    ];

List<TransactionCategory> get incomeCategories => [
      TransactionCategory.salary,
      TransactionCategory.freelance,
      TransactionCategory.investment,
      TransactionCategory.gift,
      TransactionCategory.other,
    ];
