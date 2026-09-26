import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/local_storage.dart';

class ApiService {
  // ============================================================
  // COMMON HEADERS
  // ============================================================

  static Future<Map<String, String>> _headers({
    bool requiresAuth = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await LocalStorage.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ============================================================
  // DEBUG LOGGER
  // ============================================================

  static void _debugResponse(
    String method,
    String url,
    http.Response response,
  ) {
    print('════════════════════════════════════════════════════');
    print('🌐 API $method');
    print('➡️ URL: $url');
    print('📥 STATUS: ${response.statusCode}');
    print('📦 RESPONSE: ${response.body}');
    print('════════════════════════════════════════════════════');
  }

  static void _debugError(String method, String url, Object error) {
    print('════════════════════════════════════════════════════');
    print('❌ API ERROR');
    print('🌐 METHOD: $method');
    print('➡️ URL: $url');
    print('💥 ERROR: $error');
    print('════════════════════════════════════════════════════');
  }

  // ============================================================
  // POST
  // ============================================================

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final url = '${ApiConfig.baseUrl}$endpoint';

    try {
      print('🚀 POST: $url');

      if (body != null) {
        print('📤 BODY: $body');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: await _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      _debugResponse('POST', url, response);

      return response;
    } catch (e) {
      _debugError('POST', url, e);
      rethrow;
    }
  }

  // ============================================================
  // GET
  // ============================================================

  static Future<http.Response> get(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    final url = '${ApiConfig.baseUrl}$endpoint';

    try {
      print('🚀 GET: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: await _headers(requiresAuth: requiresAuth),
      );

      _debugResponse('GET', url, response);

      return response;
    } catch (e) {
      _debugError('GET', url, e);
      rethrow;
    }
  }

  // ============================================================
  // PUT
  // ============================================================

  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final url = '${ApiConfig.baseUrl}$endpoint';

    try {
      print('🚀 PUT: $url');

      if (body != null) {
        print('📤 BODY: $body');
      }

      final response = await http.put(
        Uri.parse(url),
        headers: await _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      _debugResponse('PUT', url, response);

      return response;
    } catch (e) {
      _debugError('PUT', url, e);
      rethrow;
    }
  }

  // ============================================================
  // DELETE
  // ============================================================
  static Future<http.Response> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final url = '${ApiConfig.baseUrl}$endpoint';

    try {
      print('🚀 DELETE: $url');

      if (body != null) {
        print('📤 BODY: $body');
      }

      final response = await http.delete(
        Uri.parse(url),
        headers: await _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      );

      _debugResponse('DELETE', url, response);

      return response;
    } catch (e) {
      _debugError('DELETE', url, e);
      rethrow;
    }
  }
  // ============================================================
  // JSON HELPER
  // ============================================================

  static dynamic decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  // ============================================================
  // BIRTHDAY CHAT - STUDENT DETAILS
  // ============================================================

  static Future<http.Response> getBirthdayChat() async {
    return await get(
      '/api/v1/student-birthday-status/chat',
      requiresAuth: true,
    );
  }

  // ============================================================
  // BIRTHDAY CHAT - GET MESSAGES
  // ============================================================

  static Future<http.Response> getBirthdayMessages(int studentId) async {
    return await get('/api/v1/birthday-chat/$studentId', requiresAuth: true);
  }

  // ============================================================
  // BIRTHDAY CHAT - SEND MESSAGE
  // ============================================================

  static Future<http.Response> sendBirthdayMessage(
    int studentId,
    String message,
  ) async {
    return await post(
      '/api/v1/birthday-chat/$studentId/messages',
      body: {'message': message, 'replyToMessageId': null},
      requiresAuth: true,
    );
  }

  // ============================================================
  // BIRTHDAY CHAT - EDIT MESSAGE
  // ============================================================

  static Future<http.Response> editBirthdayMessage(
    int messageId,
    String message,
  ) async {
    return await put(
      '/api/v1/birthday-chat/messages/$messageId',
      body: {'message': message},
      requiresAuth: true,
    );
  }

  // ============================================================
  // BIRTHDAY CHAT - DELETE MESSAGE
  // ============================================================

  static Future<http.Response> deleteBirthdayMessage(int messageId) async {
    return await delete(
      '/api/v1/birthday-chat/messages/$messageId',
      requiresAuth: true,
    );
  }

  // ============================================================
  // BIRTHDAY CHAT - REPLY
  // ============================================================

  static Future<http.Response> replyToBirthdayMessage(
    int messageId,
    String message,
  ) async {
    return await post(
      '/api/v1/birthday-chat/messages/$messageId/reply',
      body: {'message': message, 'replyToMessageId': messageId},
      requiresAuth: true,
    );
  }

  // ============================================================
  // BIRTHDAY CHAT - ADD REACTION
  // ============================================================

  static Future<http.Response> addBirthdayReaction(
    int messageId,
    String reaction,
  ) async {
    return await post(
      '/api/v1/birthday-chat/messages/$messageId/reaction',
      body: {'reaction': reaction},
      requiresAuth: true,
    );
  }

  // ============================================================
  // BIRTHDAY CHAT - REMOVE REACTION
  // ============================================================
  static Future<http.Response> removeBirthdayReaction(
    int messageId,
    String reaction,
  ) async {
    return await delete(
      '/api/v1/birthday-chat/messages/$messageId/reaction',
      body: {'reaction': reaction},
      requiresAuth: true,
    );
  }

  // ============================================================
  // PARENT - GET LOGGED-IN PARENT PROFILE + CHILDREN
  // ============================================================

  static Future<http.Response> getMyParentProfile() async {
    return await get('/api/v1/parents/me', requiresAuth: true);
  }

  // ============================================================
  // ATTENDANCE - STUDENT DATE RANGE
  // ============================================================

  static Future<http.Response> getStudentAttendance(
    int studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = startDate.toIso8601String().split('T').first;
    final end = endDate.toIso8601String().split('T').first;

    return await get(
      '/api/v1/attendances/student/$studentId'
      '?startDate=$start&endDate=$end',
      requiresAuth: true,
    );
  }

  // ============================================================
  // ATTENDANCE - STUDENT REPORT
  // ============================================================

  static Future<http.Response> getStudentAttendanceReport(
    int studentId,
    int classId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = startDate.toIso8601String().split('T').first;
    final end = endDate.toIso8601String().split('T').first;

    return await get(
      '/api/v1/attendances/student/$studentId/report'
      '?classId=$classId'
      '&startDate=$start'
      '&endDate=$end',
      requiresAuth: true,
    );
  }

  // ============================================================
  // ATTENDANCE - STUDENT PERCENTAGE
  // ============================================================

  static Future<http.Response> getStudentAttendancePercentage(
    int studentId,
    int classId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = startDate.toIso8601String().split('T').first;
    final end = endDate.toIso8601String().split('T').first;

    return await get(
      '/api/v1/attendances/student/$studentId/percentage'
      '?classId=$classId'
      '&startDate=$start'
      '&endDate=$end',
      requiresAuth: true,
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<http.Response> logout() async {
    return await post('/auth/logout', requiresAuth: true);
  }

  // ============================================================
  // FEES - STUDENT FEES
  // ============================================================

  static Future<http.Response> getStudentFees(
    int studentId, {
    bool pending = false,
  }) async {
    return await get(
      '/api/v1/fees/students/$studentId?pending=$pending',
      requiresAuth: true,
    );
  }

  // ============================================================
  // EXAMINATION - STUDENT RESULTS
  // ============================================================

  static Future<http.Response> getStudentExamResults(int studentId) async {
    return await get(
      '/api/v1/examinations/results?studentId=$studentId',
      requiresAuth: true,
    );
  }

  // ============================================================
  // EXAMINATION - SCHEDULES
  // ============================================================

  static Future<http.Response> getExamSchedules({
    int? examinationId,
    int? classId,
    int? sectionId,
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

    final query = params.isEmpty ? '' : '?${params.join('&')}';

    return await get(
      '/api/v1/examinations/schedules$query',
      requiresAuth: true,
    );
  }

  // ============================================================
  // FEES - STUDENT PAYMENT HISTORY
  // ============================================================

  static Future<http.Response> getStudentPayments(int studentId) async {
    return await get(
      '/api/v1/fees/payments?studentId=$studentId',
      requiresAuth: true,
    );
  }

  // ============================================================
  // MCQ - GET AVAILABLE TESTS
  // ============================================================

  static Future<http.Response> getMcqTests() async {
    return await get('/api/v1/mcq-tests', requiresAuth: true);
  }

  // ============================================================
  // MCQ - START TEST
  // ============================================================

  static Future<http.Response> startMcqTest(int testId, int studentId) async {
    return await post(
      '/api/v1/mcq-tests/$testId/start?studentId=$studentId',
      requiresAuth: true,
    );
  }

  // ============================================================
  // MCQ - SUBMIT ANSWER
  // ============================================================

  static Future<http.Response> submitMcqAnswer(
    int attemptId,
    int studentId,
    int questionId,
    String answer,
  ) async {
    return await put(
      '/api/v1/mcq-tests/attempts/$attemptId/answers'
      '?studentId=$studentId',
      body: {'questionId': questionId, 'answer': answer},
      requiresAuth: true,
    );
  }

  // ============================================================
  // MCQ - SUBMIT TEST
  // ============================================================

  static Future<http.Response> submitMcqTest(
    int attemptId,
    int studentId,
  ) async {
    return await post(
      '/api/v1/mcq-tests/attempts/$attemptId/submit'
      '?studentId=$studentId',
      requiresAuth: true,
    );
  }

  // ============================================================
  // MCQ - STUDENT HISTORY
  // ============================================================

  static Future<http.Response> getMcqHistory(int studentId) async {
    return await get(
      '/api/v1/mcq-tests/history/$studentId',
      requiresAuth: true,
    );
  }

  static Future<http.Response> getStudentTimetable(int studentId) async {
    return await get(
      '/api/v1/teacher-timetables/student/$studentId',
      requiresAuth: true,
    );
  }

  static Future<http.Response> getStudentHomework(
    int classId,
    int sectionId,
  ) async {
    return await get(
      '/api/v1/homeworks/class/$classId/section/$sectionId',
      requiresAuth: true,
    );
  }

  static Future<http.Response> getNotices({
    int? classId,
    int? sectionId,
  }) async {
    String endpoint = '/api/v1/notices';

    final params = <String>[];

    if (classId != null) {
      params.add('classId=$classId');
    }

    if (sectionId != null) {
      params.add('sectionId=$sectionId');
    }

    if (params.isNotEmpty) {
      endpoint += '?${params.join('&')}';
    }

    return await get(endpoint, requiresAuth: true);
  }
}
