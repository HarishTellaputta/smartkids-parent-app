import 'package:http/http.dart' as http;

import 'api_service.dart';

class BirthdayChatService {
  // ============================================================
  // GET BIRTHDAY STUDENTS
  // ============================================================

  static Future<http.Response> getBirthdayChat() async {
    return await ApiService.get(
      '/api/v1/student-birthday-status/chat',
      requiresAuth: true,
    );
  }

  // ============================================================
  // GET BIRTHDAY MESSAGES
  // ============================================================

  static Future<http.Response> getBirthdayMessages(
    int studentId,
  ) async {
    return await ApiService.get(
      '/api/v1/birthday-chat/$studentId',
      requiresAuth: true,
    );
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  static Future<http.Response> sendBirthdayMessage(
    int studentId,
    String message,
  ) async {
    return await ApiService.post(
      '/api/v1/birthday-chat/$studentId/messages',
      body: {
        'message': message,
        'replyToMessageId': null,
      },
      requiresAuth: true,
    );
  }

  // ============================================================
  // EDIT MESSAGE
  // ============================================================

  static Future<http.Response> editBirthdayMessage(
    int messageId,
    String message,
  ) async {
    return await ApiService.put(
      '/api/v1/birthday-chat/messages/$messageId',
      body: {
        'message': message,
      },
      requiresAuth: true,
    );
  }

  // ============================================================
  // DELETE MESSAGE
  // ============================================================

  static Future<http.Response> deleteBirthdayMessage(
    int messageId,
  ) async {
    return await ApiService.delete(
      '/api/v1/birthday-chat/messages/$messageId',
      requiresAuth: true,
    );
  }

  // ============================================================
  // REPLY
  // ============================================================

  static Future<http.Response> replyToBirthdayMessage(
    int messageId,
    String message,
  ) async {
    return await ApiService.post(
      '/api/v1/birthday-chat/messages/$messageId/reply',
      body: {
        'message': message,
        'replyToMessageId': messageId,
      },
      requiresAuth: true,
    );
  }

  // ============================================================
  // ADD REACTION
  // ============================================================

  static Future<http.Response> addBirthdayReaction(
    int messageId,
    String reaction,
  ) async {
    return await ApiService.post(
      '/api/v1/birthday-chat/messages/$messageId/reaction',
      body: {
        'reaction': reaction,
      },
      requiresAuth: true,
    );
  }

  // ============================================================
  // REMOVE REACTION
  // ============================================================

  static Future<http.Response> removeBirthdayReaction(
    int messageId,
    String reaction,
  ) async {
    return await ApiService.delete(
      '/api/v1/birthday-chat/messages/$messageId/reaction',
      body: {
        'reaction': reaction,
      },
      requiresAuth: true,
    );
  }
}