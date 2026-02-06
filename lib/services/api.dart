import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BackendService {
  static final String _baseUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:8000';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<String> sendChat(String message) async {
    try {
      final response = await _dio.post(
        '/chat/sync',
        data: {
          "message": message,
        },
      );

      return response.data['response'] ?? response.data.toString();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Uint8List> generateTts(String text) async {
    try {
      final response = await _dio.post(
        '/tts',
        data: {"text": text},
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      return Uint8List.fromList(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> transcribeAudio(String audioFilePath) async {
    try {
      String fileName = audioFilePath.split('/').last;

      // Create FormData for multipart upload
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          audioFilePath,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/stt',
        queryParameters: {"language": "ru"},
        data: formData,
      );

      return response.data['text'] ?? response.data.toString();
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (kDebugMode) {
        print(
            "API Error: ${error.response?.statusCode} - ${error.response?.statusMessage}");
      }
      return "Connection error: ${error.response?.statusCode}";
    }
    return "Unexpected error occurred";
  }
}
