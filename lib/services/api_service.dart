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

  static void _debugError(
    String method,
    String url,
    Object error,
  ) {
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
        headers: await _headers(
          requiresAuth: requiresAuth,
        ),
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
        headers: await _headers(
          requiresAuth: requiresAuth,
        ),
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
        headers: await _headers(
          requiresAuth: requiresAuth,
        ),
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
        headers: await _headers(
          requiresAuth: requiresAuth,
        ),
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

  static dynamic decodeResponse(
    http.Response response,
  ) {
    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }
}