import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:parent_app/features/home/parent_home_screen.dart';
import 'package:parent_app/services/api_service.dart';
import 'package:parent_app/storage/local_storage.dart';
import 'package:parent_app/features/auth/login/forgot_password_screen.dart';

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

  static const Color primary = Color(0xff3155D9);
  static const Color primaryDark = Color(0xff2343B8);
  static const Color background = Color(0xffF6F8FC);
  static const Color textDark = Color(0xff172033);
  static const Color textMuted = Color(0xff697386);

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty) {
      _showMessage('Please enter your username', isError: true);
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password', isError: true);
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
            _showMessage('Invalid login response from server', isError: true);

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

          debugPrint('========== LOGIN DEBUG ==========');
          debugPrint('USERNAME : $responseUsername');
          debugPrint('USER ID  : $userId');
          debugPrint('ROLE     : $role');
          debugPrint('TOKEN    : $token');
          debugPrint('=================================');

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ParentHomeScreen()),
            (route) => false,
          );

          return;
        }

        _showMessage('Invalid response from server', isError: true);
      } else {
        String message = 'Invalid username or password';

        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }

        _showMessage(message, isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('LOGIN ERROR: $e');

      _showMessage(
        'Unable to connect to server. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 21,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: isError
            ? const Color(0xffD93025)
            : const Color(0xff188038),
        elevation: 6,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    final keyboardOpen = media.viewInsets.bottom > 0;
    final screenHeight = media.size.height;

    final compact = screenHeight < 700 || keyboardOpen;

    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _buildHeader(compact),

                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        compact ? 18 : 28,
                        20,
                        22,
                      ),
                      child: _buildLoginForm(compact),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // PREMIUM HEADER
  // ============================================================

  Widget _buildHeader(bool compact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24,
        compact ? 20 : 34,
        24,
        compact ? 28 : 38,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff2948C7), Color(0xff3155D9), Color(0xff5A78E7)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            height: compact ? 72 : 92,
            width: compact ? 72 : 92,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.school_rounded,
              color: primary,
              size: compact ? 39 : 52,
            ),
          ),

          SizedBox(height: compact ? 12 : 18),

          Text(
            'Smart School',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: compact ? 25 : 31,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'MAKE LIVES BRIGHTER',
            style: GoogleFonts.poppins(
              color: const Color(0xffFFE58A),
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),

          SizedBox(height: compact ? 6 : 9),

          Text(
            'Learning Today, Leading Tomorrow',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(.78),
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGIN FORM
  // ============================================================

  Widget _buildLoginForm(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome
        Text(
          'Welcome Back 👋',
          style: GoogleFonts.poppins(
            color: textDark,
            fontSize: compact ? 23 : 27,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Sign in to continue to your parent account.',
          style: TextStyle(color: textMuted, fontSize: 13.5, height: 1.4),
        ),

        SizedBox(height: compact ? 20 : 28),

        // Username
        _buildFieldLabel('Username'),

        const SizedBox(height: 8),

        _buildUsernameField(),

        SizedBox(height: compact ? 14 : 18),

        // Password
        _buildFieldLabel('Password'),

        const SizedBox(height: 8),
        _buildPasswordField(),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.poppins(
                color: primary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        SizedBox(height: compact ? 14 : 20),

        _buildLoginButton(),

        SizedBox(height: compact ? 14 : 18),

        // Security
        _buildSecurityCard(),

        const SizedBox(height: 15),

        // Terms
        _buildTerms(),
      ],
    );
  }

  Widget _buildFieldLabel(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: textDark,
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ============================================================
  // USERNAME FIELD
  // ============================================================

  Widget _buildUsernameField() {
    return TextField(
      controller: usernameController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      style: GoogleFonts.poppins(
        color: textDark,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _inputDecoration(
        hint: 'Enter your username',
        icon: Icons.person_outline_rounded,
      ),
    );
  }

  // ============================================================
  // PASSWORD FIELD
  // ============================================================

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordController,
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      onSubmitted: (_) {
        if (!isLoading) {
          login();
        }
      },
      style: GoogleFonts.poppins(
        color: textDark,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: _inputDecoration(
        hint: 'Enter your password',
        icon: Icons.lock_outline_rounded,
        suffix: IconButton(
          splashRadius: 22,
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
          icon: Icon(
            obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xff7A8496),
            size: 21,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: const Color(0xffA7AFBD),
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 8),
        child: Icon(icon, color: primary, size: 21),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xffE5E9F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.7),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xffD93025)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xffD93025), width: 1.7),
      ),
    );
  }

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: const Color(0xff9EAFE9),
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: primary.withOpacity(.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 23,
                  width: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: const ValueKey('login'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login_rounded, size: 20),
                    const SizedBox(width: 9),
                    Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ============================================================
  // SECURITY CARD
  // ============================================================

  Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffEDF3FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffDDE8FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: primary.withOpacity(.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: primary,
              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Login',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your credentials are securely verified by the school server.',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TERMS
  // ============================================================

  Widget _buildTerms() {
    return Center(
      child: Text(
        'By continuing, you agree to our\n'
        'Privacy Policy & Terms of Service',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: const Color(0xff929AA8),
          fontSize: 10.5,
          height: 1.45,
        ),
      ),
    );
  }
}
