import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';

class SpeechController extends GetxController {
  final _recorder = AudioRecorder();
  final RxBool _isListening = false.obs;
  final RxString listenText = ''.obs;
  String? _recordingPath;

  final textController = Get.find<TextToSpeechController>();

  String get backendUrl => dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000';

  Future<void> listen(bool onlyListen) async {
    var status = await Permission.microphone.status;

    if (status.isDenied) {
      status = await Permission.microphone.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        Get.snackbar('Нет доступа',
            'Пожалуйста, предоставьте доступ к микрофону в настройках');
        return;
      }
    }

    if (!_isListening.value) {
      try {
        _isListening.value = true;

        // Get temporary directory for recording
        final tempDir = await getTemporaryDirectory();
        _recordingPath =
            '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Check if recorder has permission
        if (await _recorder.hasPermission()) {
          // Start recording
          await _recorder.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              sampleRate: 16000,
              bitRate: 128000,
            ),
            path: _recordingPath!,
          );

          if (kDebugMode) {
            print('Recording started at: $_recordingPath');
          }
        } else {
          throw Exception('No microphone permission');
        }
      } catch (e) {
        _isListening.value = false;
        Get.snackbar('Ошибка записи', 'Не удалось начать запись: $e');
        if (kDebugMode) {
          print('Error starting recording: $e');
        }
      }
    } else {
      // Stop recording and process
      await stopListening(onlyListen);
    }
  }

  Future<void> stopListening(bool onlyListen) async {
    if (!_isListening.value) return;

    try {
      _isListening.value = false;

      final path = await _recorder.stop();

      if (path != null && await File(path).exists()) {
        if (kDebugMode) {
          print('Recording stopped. File saved at: $path');
        }

        // Send to backend for transcription
        await _transcribeAudio(path, onlyListen);

        // Clean up the recording file
        try {
          await File(path).delete();
        } catch (e) {
          if (kDebugMode) {
            print('Error deleting recording file: $e');
          }
        }
      } else {
        throw Exception('Recording file not found');
      }
    } catch (e) {
      _isListening.value = false;
      Get.snackbar('Ошибка обработки', 'Не удалось обработать запись: $e');
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
    }
  }

  Future<void> _transcribeAudio(String audioPath, bool onlyListen) async {
    try {
      final audioFile = File(audioPath);

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/stt'),
      );

      // Add audio file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
          filename: 'audio.m4a',
        ),
      );

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Transcription request timed out');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Parse JSON response from STT endpoint
        final data = jsonDecode(response.body);
        final transcription = data['text'] as String? ?? '';
        final metrics = data['metrics'] as Map<String, dynamic>?;

        listenText.value = transcription;

        if (kDebugMode) {
          print('Transcription: $transcription');
          print('Metrics: $metrics');
        }

        // Generate response with text and metrics
        if (transcription.isNotEmpty) {
          await textController.generateText(
            transcription,
            onlyListen,
            metrics: metrics,
          );
        } else {
          Get.snackbar('Предупреждение', 'Не удалось распознать речь');
        }
      } else {
        throw Exception(
            'Transcription failed with status ${response.statusCode}');
      }
    } on SocketException {
      Get.snackbar('Ошибка соединения', 'Не удается подключиться к серверу');
    } on TimeoutException {
      Get.snackbar('Превышено время ожидания', 'Сервер не отвечает');
    } catch (e) {
      Get.snackbar('Ошибка транскрипции', 'Не удалось распознать речь: $e');
      if (kDebugMode) {
        print('Error transcribing audio: $e');
      }
    }
  }

  @override
  void onInit() {
    if (kDebugMode) {
      print('SpeechController initialized with custom backend');
    }
    super.onInit();
  }

  @override
  void onClose() {
    _recorder.dispose();
    super.onClose();
  }

  bool get isListening => _isListening.value;

  set isListening(bool value) {
    _isListening.value = value;
  }
}
