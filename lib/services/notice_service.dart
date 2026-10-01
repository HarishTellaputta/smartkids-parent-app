import 'package:http/http.dart' as http;

import 'api_service.dart';

class NoticeService {
  // ============================================================
  // GET NOTICES
  // ============================================================

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

    return await ApiService.get(
      endpoint,
      requiresAuth: true,
    );
  }
}