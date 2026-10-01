import 'package:flutter/material.dart';

import 'package:parent_app/models/student_response.dart';

class PerformanceHeader extends StatelessWidget {
  final StudentResponse student;

  const PerformanceHeader({
    super.key,
    required this.student,
  });

  static const Color primary = Color(0xFF3155D9);
  static const Color primaryDark = Color(0xFF2343B8);

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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Decorative circle
          Positioned(
            right: 35,
            bottom: -65,
            child: Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Row(
            children: [
              _studentAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: _studentInfo(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT AVATAR
  // ============================================================

  Widget _studentAvatar() {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.30),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 34,
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // STUDENT INFORMATION
  // ============================================================

  Widget _studentInfo() {
    final name = student.name.trim().isEmpty
        ? 'Student'
        : student.name.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'PERFORMANCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            Icon(
              Icons.school_rounded,
              size: 14,
              color: Colors.white.withOpacity(0.78),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'MCQ Test Performance',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}