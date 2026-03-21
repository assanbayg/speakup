import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SessionService {
  static String get _baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

  static Future<String?> startSession(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/session/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['session_id'] as String?;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> endSession(String sessionId, int messageCount) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/session/end'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': sessionId,
          'message_count': messageCount,
        }),
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<Map<String, dynamic>> getProgress(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/session/progress/$userId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }
}
