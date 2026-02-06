import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SpriteInfo {
  final String filename;
  final String url;

  SpriteInfo({required this.filename, required this.url});
}

class SpriteService {
  static String get _baseUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

  /// Upload a sprite image for review (pending approval)
  static Future<Map<String, dynamic>> uploadPendingSprite({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/sprites/upload-pending')
          .replace(queryParameters: {'user_id': userId});

      final request = http.MultipartRequest('POST', uri);

      // Determine content type from extension
      final filename = imageFile.path.split('/').last.toLowerCase();
      MediaType? contentType;
      if (filename.endsWith('.jpg') || filename.endsWith('.jpeg')) {
        contentType = MediaType('image', 'jpeg');
      } else if (filename.endsWith('.png')) {
        contentType = MediaType('image', 'png');
      } else if (filename.endsWith('.webp')) {
        contentType = MediaType('image', 'webp');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: filename,
          contentType: contentType,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading sprite: $e');
      }
      rethrow;
    }
  }

  /// List all approved sprites for a user
  static Future<List<String>> listApprovedSprites(String userId) async {
    try {
      final uri = Uri.parse('$_baseUrl/sprites/list')
          .replace(queryParameters: {'user_id': userId});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sprites = List<String>.from(data['sprites'] ?? []);
        return sprites;
      } else {
        throw Exception('Failed to list sprites: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error listing sprites: $e');
      }
      return [];
    }
  }

  /// Get the URL for a sprite image
  static String getSpriteImageUrl(String userId, String filename) {
    return '$_baseUrl/sprites/image/$userId/$filename';
  }

  /// Download sprite image bytes (for caching or display)
  static Future<Uint8List?> getSpriteBytes(
      String userId, String filename) async {
    try {
      final url = getSpriteImageUrl(userId, filename);
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 302 || response.statusCode == 307) {
        // Handle redirect
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          final redirectResponse = await http.get(Uri.parse(redirectUrl));
          if (redirectResponse.statusCode == 200) {
            return redirectResponse.bodyBytes;
          }
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sprite bytes: $e');
      }
      return null;
    }
  }
}
