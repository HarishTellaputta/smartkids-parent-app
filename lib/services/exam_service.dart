import 'package:http/http.dart' as http;

import 'api_service.dart';

class ExamService {
  // ============================================================
  // EXAMINATIONS
  // ============================================================

  static Future<http.Response> getExaminations({
    int? academicYearId,
  }) async {
    final query = academicYearId != null
        ? '?academicYearId=$academicYearId'
        : '';

    return await ApiService.get(
      '/api/v1/examinations$query',
      requiresAuth: true,
    );
  }

  // ============================================================
  // STUDENT RESULTS
  // ============================================================

  static Future<http.Response> getStudentExamResults(
    int studentId,
  ) async {
    return await ApiService.get(
      '/api/v1/examinations/results?studentId=$studentId',
      requiresAuth: true,
    );
  }

  // ============================================================
  // EXAM SCHEDULES
  // ============================================================

  static Future<http.Response> getExamSchedules({
    int? examinationId,
    int? classId,
    int? sectionId,
    int? subjectId,
  }) async {
    final params = <String>[];

    if (examinationId != null) {
      params.add('examinationId=$examinationId');
    }

    if (classId != null) {
      params.add('classId=$classId');
    }

    if (sectionId != null) {
      params.add('sectionId=$sectionId');
    }

    if (subjectId != null) {
      params.add('subjectId=$subjectId');
    }

    final query = params.isEmpty
        ? ''
        : '?${params.join('&')}';

    return await ApiService.get(
      '/api/v1/examinations/schedules$query',
      requiresAuth: true,
    );
  }

  // ============================================================
  // GRADE RULES
  // ============================================================

  static Future<http.Response> getGradeRules() async {
    return await ApiService.get(
      '/api/v1/examinations/grade-rules',
      requiresAuth: true,
    );
  }
}