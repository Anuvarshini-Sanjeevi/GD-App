import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gdapp/login_page.dart';
import 'package:gdapp/student/dashboard_page.dart';

bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title: 'GD App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2169E1)),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: const LoginPage(),
    );
  }
}
