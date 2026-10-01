import 'package:flutter/material.dart';

import 'performance_helpers.dart';

class SubjectPerformanceCard extends StatelessWidget {
  final String subject;
  final int score;
  final int tests;

  const SubjectPerformanceCard({
    super.key,
    required this.subject,
    required this.score,
    required this.tests,
  });

  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);
  static const Color primary = Color(0xFF3155D9);

  @override
  Widget build(BuildContext context) {
    final safeScore = score.clamp(0, 100);
    final scoreColor = PerformanceHelpers.scoreColor(
      safeScore.toDouble(),
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E9F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ======================================================
          // TOP ROW
          // ======================================================

          Row(
            children: [
              // Subject icon
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE8F0FF),
                      Color(0xFFF1F5FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  PerformanceHelpers.subjectIcon(subject),
                  color: primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Subject details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.isEmpty ? 'Other' : subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 13,
                          color: textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$tests ${tests == 1 ? 'test' : 'tests'} completed',
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$safeScore%',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Average',
                    style: TextStyle(
                      color: textMuted.withOpacity(0.85),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ======================================================
          // PROGRESS BAR
          // ======================================================

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: safeScore / 100,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFEDF0F5),
                    valueColor: AlwaysStoppedAnimation(
                      scoreColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                _performanceText(safeScore),
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _performanceText(int score) {
    if (score >= 90) {
      return 'Excellent';
    }

    if (score >= 75) {
      return 'Very Good';
    }

    if (score >= 60) {
      return 'Good';
    }

    return 'Practice More';
  }
}