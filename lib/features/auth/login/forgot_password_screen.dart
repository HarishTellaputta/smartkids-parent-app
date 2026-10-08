import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:parent_app/services/api_service.dart';
import 'package:parent_app/services/auth_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  static const Color primary = Color(0xff3155D9);
  static const Color background = Color(0xffF6F8FC);
  static const Color textDark = Color(0xff172033);
  static const Color textMuted = Color(0xff697386);

  Future<void> _forgotPassword() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Please enter your email address', isError: true);
      return;
    }

    if (!email.contains('@')) {
      _showMessage('Please enter a valid email address', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await AuthService.forgotPassword(email: email);

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          String responseText = response.body.trim();

          const prefix = 'Password reset token generated:';

          String token = responseText;

          if (responseText.startsWith(prefix)) {
            token = responseText.substring(prefix.length).trim();
          }

          if (token.isEmpty) {
            _showMessage('Reset token was not received', isError: true);
            return;
          }

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(token: token),
            ),
          );
        } else {
          _showMessage(
            response.body.isNotEmpty
                ? response.body
                : 'Unable to process request',
            isError: true,
          );
        }
      } else {
        final message = response.toString();

        _showMessage(
          message.isNotEmpty
              ? message
              : 'Unable to process password reset request.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('FORGOT PASSWORD ERROR: $e');

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
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: isError
            ? const Color(0xffD93025)
            : const Color(0xff188038),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: textDark,
        title: Text(
          'Forgot Password',
          style: GoogleFonts.poppins(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 92,
                  width: 92,
                  decoration: BoxDecoration(
                    color: const Color(0xffEAF0FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: primary,
                    size: 46,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Center(
                child: Text(
                  'Reset Your Password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter the email address registered with your parent account. We will send you instructions to reset your password.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textMuted,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'Email Address',
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!isLoading) {
                    _forgotPassword();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter your registered email',
                  prefixIcon: const Icon(Icons.email_outlined, color: primary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 17,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xffE5E9F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xffE5E9F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: primary, width: 1.6),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _forgotPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    disabledBackgroundColor: const Color(0xff9EAFE9),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_rounded, size: 19),
                            const SizedBox(width: 9),
                            Text(
                              'Send Reset Instructions',
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffEDF3FF),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xffDDE8FF)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Use the email address registered by your school. If you do not receive an email, please contact your school administrator.',
                        style: GoogleFonts.poppins(
                          color: textMuted,
                          fontSize: 11.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
