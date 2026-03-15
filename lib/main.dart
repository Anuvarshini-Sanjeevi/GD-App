import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gdapp/login_page.dart';
import 'package:gdapp/student/dashboard_page.dart';
import 'package:gdapp/supervisor/supervisor_shell.dart';
import 'package:gdapp/supervisor/main_supervisor.dart';
import 'package:flutter/foundation.dart';

bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      // On Web, Firebase.initializeApp() requires options to be present in index.html
      // or passed as an argument. If not found, it throws.
      await Firebase.initializeApp();
    } else {
      await Firebase.initializeApp();
    }
    isFirebaseInitialized = true;
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Firebase initialization failed (likely missing configuration): $e");
    // We continue execution so the app can still boot
    isFirebaseInitialized = false;
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GD App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2169E1)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
