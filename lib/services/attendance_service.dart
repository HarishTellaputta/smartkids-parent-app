import 'package:http/http.dart' as http;

import 'api_service.dart';

class AttendanceService {
  // ============================================================
  // STUDENT ATTENDANCE - DATE RANGE
  // ============================================================

  static Future<http.Response> getStudentAttendance(
    int studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = startDate
        .toIso8601String()
        .split('T')
        .first;

    final end = endDate
        .toIso8601String()
        .split('T')
        .first;

    return await ApiService.get(
      '/api/v1/attendances/student/$studentId'
      '?startDate=$start&endDate=$end',
      requiresAuth: true,
    );
  }

  // ============================================================
  // STUDENT ATTENDANCE REPORT
  // ============================================================

  static Future<http.Response> getStudentAttendanceReport(
    int studentId,
    int classId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = startDate
        .toIso8601String()
        .split('T')
        .first;

    final end = endDate
        .toIso8601String()
        .split('T')
        .first;

    return await ApiService.get(
      '/api/v1/attendances/student/$studentId/report'
      '?classId=$classId'
      '&startDate=$start'
      '&endDate=$end',
      requiresAuth: true,
    );
  }

  // ============================================================
  // STUDENT ATTENDANCE PERCENTAGE
  // ============================================================

  static Future<http.Response> getStudentAttendancePercentage(
    int studentId,
    int classId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = startDate
        .toIso8601String()
        .split('T')
        .first;

    final end = endDate
        .toIso8601String()
        .split('T')
        .first;

    return await ApiService.get(
      '/api/v1/attendances/student/$studentId/percentage'
      '?classId=$classId'
      '&startDate=$start'
      '&endDate=$end',
      requiresAuth: true,
    );
  }
}