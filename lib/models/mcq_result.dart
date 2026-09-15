class McqResult {
  final String testId;
  final String studentId;
  final String testTitle;
  final String subject;

  final int totalQuestions;
  final int attemptedQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unanswered;

  final int score;
  final int totalMarks;
  final double percentage;

  final bool autoSubmitted;

  final String submittedAt;

  const McqResult({
    required this.testId,
    required this.studentId,
    required this.testTitle,
    required this.subject,
    required this.totalQuestions,
    required this.attemptedQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unanswered,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.autoSubmitted,
    required this.submittedAt,
  });

  // ============================================================
  // DUMMY RESULT
  // Used for frontend testing
  // ============================================================

  factory McqResult.dummy() {
    return const McqResult(
      testId: "TEST001",
      studentId: "STU001",
      testTitle: "Daily Mathematics Test",
      subject: "Mathematics",

      totalQuestions: 10,
      attemptedQuestions: 9,

      correctAnswers: 8,
      wrongAnswers: 1,
      unanswered: 1,

      score: 8,
      totalMarks: 10,

      percentage: 80.0,

      autoSubmitted: false,

      submittedAt: "09 Aug 2026 07:12 PM",
    );
  }

  // ============================================================
  // FROM JSON
  // Used when receiving result from Spring Boot API
  // ============================================================

  factory McqResult.fromJson(Map<String, dynamic> json) {
    return McqResult(
      testId: json['testId']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      testTitle: json['testTitle']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',

      totalQuestions: _toInt(json['totalQuestions']),

      attemptedQuestions: _toInt(json['attemptedQuestions']),

      correctAnswers: _toInt(json['correctAnswers']),

      wrongAnswers: _toInt(json['wrongAnswers']),

      unanswered: _toInt(json['unanswered']),

      score: _toInt(json['score']),

      totalMarks: _toInt(json['totalMarks']),

      percentage: _toDouble(json['percentage']),

      autoSubmitted: json['autoSubmitted'] == true,

      submittedAt: json['submittedAt']?.toString() ?? '',
    );
  }

  // ============================================================
  // TO JSON
  // Used when sending result/submission data
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'testId': testId,
      'studentId': studentId,
      'testTitle': testTitle,
      'subject': subject,

      'totalQuestions': totalQuestions,
      'attemptedQuestions': attemptedQuestions,

      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'unanswered': unanswered,

      'score': score,
      'totalMarks': totalMarks,

      'percentage': percentage,

      'autoSubmitted': autoSubmitted,

      'submittedAt': submittedAt,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  McqResult copyWith({
    String? testId,
    String? studentId,
    String? testTitle,
    String? subject,

    int? totalQuestions,
    int? attemptedQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? unanswered,

    int? score,
    int? totalMarks,
    double? percentage,

    bool? autoSubmitted,

    String? submittedAt,
  }) {
    return McqResult(
      testId: testId ?? this.testId,
      studentId: studentId ?? this.studentId,
      testTitle: testTitle ?? this.testTitle,
      subject: subject ?? this.subject,

      totalQuestions: totalQuestions ?? this.totalQuestions,

      attemptedQuestions: attemptedQuestions ?? this.attemptedQuestions,

      correctAnswers: correctAnswers ?? this.correctAnswers,

      wrongAnswers: wrongAnswers ?? this.wrongAnswers,

      unanswered: unanswered ?? this.unanswered,

      score: score ?? this.score,

      totalMarks: totalMarks ?? this.totalMarks,

      percentage: percentage ?? this.percentage,

      autoSubmitted: autoSubmitted ?? this.autoSubmitted,

      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  static int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }
}
