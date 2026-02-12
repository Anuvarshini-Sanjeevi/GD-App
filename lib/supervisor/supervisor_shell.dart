import 'package:flutter/material.dart';
import 'package:gdapp/supervisor/dashboard_page.dart';
import 'package:gdapp/supervisor/sessions_page.dart';
import 'package:gdapp/supervisor/reports_page.dart';
import 'package:gdapp/supervisor/supervisor_bottom_nav.dart';
import 'package:gdapp/supervisor/table_monitor_page.dart';
import 'package:gdapp/supervisor/supervisor_profile_page.dart';

class SupervisorShell extends StatefulWidget {
  const SupervisorShell({Key? key}) : super(key: key);

  @override
  State<SupervisorShell> createState() => _SupervisorShellState();
}

class _SupervisorShellState extends State<SupervisorShell> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _handleBack() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const SupervisorDashboardPage(),
      SessionsPage(onBack: _handleBack),
      ReportsPage(onBack: _handleBack),
      SupervisorProfilePage(onBack: _handleBack),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_currentIndex != 0) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: SupervisorBottomNav(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}
