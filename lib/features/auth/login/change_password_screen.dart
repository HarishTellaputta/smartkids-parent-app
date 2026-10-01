import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:parent_app/services/api_service.dart';
import 'package:parent_app/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();

  final newPasswordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  static const Color primary = Color(0xff3155D9);
  static const Color background = Color(0xffF6F8FC);
  static const Color textDark = Color(0xff172033);
  static const Color textMuted = Color(0xff697386);

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();

    final current = currentPasswordController.text;

    final newPassword = newPasswordController.text;

    final confirm = confirmPasswordController.text;

    if (current.isEmpty) {
      _showMessage('Please enter your current password', isError: true);
      return;
    }

    if (newPassword.isEmpty) {
      _showMessage('Please enter your new password', isError: true);
      return;
    }

    if (newPassword.length < 8) {
      _showMessage('New password must be at least 8 characters', isError: true);
      return;
    }

    if (confirm.isEmpty) {
      _showMessage('Please confirm your new password', isError: true);
      return;
    }

    if (newPassword != confirm) {
      _showMessage('New passwords do not match', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await AuthService.changePassword(
        currentPassword: current,
        newPassword: newPassword,
        confirmPassword: confirm,
      );

      if (!mounted) return;

      final data = ApiService.decodeResponse(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final message = data is String
            ? data
            : data is Map && data['message'] != null
            ? data['message'].toString()
            : 'Password changed successfully.';

        _showMessage(message, isError: false);

        await Future.delayed(const Duration(milliseconds: 700));

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        final message = data is Map && data['message'] != null
            ? data['message'].toString()
            : data is String
            ? data
            : 'Unable to change password.';

        _showMessage(message, isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('CHANGE PASSWORD ERROR: $e');

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

  Widget _passwordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: primary),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xff7A8496),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
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
      ],
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
          'Change Password',
          style: GoogleFonts.poppins(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            children: [
              Container(
                height: 82,
                width: 82,
                decoration: BoxDecoration(
                  color: const Color(0xffEAF0FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: primary,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Update Password',
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Create a strong password to keep your account secure.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: textMuted,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 28),

              _passwordField(
                label: 'Current Password',
                hint: 'Enter current password',
                controller: currentPasswordController,
                obscure: obscureCurrent,
                onToggle: () {
                  setState(() {
                    obscureCurrent = !obscureCurrent;
                  });
                },
              ),

              const SizedBox(height: 17),

              _passwordField(
                label: 'New Password',
                hint: 'Enter new password',
                controller: newPasswordController,
                obscure: obscureNew,
                onToggle: () {
                  setState(() {
                    obscureNew = !obscureNew;
                  });
                },
              ),

              const SizedBox(height: 17),

              _passwordField(
                label: 'Confirm New Password',
                hint: 'Re-enter new password',
                controller: confirmPasswordController,
                obscure: obscureConfirm,
                onToggle: () {
                  setState(() {
                    obscureConfirm = !obscureConfirm;
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _changePassword,
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
                            const Icon(Icons.check_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Update Password',
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
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
                        'Password must contain at least 8 characters.',
                        style: GoogleFonts.poppins(
                          color: textMuted,
                          fontSize: 11.5,
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
