import 'package:flutter/material.dart';
import 'package:parent_app/features/auth/otp/otp_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();

  void sendOtp() {
    FocusScope.of(context).unfocus();

    if (mobileController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid 10-digit mobile number"),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(mobileNumber: mobileController.text),
      ),
    );
  }

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // CHECK WHETHER KEYBOARD IS OPEN
    // ============================================================
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
            //
            // Header SHRINKS when keyboard opens.
            //
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
                      "Login with your registered mobile number.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: keyboardOpen ? 13 : 16,
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 10 : 24),

                    // ======================================================
                    // MOBILE NUMBER LABEL
                    // ======================================================
                    const Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff172033),
                      ),
                    ),

                    SizedBox(height: keyboardOpen ? 6 : 10),

                    // ======================================================
                    // MOBILE NUMBER FIELD
                    // ======================================================
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
                        controller: mobileController,

                        keyboardType: TextInputType.phone,

                        maxLength: 10,

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: Color(0xff172033),
                        ),

                        decoration: InputDecoration(
                          counterText: "",

                          hintText: "Enter mobile number",

                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0,
                          ),

                          filled: true,
                          fillColor: Colors.white,

                          // ==================================================
                          // INDIA +91
                          // ==================================================
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 8,
                              top: 8,
                              bottom: 8,
                            ),

                            child: Container(
                              width: 70,

                              decoration: BoxDecoration(
                                color: const Color(0xffEAF2FF),
                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  const Text(
                                    "🇮🇳",
                                    style: TextStyle(fontSize: 18),
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    "+91",
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xff1565C0),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ==================================================
                          // PHONE ICON
                          // ==================================================
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(10),

                            height: 40,
                            width: 40,

                            decoration: BoxDecoration(
                              color: const Color(0xffF1F6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),

                            child: const Icon(
                              Icons.phone_android_rounded,
                              color: Color(0xff1565C0),
                              size: 21,
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
                    // SEND OTP
                    // ======================================================
                    SizedBox(
                      width: double.infinity,
                      height: 58,

                      child: ElevatedButton(
                        onPressed: sendOtp,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1565C0),
                          foregroundColor: Colors.white,

                          elevation: 5,

                          shadowColor: const Color(0xff1565C0).withOpacity(0.3),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Icon(Icons.send_rounded, size: 21),

                            const SizedBox(width: 10),

                            Text(
                              "Send OTP",
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
                              "We will send a secure OTP to verify your mobile number.",

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
