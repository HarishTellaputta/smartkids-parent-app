import 'package:http/http.dart' as http;

import 'api_service.dart';

class HomeworkService {
  // ============================================================
  // STUDENT HOMEWORK
  // ============================================================

  static Future<http.Response> getStudentHomework(
    int classId,
    int sectionId,
  ) async {
    return await ApiService.get(
      '/api/v1/homeworks/class/$classId/section/$sectionId',
      requiresAuth: true,
    );
  }
}