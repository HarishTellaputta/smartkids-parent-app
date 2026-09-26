import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _roleKey = 'role';

  // =========================================================
  // SAVE LOGIN DATA
  // =========================================================

  static Future<void> saveLoginData({
    required String token,
    required int userId,
    required String username,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_roleKey, role);
  }

  // =========================================================
  // GET TOKEN
  // =========================================================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // =========================================================
  // GET USER ID
  // =========================================================

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // =========================================================
  // GET USERNAME
  // =========================================================

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // =========================================================
  // GET ROLE
  // =========================================================

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // =========================================================
  // CHECK LOGIN
  // =========================================================

  static Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  // =========================================================
  // CLEAR LOGIN DATA
  // =========================================================

  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_roleKey);
  }
}