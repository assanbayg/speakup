import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class VoiceInfo {
  final String voiceId;
  final String voiceName;
  final double duration;
  final String createdAt;
  final Map<String, dynamic>? metadata;

  VoiceInfo({
    required this.voiceId,
    required this.voiceName,
    required this.duration,
    required this.createdAt,
    this.metadata,
  });

  factory VoiceInfo.fromJson(Map<String, dynamic> json) {
    return VoiceInfo(
      voiceId: json['voice_id'] ?? '',
      voiceName: json['voice_name'] ?? 'Голос',
      duration: (json['preprocessing']?['processed_duration'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
      metadata: json,
    );
  }
}

class VoiceValidationResult {
  final bool valid;
  final double duration;
  final int sampleRate;
  final int channels;
  final List<String> errors;
  final List<String> warnings;
  final List<String> recommendations;

  VoiceValidationResult({
    required this.valid,
    required this.duration,
    required this.sampleRate,
    required this.channels,
    required this.errors,
    required this.warnings,
    required this.recommendations,
  });

  factory VoiceValidationResult.fromJson(Map<String, dynamic> json) {
    return VoiceValidationResult(
      valid: json['valid'] ?? false,
      duration: (json['duration'] ?? 0).toDouble(),
      sampleRate: json['sample_rate'] ?? 0,
      channels: json['channels'] ?? 0,
      errors: List<String>.from(json['errors'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

class VoiceService {
  static String get _baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

  /// Validate audio file before upload
  static Future<VoiceValidationResult> validateAudio(File audioFile) async {
    try {
      final uri = Uri.parse('$_baseUrl/voices/validate');
      final request = http.MultipartRequest('POST', uri);

      final filename = audioFile.path.split('/').last.toLowerCase();
      MediaType? contentType = _getContentType(filename);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
          filename: filename,
          contentType: contentType,
        ),
      );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
          );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return VoiceValidationResult.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        return VoiceValidationResult(
          valid: false,
          duration: 0,
          sampleRate: 0,
          channels: 0,
          errors: [error['detail'] ?? 'Ошибка валидации'],
          warnings: [],
          recommendations: [],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error validating audio: $e');
      }
      return VoiceValidationResult(
        valid: false,
        duration: 0,
        sampleRate: 0,
        channels: 0,
        errors: ['Ошибка соединения: $e'],
        warnings: [],
        recommendations: [],
      );
    }
  }

  /// Upload voice sample for cloning
  static Future<Map<String, dynamic>> uploadVoice({
    required String userId,
    required File audioFile,
    String? voiceName,
  }) async {
    try {
      var uri = Uri.parse('$_baseUrl/voices/upload').replace(
        queryParameters: {
          'user_id': userId,
          if (voiceName != null) 'voice_name': voiceName,
        },
      );

      final request = http.MultipartRequest('POST', uri);

      final filename = audioFile.path.split('/').last.toLowerCase();
      MediaType? contentType = _getContentType(filename);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
          filename: filename,
          contentType: contentType,
        ),
      );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 60), // Longer timeout for processing
          );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Upload failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading voice: $e');
      }
      rethrow;
    }
  }

  /// List all voices for a user
  static Future<List<VoiceInfo>> listVoices(String userId) async {
    try {
      final uri = Uri.parse('$_baseUrl/voices/list').replace(
        queryParameters: {'user_id': userId},
      );

      final response = await http.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final voices = List<Map<String, dynamic>>.from(data['voices'] ?? []);
        return voices.map((v) => VoiceInfo.fromJson(v)).toList();
      } else {
        throw Exception('Failed to list voices: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error listing voices: $e');
      }
      return [];
    }
  }

  /// Get user's default voice ID
  static Future<String?> getDefaultVoice(String userId) async {
    try {
      final uri = Uri.parse('$_baseUrl/voices/list').replace(
        queryParameters: {'user_id': userId},
      );

      final response = await http.get(uri).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['default_voice_id'];
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting default voice: $e');
      }
      return null;
    }
  }

  /// Set default voice for user
  static Future<bool> setDefaultVoice(String userId, String voiceId) async {
    try {
      final uri = Uri.parse('$_baseUrl/voices/set-default').replace(
        queryParameters: {
          'user_id': userId,
          'voice_id': voiceId,
        },
      );

      final response = await http.post(uri).timeout(
            const Duration(seconds: 10),
          );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error setting default voice: $e');
      }
      return false;
    }
  }

  /// Delete a voice
  static Future<bool> deleteVoice(String userId, String voiceId) async {
    try {
      final uri = Uri.parse('$_baseUrl/voices/$userId/$voiceId');

      final response = await http.delete(uri).timeout(
            const Duration(seconds: 10),
          );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting voice: $e');
      }
      return false;
    }
  }

  /// Get preview URL for a voice
  static String getPreviewUrl(String userId, String voiceId, {String? text}) {
    final params = {
      if (text != null) 'text': text,
    };
    return Uri.parse('$_baseUrl/voices/preview/$userId/$voiceId')
        .replace(queryParameters: params.isEmpty ? null : params)
        .toString();
  }

  /// Preview voice with custom text (returns audio bytes)
  static Future<Uint8List?> previewVoice({
    required String userId,
    required String voiceId,
    String text = 'Привет! Это мой голос.',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/voices/preview'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'voice_id': voiceId,
              'text': text,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error previewing voice: $e');
      }
      return null;
    }
  }

  static MediaType? _getContentType(String filename) {
    if (filename.endsWith('.wav')) {
      return MediaType('audio', 'wav');
    } else if (filename.endsWith('.mp3')) {
      return MediaType('audio', 'mpeg');
    } else if (filename.endsWith('.m4a')) {
      return MediaType('audio', 'mp4');
    } else if (filename.endsWith('.ogg')) {
      return MediaType('audio', 'ogg');
    } else if (filename.endsWith('.webm')) {
      return MediaType('audio', 'webm');
    }
    return null;
  }
}
