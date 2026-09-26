
import 'package:flutter/material.dart';

import 'features/auth/login/login_screen.dart';
import 'features/home/parent_home_screen.dart';
import 'storage/local_storage.dart';

void main() {
  runApp(const ParentApp());
}

class ParentApp extends StatelessWidget {
  const ParentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: "Smart School",

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: const AppStartScreen(),
    );
  }
}

// ============================================================
// APP START SCREEN
// ============================================================

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final isLoggedIn = await LocalStorage.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ParentHomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

