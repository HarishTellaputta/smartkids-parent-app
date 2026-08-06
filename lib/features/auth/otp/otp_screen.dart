import 'package:flutter/material.dart';
import 'package:parent_app/features/home/parent_home_screen.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();
  int seconds = 30;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() async {
    while (seconds > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      setState(() {
        seconds--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            const Text(
              "OTP Verification",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "Enter the 6-digit OTP sent to\n+91 ${widget.mobileNumber}",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 40),

            Pinput(
              length: 6,

              controller: otpController,

              keyboardType: TextInputType.number,

              defaultPinTheme: PinTheme(
                width: 50,

                height: 55,

                textStyle: const TextStyle(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              focusedPinTheme: PinTheme(
                width: 50,

                height: 55,

                textStyle: const TextStyle(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(14),

                  border: Border.all(color: Colors.blue),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                seconds == 0
                    ? "Didn't receive OTP?"
                    : "Resend OTP in ${seconds}s",
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 10),

            if (seconds == 0)
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      seconds = 30;
                    });
                    startTimer();
                  },
                  child: const Text(
                    "Resend OTP",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,

                    MaterialPageRoute(builder: (_) => const ParentHomeScreen()),
                  );
                },
                child: const Text(
                  "Verify OTP",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
