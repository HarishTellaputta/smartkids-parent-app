import 'package:http/http.dart' as http;

import 'api_service.dart';

class McqService {
  // ============================================================
  // GET AVAILABLE TESTS
  // ============================================================

  static Future<http.Response> getMcqTests() async {
    return await ApiService.get(
      '/api/v1/mcq-tests',
      requiresAuth: true,
    );
  }

  // ============================================================
  // START TEST
  // ============================================================

  static Future<http.Response> startMcqTest(
    int testId,
    int studentId,
  ) async {
    return await ApiService.post(
      '/api/v1/mcq-tests/$testId/start?studentId=$studentId',
      requiresAuth: true,
    );
  }

  // ============================================================
  // SUBMIT ANSWER
  // ============================================================

  static Future<http.Response> submitMcqAnswer(
    int attemptId,
    int studentId,
    int questionId,
    String answer,
  ) async {
    return await ApiService.put(
      '/api/v1/mcq-tests/attempts/$attemptId/answers'
      '?studentId=$studentId',
      body: {
        'questionId': questionId,
        'answer': answer,
      },
      requiresAuth: true,
    );
  }

  // ============================================================
  // SUBMIT TEST
  // ============================================================

  static Future<http.Response> submitMcqTest(
    int attemptId,
    int studentId,
  ) async {
    return await ApiService.post(
      '/api/v1/mcq-tests/attempts/$attemptId/submit'
      '?studentId=$studentId',
      requiresAuth: true,
    );
  }

  // ============================================================
  // STUDENT MCQ HISTORY
  // ============================================================

  static Future<http.Response> getMcqHistory(
    int studentId,
  ) async {
    return await ApiService.get(
      '/api/v1/mcq-tests/history/$studentId',
      requiresAuth: true,
    );
  }
}