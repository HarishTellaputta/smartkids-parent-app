import 'package:http/http.dart' as http;

import 'api_service.dart';

class AuthService {
  // ============================================================
  // LOGIN
  // ============================================================

  static Future<http.Response> login({
    required String username,
    required String password,
  }) async {
    return await ApiService.post(
      '/auth/login',
      body: {
        'username': username,
        'password': password,
      },
    );
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  static Future<http.Response> forgotPassword({
    required String email,
  }) async {
    return await ApiService.post(
      '/auth/forgot-password',
      body: {
        'email': email,
      },
    );
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  static Future<http.Response> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await ApiService.post(
      '/auth/reset-password',
      body: {
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  static Future<http.Response> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await ApiService.post(
      '/auth/change-password',
      requiresAuth: true,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  static Future<http.Response> logout() async {
    return await ApiService.post(
      '/auth/logout',
      requiresAuth: true,
    );
  }
}