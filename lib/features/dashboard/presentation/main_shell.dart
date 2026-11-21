import 'package:flutter/material.dart';
import '../../history/presentation/history_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../statistics/presentation/statistics_screen.dart';
import 'dashboard_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  static const List<Widget> _pages = [
    DashboardScreen(), HistoryScreen(), StatisticsScreen(), SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: _index, children: _pages)),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.directions_walk), label: 'الرئيسية'),
        NavigationDestination(icon: Icon(Icons.calendar_month), label: 'السجل'),
        NavigationDestination(icon: Icon(Icons.insights), label: 'الإحصائيات'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
      ],
    ),
  );
}
