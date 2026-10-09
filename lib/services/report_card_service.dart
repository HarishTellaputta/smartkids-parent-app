
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_service.dart';

class ReportCardService {
  /// Downloads the report card as a TXT file.
  static Future<void> downloadReportCard({
    required int studentId,
    required int examinationId,
  }) async {
    final http.Response response = await ApiService.get(
      '/api/v1/report-cards/$studentId/$examinationId/download',
      requiresAuth: true,
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 401 ||
          response.statusCode == 403) {
        throw Exception(
          'You are not authorized to download this report card.',
        );
      }

      throw Exception(
        'Failed to download report card. '
        'Status: ${response.statusCode}',
      );
    }

    if (response.bodyBytes.isEmpty) {
      throw Exception('Report card file is empty.');
    }

    final Uint8List bytes = response.bodyBytes;

    final blob = html.Blob(
      [bytes],
      'text/plain;charset=utf-8',
    );

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..download = 'report-card-$studentId-$examinationId.txt'
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
  }
}
