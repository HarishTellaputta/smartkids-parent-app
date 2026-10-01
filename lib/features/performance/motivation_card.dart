import 'package:flutter/material.dart';

class MotivationCard extends StatelessWidget {
  final double averageScore;

  const MotivationCard({
    super.key,
    required this.averageScore,
  });

  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF697386);

  String get _title {
    if (averageScore >= 90) {
      return 'Outstanding Performance! 🎉';
    }

    if (averageScore >= 75) {
      return 'Great Progress! 🌟';
    }

    if (averageScore >= 60) {
      return 'Keep Growing! 💪';
    }

    return 'Keep Practicing! 📚';
  }

  String get _message {
    if (averageScore >= 90) {
      return 'You are doing an excellent job. Keep maintaining your consistency and aim even higher.';
    }

    if (averageScore >= 75) {
      return 'Your performance is going in the right direction. Regular practice can help you reach the next level.';
    }

    if (averageScore >= 60) {
      return 'You have made a good start. Focus on the questions you missed and keep practicing regularly.';
    }

    return 'Every test is a chance to learn. Practice regularly, review your mistakes, and keep improving.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primaryDark,
            primary,
            Color(0xFF5B7FF0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ======================================================
          // DECORATIVE CIRCLES
          // ======================================================

          Positioned(
            right: -35,
            top: -45,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 45,
            bottom: -65,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.14),
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Your learning journey matters.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                _message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.86),
                  fontSize: 11,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // ACTION / REMINDER STRIP
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Review your mistakes and take the next test with confidence.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.86),
                          fontSize: 10,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}