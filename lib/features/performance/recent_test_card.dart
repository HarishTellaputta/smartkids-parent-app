import 'package:flutter/material.dart';

import 'package:parent_app/models/mcq_attempt.dart';

import 'performance_helpers.dart';

class RecentTestCard extends StatelessWidget {
  final McqAttempt test;

  const RecentTestCard({
    super.key,
    required this.test,
  });

  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color primary = Color(0xFF3155D9);

  @override
  Widget build(BuildContext context) {
    final percentage = (test.percentage ?? 0).clamp(0, 100).round();

    final scoreColor = PerformanceHelpers.scoreColor(
      percentage.toDouble(),
    );

    final subject = test.test?.subject.trim();

    final title = subject != null && subject.isNotEmpty
        ? '$subject Test'
        : 'MCQ Test';

    final score = test.score ?? 0;

    final total = test.totalQuestions ??
        test.test?.questions.length ??
        0;

    final date = PerformanceHelpers.formatDate(
      test.submittedAt ?? test.startedAt,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE5E9F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.022),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ======================================================
          // TEST ICON
          // ======================================================

          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE8F0FF),
                  Color(0xFFF2F5FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: primary,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // ======================================================
          // TEST DETAILS
          // ======================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      date,
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Container(
                      height: 3,
                      width: 3,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB8BFCC),
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 9),

                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 12,
                      color: textMuted,
                    ),
                    const SizedBox(width: 5),

                    Text(
                      '$score/$total',
                      style: const TextStyle(
                        color: textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // ======================================================
          // PERCENTAGE
          // ======================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: scoreColor.withOpacity(0.12),
              ),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                color: scoreColor,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}