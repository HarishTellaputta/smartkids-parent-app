import 'package:http/http.dart' as http;

import 'api_service.dart';

class TimetableService {
  // ============================================================
  // STUDENT TIMETABLE
  // ============================================================

  static Future<http.Response> getStudentTimetable(
    int studentId,
  ) async {
    return await ApiService.get(
      '/api/v1/teacher-timetables/student/$studentId',
      requiresAuth: true,
    );
  }
} 