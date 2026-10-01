import 'package:http/http.dart' as http;

import 'api_service.dart';

class FeeService {
  // ============================================================
  // STUDENT FEES
  // ============================================================

  static Future<http.Response> getStudentFees(
    int studentId, {
    bool pending = false,
  }) async {
    return await ApiService.get(
      '/api/v1/fees/students/$studentId?pending=$pending',
      requiresAuth: true,
    );
  }

  // ============================================================
  // STUDENT PAYMENT HISTORY
  // ============================================================

  static Future<http.Response> getStudentPayments(
    int studentId,
  ) async {
    return await ApiService.get(
      '/api/v1/fees/payments?studentId=$studentId',
      requiresAuth: true,
    );
  }
}