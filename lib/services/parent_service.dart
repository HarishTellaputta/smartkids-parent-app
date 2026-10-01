import 'package:http/http.dart' as http;

import 'api_service.dart';

class ParentService {
  // ============================================================
  // GET LOGGED-IN PARENT PROFILE + CHILDREN
  // ============================================================

  static Future<http.Response> getMyParentProfile() async {
    return await ApiService.get(
      '/api/v1/parents/me',
      requiresAuth: true,
    );
  }
}