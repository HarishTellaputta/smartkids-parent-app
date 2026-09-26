
import 'mcq_test.dart';

class McqAttempt {
  final int? attemptId;
  final int? testId;
  final int? studentId;
  final String? studentName;
  final String? admissionNo;
  final String? status;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final DateTime? submittedAt;
  final int? score;
  final int? totalQuestions;
  final int? correctAnswers;
  final int? wrongAnswers;
  final double? percentage;
  final McqTest? test;

  const McqAttempt({
    this.attemptId,
    this.testId,
    this.studentId,
    this.studentName,
    this.admissionNo,
    this.status,
    this.startedAt,
    this.expiresAt,
    this.submittedAt,
    this.score,
    this.totalQuestions,
    this.correctAnswers,
    this.wrongAnswers,
    this.percentage,
    this.test,
  });

  factory McqAttempt.fromJson(Map<String, dynamic> json) {
    return McqAttempt(
      attemptId: _toInt(json['attemptId']),
      testId: _toInt(json['testId']),
      studentId: _toInt(json['studentId']),
      studentName: json['studentName']?.toString(),
      admissionNo: json['admissionNo']?.toString(),
      status: json['status']?.toString(),

      startedAt: _toDateTime(json['startedAt']),
      expiresAt: _toDateTime(json['expiresAt']),
      submittedAt: _toDateTime(json['submittedAt']),

      score: _toInt(json['score']),
      totalQuestions: _toInt(json['totalQuestions']),
      correctAnswers: _toInt(json['correctAnswers']),
      wrongAnswers: _toInt(json['wrongAnswers']),
      percentage: _toDouble(json['percentage']),

      test: json['test'] is Map<String, dynamic>
          ? McqTest.fromJson(
              json['test'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attemptId': attemptId,
      'testId': testId,
      'studentId': studentId,
      'studentName': studentName,
      'admissionNo': admissionNo,
      'status': status,
      'startedAt': startedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'percentage': percentage,
      'test': test?.toJson(),
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}
