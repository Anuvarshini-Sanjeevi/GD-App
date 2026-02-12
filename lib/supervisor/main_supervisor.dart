import 'package:flutter/material.dart';
import 'package:gdapp/supervisor/dashboard_page.dart';

void main() {
  runApp(const SupervisorApp());
}

class SupervisorApp extends StatelessWidget {
  const SupervisorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supervisor Dashboard',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const SupervisorDashboardPage(),
    );
  }
}
