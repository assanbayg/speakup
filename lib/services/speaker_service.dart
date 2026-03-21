import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Speaker {
  final String id;
  final String name;

  Speaker({required this.id, required this.name});

  factory Speaker.fromJson(String speakerId) {
    return Speaker(id: speakerId, name: _displayName(speakerId));
  }

  static String _displayName(String id) {
    const names = {
      'default': 'Стандартный голос',
    };
    return names[id] ?? id;
  }
}

class SpeakerService {
  static String get _baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

  static Future<List<Speaker>> fetchSpeakers() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/speakers'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final speakerIds = List<String>.from(data['speakers'] ?? []);
        return speakerIds.map((id) => Speaker.fromJson(id)).toList();
      } else {
        throw Exception('Failed to fetch speakers: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching speakers: $e');
      return [];
    }
  }

  /// Fetch a TTS preview clip for the given speaker.
  /// Timeout is 60s because XTTS on CPU takes 10-20s to synthesise.
  static Future<List<int>?> previewSpeaker(String speakerId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/tts'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': 'Привет! Давай поговорим.',
              'voice': speakerId,
            }),
          )
          .timeout(const Duration(seconds: 60));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
      if (kDebugMode) {
        print('Preview response: ${response.statusCode}, '
            'body length: ${response.bodyBytes.length}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error previewing speaker: $e');
      return null;
    }
  }
}
