import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Speaker {
  final String id;
  final String name;

  Speaker({required this.id, required this.name});

  factory Speaker.fromJson(String speakerId) {
    return Speaker(
      id: speakerId,
      name: speakerId,
    );
  }
}

class SpeakerService {
  static String get _baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

  /// Fetch available TTS speakers from backend
  static Future<List<Speaker>> fetchSpeakers() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/speakers'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final speakerIds = List<String>.from(data['speakers'] ?? []);
        return speakerIds.map((id) => Speaker.fromJson(id)).toList();
      } else {
        throw Exception('Failed to fetch speakers: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching speakers: $e');
      }
      return [];
    }
  }
}
