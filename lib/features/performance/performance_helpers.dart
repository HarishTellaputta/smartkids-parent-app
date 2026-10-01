import 'package:flutter/material.dart';

class PerformanceHelpers {
  PerformanceHelpers._();

  // ============================================================
  // SUBJECT ICON
  // ============================================================

  static IconData subjectIcon(String subject) {
    final value = subject.trim().toLowerCase();

    if (value.contains('math')) {
      return Icons.calculate_rounded;
    }

    if (value.contains('english')) {
      return Icons.menu_book_rounded;
    }

    if (value.contains('science')) {
      return Icons.science_rounded;
    }

    if (value.contains('social')) {
      return Icons.public_rounded;
    }

    if (value.contains('telugu')) {
      return Icons.translate_rounded;
    }

    if (value.contains('hindi')) {
      return Icons.language_rounded;
    }

    if (value.contains('computer')) {
      return Icons.computer_rounded;
    }

    return Icons.quiz_rounded;
  }

  // ============================================================
  // SCORE COLOR
  // ============================================================

  static Color scoreColor(double score) {
    if (score >= 80) {
      return const Color(0xFF16A34A);
    }

    if (score >= 60) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFFDC2626);
  }

  // ============================================================
  // PERFORMANCE LABEL
  // ============================================================

  static String performanceLabel(double score) {
    if (score >= 90) {
      return 'Excellent';
    }

    if (score >= 75) {
      return 'Very Good';
    }

    if (score >= 60) {
      return 'Good';
    }

    return 'Keep Practicing';
  }

  // ============================================================
  // PERFORMANCE LABEL COLOR
  // ============================================================

  static Color performanceLabelColor(double score) {
    if (score >= 75) {
      return const Color(0xFF16A34A);
    }

    if (score >= 60) {
      return const Color(0xFFF59E0B);
    }

    return const Color(0xFFDC2626);
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  static String formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  // ============================================================
  // PERCENTAGE
  // ============================================================

  static double clampPercentage(double value) {
    if (value < 0) {
      return 0;
    }

    if (value > 100) {
      return 100;
    }

    return value;
  }

  // ============================================================
  // SCORE TEXT
  // ============================================================

  static String percentageText(double value) {
    return '${value.round()}%';
  }
}