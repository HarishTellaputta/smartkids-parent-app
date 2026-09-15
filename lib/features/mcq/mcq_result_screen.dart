import 'package:flutter/material.dart';

class McqResultScreen extends StatelessWidget {
  final int totalQuestions;
  final int score;
  final int correctAnswers;
  final int wrongAnswers;
  final int unanswered;
  final bool autoSubmitted;

  const McqResultScreen({
    super.key,
    required this.totalQuestions,
    required this.score,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unanswered,
    required this.autoSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalQuestions == 0
        ? 0
        : ((score / totalQuestions) * 100).round();

    final bool passed = percentage >= 40;

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      appBar: AppBar(
        title: const Text(
          "Test Result",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff172033),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 15),

              // =====================================================
              // RESULT ICON
              // =====================================================
              Container(
                height: 95,
                width: 95,

                decoration: BoxDecoration(
                  color: passed
                      ? const Color(0xffDCFCE7)
                      : const Color(0xffffe4e6),
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  passed
                      ? Icons.celebration_rounded
                      : Icons.sentiment_dissatisfied_rounded,
                  size: 52,
                  color: passed ? Colors.green : Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // TITLE
              // =====================================================
              Text(
                autoSubmitted ? "Test Auto-Submitted" : "Test Completed!",
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff172033),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                autoSubmitted
                    ? "Time limit reached. Your test was submitted automatically."
                    : "Great job! Your test has been submitted successfully.",
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 30),

              // =====================================================
              // SCORE CARD
              // =====================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    const Text(
                      "Your Score",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "$score / $totalQuestions",

                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff4169E1),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: passed
                            ? const Color(0xffDCFCE7)
                            : const Color(0xffffe4e6),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        "$percentage%",

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: passed
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // RESULT STATISTICS
              // =====================================================
              Row(
                children: [
                  Expanded(
                    child: _resultStat(
                      icon: Icons.check_circle_rounded,
                      title: "Correct",
                      value: "$correctAnswers",
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _resultStat(
                      icon: Icons.cancel_rounded,
                      title: "Wrong",
                      value: "$wrongAnswers",
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _resultStat(
                      icon: Icons.remove_circle_rounded,
                      title: "Skipped",
                      value: "$unanswered",
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =====================================================
              // PERFORMANCE MESSAGE
              // =====================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: passed
                      ? const Color(0xffF0FDF4)
                      : const Color(0xfffff1f2),

                  borderRadius: BorderRadius.circular(18),

                  border: Border.all(
                    color: passed
                        ? const Color(0xffBBF7D0)
                        : const Color(0xffffcdd3),
                  ),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Icon(
                      passed
                          ? Icons.thumb_up_alt_rounded
                          : Icons.lightbulb_outline_rounded,

                      color: passed ? Colors.green : Colors.orange,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        _performanceMessage(percentage),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: passed
                              ? Colors.green.shade800
                              : Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =====================================================
              // TEST DETAILS
              // =====================================================
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Test Details",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff172033),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _detailRow(
                      icon: Icons.menu_book_rounded,
                      title: "Subject",
                      value: "Mathematics",
                    ),

                    _detailRow(
                      icon: Icons.description_outlined,
                      title: "Test",
                      value: "Daily MCQ Test",
                    ),

                    _detailRow(
                      icon: Icons.help_outline_rounded,
                      title: "Questions",
                      value: "$totalQuestions",
                    ),

                    _detailRow(
                      icon: Icons.timer_outlined,
                      title: "Duration",
                      value: "15 Minutes",
                    ),

                    _detailRow(
                      icon: autoSubmitted
                          ? Icons.timer_off_rounded
                          : Icons.check_circle_outline,
                      title: "Submission",
                      value: autoSubmitted
                          ? "Automatically Submitted"
                          : "Submitted by Student",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =====================================================
              // BACK HOME BUTTON
              // =====================================================
              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff4169E1),
                    foregroundColor: Colors.white,
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // =====================================================
              // VIEW ANSWERS
              // =====================================================
              SizedBox(
                width: double.infinity,
                height: 50,

                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Answer review will be available here."),
                      ),
                    );
                  },

                  icon: const Icon(Icons.visibility_outlined),

                  label: const Text("View Answers"),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff4169E1),

                    side: const BorderSide(color: Color(0xff4169E1)),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESULT STAT CARD
  // ============================================================

  Widget _resultStat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, color: color, size: 25),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,

            decoration: BoxDecoration(
              color: const Color(0xffF1F4FA),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(icon, size: 19, color: const Color(0xff4169E1)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,

              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xff172033),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERFORMANCE MESSAGE
  // ============================================================

  String _performanceMessage(int percentage) {
    if (percentage >= 90) {
      return "Excellent work! 🌟 Keep up the amazing performance!";
    }

    if (percentage >= 75) {
      return "Great job! 👏 You are doing very well. Keep practicing!";
    }

    if (percentage >= 60) {
      return "Good effort! 👍 A little more practice can make you even better.";
    }

    if (percentage >= 40) {
      return "Keep practicing! 💪 You can improve your score in the next test.";
    }

    return "Don't worry! 🌱 Practice regularly and you will improve.";
  }
}
