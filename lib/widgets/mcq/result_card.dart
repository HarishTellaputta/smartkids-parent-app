
import 'package:flutter/material.dart';

import '../../models/mcq_result.dart';

class ResultCard extends StatelessWidget {
  final McqResult result;

  const ResultCard({
    super.key,
    required this.result,
  });

  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color border = Color(0xFFE5E9F0);

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = _getScoreColor(result.percentage);
    final String performanceText =
        _getPerformanceText(result.percentage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          // ======================================================
          // RESULT HEADER
          // ======================================================

          _buildResultHeader(
            scoreColor,
            performanceText,
          ),

          const SizedBox(height: 18),

          // ======================================================
          // SCORE CARD
          // ======================================================

          _buildScoreCard(scoreColor),

          const SizedBox(height: 16),

          // ======================================================
          // STATISTICS
          // ======================================================

          Row(
            children: [
              Expanded(
                child: _statItem(
                  icon: Icons.check_circle_rounded,
                  title: 'Correct',
                  value: '${result.correctAnswers}',
                  color: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statItem(
                  icon: Icons.cancel_rounded,
                  title: 'Wrong',
                  value: '${result.wrongAnswers}',
                  color: const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statItem(
                  icon: Icons.remove_circle_rounded,
                  title: 'Skipped',
                  value: '${result.unanswered}',
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ======================================================
          // ATTEMPTED QUESTIONS
          // ======================================================

          _buildAttemptedCard(),

          const SizedBox(height: 10),

          // ======================================================
          // SUBMISSION STATUS
          // ======================================================

          _buildSubmissionStatus(),

          const SizedBox(height: 12),

          // ======================================================
          // SUBMITTED TIME
          // ======================================================

          _buildSubmittedTime(),
        ],
      ),
    );
  }

  // ============================================================
  // RESULT HEADER
  // ============================================================

  Widget _buildResultHeader(
    Color scoreColor,
    String performanceText,
  ) {
    final bool isGoodScore = result.percentage >= 60;

    return Column(
      children: [
        Container(
          height: 76,
          width: 76,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scoreColor.withOpacity(0.15),
                scoreColor.withOpacity(0.07),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: scoreColor.withOpacity(0.12),
            ),
          ),
          child: Icon(
            isGoodScore
                ? Icons.emoji_events_rounded
                : Icons.school_rounded,
            size: 38,
            color: scoreColor,
          ),
        ),

        const SizedBox(height: 13),

        Text(
          result.testTitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: textDark,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 5),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 13,
                color: textMuted,
              ),
              const SizedBox(width: 5),
              Text(
                result.subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Text(
          performanceText,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: scoreColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SCORE CARD
  // ============================================================

  Widget _buildScoreCard(Color scoreColor) {
    final double progress =
        (result.percentage / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withOpacity(0.10),
            scoreColor.withOpacity(0.045),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scoreColor.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.score}',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 3,
                  left: 4,
                ),
                child: Text(
                  '/${result.totalMarks}',
                  style: TextStyle(
                    color: scoreColor.withOpacity(0.60),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            '${result.percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: scoreColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: scoreColor.withOpacity(0.10),
              valueColor: AlwaysStoppedAnimation<Color>(
                scoreColor,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Score',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${result.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
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
      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 31,
            width: 31,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 17,
              color: color,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ATTEMPTED QUESTIONS
  // ============================================================

  Widget _buildAttemptedCard() {
    final int total = result.totalQuestions;
    final int attempted = result.attemptedQuestions;

    final double progress = total > 0
        ? (attempted / total).clamp(0.0, 1.0)
        : 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.quiz_outlined,
                  size: 18,
                  color: primary,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Questions Attempted',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your answered questions',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$attempted/$total',
                style: const TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE8EBF1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMISSION STATUS
  // ============================================================

  Widget _buildSubmissionStatus() {
    final bool autoSubmitted = result.autoSubmitted;

    final Color color = autoSubmitted
        ? const Color(0xFFF59E0B)
        : const Color(0xFF16A34A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.065),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 29,
            width: 29,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              autoSubmitted
                  ? Icons.timer_off_rounded
                  : Icons.check_rounded,
              size: 16,
              color: color,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              autoSubmitted
                  ? 'Test automatically submitted when time ended'
                  : 'Test submitted successfully',
              style: TextStyle(
                color: color,
                fontSize: 10,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMITTED TIME
  // ============================================================

  Widget _buildSubmittedTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.access_time_rounded,
          size: 13,
          color: Color(0xFF9AA3B2),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            'Submitted: ${result.submittedAt}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8A93A2),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SCORE COLOR
  // ============================================================

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) {
      return const Color(0xFF16A34A);
    }

    if (percentage >= 60) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFFDC2626);
  }

  // ============================================================
  // PERFORMANCE TEXT
  // ============================================================

  String _getPerformanceText(double percentage) {
    if (percentage >= 90) {
      return 'Excellent performance! 🌟';
    }

    if (percentage >= 80) {
      return 'Great job! Keep it up! 👏';
    }

    if (percentage >= 60) {
      return 'Good effort! Keep practicing! 💪';
    }

    if (percentage >= 40) {
      return 'Keep learning and try again! 📚';
    }

    return 'Keep practicing. You can improve! 🌱';
  }
}

