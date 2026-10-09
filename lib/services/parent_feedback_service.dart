
import 'package:http/http.dart' as http;

import '../../../services/api_service.dart';
import '../models/parent_feedback.dart';

class ParentFeedbackService {
  static const String _endpoint = '/api/v1/parent-feedback';

  static Future<http.Response> submitFeedback(
    ParentFeedback feedback,
  ) {
    return ApiService.post(
      _endpoint,
      body: feedback.toRequestJson(),
      requiresAuth: true,
    );
  }
}
