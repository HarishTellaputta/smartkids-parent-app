import 'package:flutter/material.dart';

import 'features/auth/login/login_screen.dart';
import 'features/home/parent_home_screen.dart';
import 'storage/local_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ParentApp());
}

class ParentApp extends StatelessWidget {
  const ParentApp({super.key});

  static const Color primary = Color(0xff3155D9);
  static const Color textDark = Color(0xff172033);
  static const Color background = Color(0xffF6F8FC);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Smart School',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: background,

        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: textDark,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.white,

          titleTextStyle: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xffE5E9F0),
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xffE5E9F0),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: primary,
              width: 1.6,
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 3,

            minimumSize: const Size(
              double.infinity,
              52,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,

          backgroundColor: textDark,

          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: Color(0xffE8ECF3),
          thickness: 1,
        ),
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
    // Small delay gives the branded start screen time
    // to render smoothly.
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

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
    return const _PremiumStartScreen();
  }
}

// ============================================================
// PREMIUM START SCREEN
// ============================================================

class _PremiumStartScreen extends StatefulWidget {
  const _PremiumStartScreen();

  @override
  State<_PremiumStartScreen> createState() =>
      _PremiumStartScreenState();
}

class _PremiumStartScreenState
    extends State<_PremiumStartScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff2948C7),
              Color(0xff3155D9),
              Color(0xff5A78E7),
            ],
          ),
        ),

        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,

            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,

                    child: Container(
                      height: 105,
                      width: 105,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.18),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.school_rounded,
                        color: Color(0xff3155D9),
                        size: 58,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FadeTransition(
                    opacity: _fadeAnimation,

                    child: const Column(
                      children: [
                        Text(
                          'Smart School',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .3,
                          ),
                        ),

                        SizedBox(height: 7),

                        Text(
                          'MAKE LIVES BRIGHTER',
                          style: TextStyle(
                            color: Color(0xffFFE58A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          'Learning Today, Leading Tomorrow',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 42),

                  FadeTransition(
                    opacity: _fadeAnimation,

                    child: const SizedBox(
                      height: 24,
                      width: 24,

                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}