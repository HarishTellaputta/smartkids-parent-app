import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:parent_app/features/home/parent_home_screen.dart';
import 'package:parent_app/services/api_service.dart';
import 'package:parent_app/storage/local_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty) {
      _showMessage("Please enter your username");
      return;
    }

    if (password.isEmpty) {
      _showMessage("Please enter your password");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.post(
        '/auth/login',
        body: {'username': username, 'password': password},
      );

      if (!mounted) return;

      final data = ApiService.decodeResponse(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data is Map<String, dynamic>) {
          final token = data['token']?.toString();
          final userId = data['userId'];
          final responseUsername = data['username']?.toString() ?? username;
          final role = data['role']?.toString();

          if (token == null ||
              token.isEmpty ||
              userId == null ||
              role == null ||
              role.isEmpty) {
            _showMessage("Invalid login response from server");

            setState(() {
              isLoading = false;
            });

            return;
          }

          await LocalStorage.saveLoginData(
            token: token,
            userId: userId is int ? userId : int.parse(userId.toString()),
            username: responseUsername,
            role: role,
          );

          debugPrint("========== LOGIN DEBUG ==========");
          debugPrint("USERNAME : $responseUsername");
          debugPrint("USER ID  : $userId");
          debugPrint("ROLE     : $role");
          debugPrint("TOKEN    : $token");
          debugPrint("=================================");

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ParentHomeScreen()),
            (route) => false,
          );

          return;
        }

        _showMessage("Invalid response from server");
      } else {
        String message = "Invalid username or password";

        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }

        _showMessage(message);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage("Unable to connect to server. Please try again.");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF5F8FC),

      body: SafeArea(
        child: Column(
          children: [
            // ============================================================
            // HEADER
            // ============================================================

            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,

              width: double.infinity,

              padding: EdgeInsets.only(
                top: keyboardOpen ? 12 : 35,
                bottom: keyboardOpen ? 16 : 45,
              ),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(45),
                  bottomRight: Radius.circular(45),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ========================================================
                  // SCHOOL ICON
                  // ========================================================

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,

                    height: keyboardOpen ? 65 : 110,
                    width: keyboardOpen ? 65 : 110,

                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),

                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),

                      child: Icon(
                        Icons.school_rounded,
                        key: ValueKey(keyboardOpen),
                        color: const Color(0xff1565C0),
                        size: keyboardOpen ? 36 : 60,
                      ),
                    ),
                  ),

                  SizedBox(height: keyboardOpen ? 8 : 20),

                  // ========================================================
                  // SMART SCHOOL
                  // ========================================================
                  Text(
                    "Smart School",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: keyboardOpen ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: keyboardOpen ? 0.5 : 1,
                    ),
                  ),

                  // ========================================================
                  // TAGLINE
                  // ========================================================
                  Text(
                    "Make Lives Brighter",
                    style: GoogleFonts.poppins(
                      color: Colors.yellow.shade200,
                      fontSize: keyboardOpen ? 12 : 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: keyboardOpen ? 2.5 : 5,
                    ),
                  ),

                  SizedBox(height: keyboardOpen ? 3 : 10),

                  // ========================================================
                  // SUBTITLE
                  // ========================================================
                  Text(
                    "Learning Today, Leading Tomorrow",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: keyboardOpen ? 10 : 15,
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // LOGIN AREA
            // ============================================================
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  keyboardOpen ? 12 : 24,
                  20,
                  keyboardOpen ? 8 : 20,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ======================================================
                    // WELCOME
                    // ======================================================

                    Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        fontSize: keyboardOpen ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff172033),
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 3 : 8),

                    Text(
                      "Login with your username and password.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: keyboardOpen ? 13 : 16,
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 10 : 24),

                    // ======================================================
                    // USERNAME
                    // ======================================================
                    const Text(
                      "Username",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff172033),
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 6 : 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: TextField(
                        controller: usernameController,

                        keyboardType: TextInputType.text,

                        textInputAction: TextInputAction.next,

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff172033),
                        ),

                        decoration: InputDecoration(
                          hintText: "Enter username",

                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),

                          filled: true,
                          fillColor: Colors.white,

                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xff1565C0),
                          ),

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),

                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1.2,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),

                            borderSide: const BorderSide(
                              color: Color(0xff1565C0),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 10 : 16),

                    // ======================================================
                    // PASSWORD
                    // ======================================================
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff172033),
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 6 : 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: TextField(
                        controller: passwordController,

                        obscureText: obscurePassword,

                        textInputAction: TextInputAction.done,

                        onSubmitted: (_) {
                          if (!isLoading) {
                            login();
                          }
                        },

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff172033),
                        ),

                        decoration: InputDecoration(
                          hintText: "Enter password",

                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                          ),

                          filled: true,
                          fillColor: Colors.white,

                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: Color(0xff1565C0),
                          ),

                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },

                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,

                              color: Colors.grey.shade600,
                            ),
                          ),

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),

                            borderSide: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1.2,
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),

                            borderSide: const BorderSide(
                              color: Color(0xff1565C0),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ======================================================
                    // PUSH BUTTON TO BOTTOM
                    // ======================================================
                    const Spacer(),

                    // ======================================================
                    // LOGIN BUTTON
                    // ======================================================
                    SizedBox(
                      width: double.infinity,
                      height: 58,

                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1565C0),

                          disabledBackgroundColor: const Color(0xff90CAF9),

                          foregroundColor: Colors.white,

                          elevation: 5,

                          shadowColor: const Color(0xff1565C0).withOpacity(0.3),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  const Icon(Icons.login_rounded, size: 21),

                                  const SizedBox(width: 10),

                                  Text(
                                    "Login",
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 6 : 14),

                    // ======================================================
                    // SECURITY MESSAGE
                    // ======================================================
                    Container(
                      width: double.infinity,

                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: keyboardOpen ? 7 : 11,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xffEAF2FF),
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 19,
                            color: Color(0xff1565C0),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Your login details are securely verified by the school server.",

                              style: TextStyle(
                                fontSize: keyboardOpen ? 10 : 12,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 5 : 12),

                    // ======================================================
                    // TERMS
                    // ======================================================
                    Text(
                      "By continuing, you agree to our\n"
                      "Privacy Policy & Terms of Service",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: keyboardOpen ? 9 : 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
