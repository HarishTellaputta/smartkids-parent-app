import 'package:flutter/material.dart';

import '../../models/mcq_result.dart';

class ResultCard extends StatelessWidget {
  final McqResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = _getScoreColor(result.percentage);

    final String performanceText = _getPerformanceText(result.percentage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        children: [
          // ====================================================
          // SUCCESS ICON
          // ====================================================
          Container(
            height: 72,
            width: 72,

            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),

            child: Icon(
              result.percentage >= 60
                  ? Icons.emoji_events_rounded
                  : Icons.school_rounded,
              size: 38,
              color: scoreColor,
            ),
          ),

          const SizedBox(height: 15),

          // ====================================================
          // TEST TITLE
          // ====================================================
          Text(
            result.testTitle,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xff172033),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            result.subject,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 20),

          // ====================================================
          // SCORE
          // ====================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),

            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Column(
              children: [
                Text(
                  "${result.score}/${result.totalMarks}",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  "${result.percentage.toStringAsFixed(0)}%",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  performanceText,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ====================================================
          // RESULT STATISTICS
          // ====================================================
          Row(
            children: [
              Expanded(
                child: _statItem(
                  icon: Icons.check_circle_rounded,
                  title: "Correct",
                  value: "${result.correctAnswers}",
                  color: Colors.green,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _statItem(
                  icon: Icons.cancel_rounded,
                  title: "Wrong",
                  value: "${result.wrongAnswers}",
                  color: Colors.red,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _statItem(
                  icon: Icons.remove_circle_rounded,
                  title: "Skipped",
                  value: "${result.unanswered}",
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ====================================================
          // ATTEMPTED QUESTIONS
          // ====================================================
          Container(
            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: const Color(0xffF7F8FB),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.quiz_outlined,
                  size: 20,
                  color: Color(0xff4169E1),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    "Questions Attempted",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),

                Text(
                  "${result.attemptedQuestions}"
                  "/${result.totalQuestions}",

                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ====================================================
          // SUBMISSION STATUS
          // ====================================================
          Container(
            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),

            decoration: BoxDecoration(
              color: result.autoSubmitted
                  ? const Color(0xfffff7e6)
                  : const Color(0xffecfdf3),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Row(
              children: [
                Icon(
                  result.autoSubmitted
                      ? Icons.timer_off_rounded
                      : Icons.check_circle_outline,
                  size: 18,

                  color: result.autoSubmitted ? Colors.orange : Colors.green,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    result.autoSubmitted
                        ? "Test automatically submitted when time ended"
                        : "Test submitted successfully",

                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,

                      color: result.autoSubmitted
                          ? Colors.orange.shade800
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ====================================================
          // SUBMITTED TIME
          // ====================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: Colors.grey.shade500,
              ),

              const SizedBox(width: 5),

              Text(
                "Submitted: ${result.submittedAt}",
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT ITEM
  // ============================================================

  Widget _statItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),

      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(13),
      ),

      child: Column(
        children: [
          Icon(icon, size: 20, color: color),

          const SizedBox(height: 5),

          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCORE COLOR
  // ============================================================

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    }

    if (percentage >= 60) {
      return Colors.orange;
    }

    return Colors.red;
  }

  // ============================================================
  // PERFORMANCE TEXT
  // ============================================================

  String _getPerformanceText(double percentage) {
    if (percentage >= 90) {
      return "Excellent performance! 🌟";
    }

    if (percentage >= 80) {
      return "Great job! Keep it up! 👏";
    }

    if (percentage >= 60) {
      return "Good effort! Keep practicing! 💪";
    }

    if (percentage >= 40) {
      return "Keep learning and try again! 📚";
    }

    return "Don't give up. You can do better! 🌱";
  }
}
