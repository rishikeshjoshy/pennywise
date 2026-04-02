import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'transactions/transactions_screen.dart';
import 'goals/goals_screen.dart';
import 'insights/insights_screen.dart';
import 'transactions/add_edit_transaction_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    TransactionsScreen(),
    SizedBox(), // Placeholder for FAB
    GoalsScreen(),
    InsightsScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // FAB action - add transaction
      _showAddTransaction();
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _showAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddEditTransactionScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex >= 2 ? _currentIndex : _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(), // Hidden - FAB replaces it
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_rounded),
              activeIcon: Icon(Icons.flag_rounded),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_rounded),
              activeIcon: Icon(Icons.insights_rounded),
              label: 'Insights',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransaction,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
