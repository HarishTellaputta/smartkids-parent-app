import 'package:flutter/material.dart';

class OverallPerformanceCard extends StatelessWidget {
  final double averageScore;
  final double highestScore;
  final int testsCompleted;
  final String performanceLabel;

  const OverallPerformanceCard({
    super.key,
    required this.averageScore,
    required this.highestScore,
    required this.testsCompleted,
    required this.performanceLabel,
  });

  static const Color primary = Color(0xFF3155D9);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);

  Color get _statusColor {
    if (averageScore >= 80) {
      return const Color(0xFF16A34A);
    }

    if (averageScore >= 60) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final average = averageScore.clamp(0.0, 100.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE5E9F0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // TITLE
          // ======================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Performance',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Based on completed MCQ tests',
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Performance badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _statusColor.withOpacity(0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      performanceLabel,
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          // ======================================================
          // SCORE + DETAILS
          // ======================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular score
              _ScoreCircle(
                percentage: average,
                color: primary,
              ),

              const SizedBox(width: 24),

              Expanded(
                child: Column(
                  children: [
                    _PerformanceLine(
                      icon: Icons.task_alt_rounded,
                      title: 'Tests Completed',
                      value: '$testsCompleted',
                      iconColor: const Color(0xFF3155D9),
                    ),

                    const SizedBox(height: 15),

                    _PerformanceLine(
                      icon: Icons.emoji_events_rounded,
                      title: 'Highest Score',
                      value: '${highestScore.round()}%',
                      iconColor: const Color(0xFFF59E0B),
                    ),

                    const SizedBox(height: 15),

                    _PerformanceLine(
                      icon: Icons.analytics_rounded,
                      title: 'Average Score',
                      value: '${averageScore.round()}%',
                      iconColor: const Color(0xFF16A34A),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ======================================================
          // BOTTOM MESSAGE
          // ======================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  size: 17,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    _message,
                    style: const TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _message {
    if (averageScore >= 90) {
      return 'Outstanding work! Keep maintaining this excellent performance.';
    }

    if (averageScore >= 75) {
      return 'Great progress! Keep practicing to reach the next level.';
    }

    if (averageScore >= 60) {
      return 'Good effort! Regular practice can help improve your score.';
    }

    return 'Keep practicing regularly. Every test is an opportunity to improve.';
  }
}

// ==================================================================
// SCORE CIRCLE
// ==================================================================

class _ScoreCircle extends StatelessWidget {
  final double percentage;
  final Color color;

  const _ScoreCircle({
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      width: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 128,
            width: 128,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 10,
              backgroundColor: const Color(0xFFE8ECF4),
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFFE8ECF4),
              ),
            ),
          ),

          SizedBox(
            height: 128,
            width: 128,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${percentage.round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Average',
                style: TextStyle(
                  color: Color(0xFF697386),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// PERFORMANCE LINE
// ==================================================================

class _PerformanceLine extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _PerformanceLine({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 31,
          width: 31,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.09),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF697386),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF172033),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}