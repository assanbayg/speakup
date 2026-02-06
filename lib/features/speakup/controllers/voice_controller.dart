import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speakup/services/voice_service.dart';
import 'package:speakup/util/helpers/helper_functions.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';

class VoiceController extends GetxController {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  // Observable state
  final RxList<VoiceInfo> availableVoices = <VoiceInfo>[].obs;
  final Rx<String?> defaultVoiceId = Rx<String?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isRecording = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isPreviewing = false.obs;
  final Rx<VoiceValidationResult?> lastValidation =
      Rx<VoiceValidationResult?>(null);
  final RxDouble recordingDuration = 0.0.obs;
  final Rx<String?> recordingPath = Rx<String?>(null);

  String? get userId => SSupabaseHelper.currentUser?.id;

  // Recording timer
  DateTime? _recordingStartTime;

  @override
  void onInit() {
    super.onInit();
    loadVoices();

    // Listen to player state
    _player.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });
  }

  @override
  void onClose() {
    _recorder.dispose();
    _player.dispose();
    super.onClose();
  }

  /// Load available voices from backend
  Future<void> loadVoices() async {
    if (userId == null) return;

    isLoading.value = true;
    try {
      final voices = await VoiceService.listVoices(userId!);
      availableVoices.value = voices;

      final defaultId = await VoiceService.getDefaultVoice(userId!);
      defaultVoiceId.value = defaultId;

      if (kDebugMode) {
        print('Loaded ${voices.length} voices, default: $defaultId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading voices: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Start recording voice sample
  Future<void> startRecording() async {
    var status = await Permission.microphone.status;

    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        SHelperFunctions.showSnackBar(
          'Пожалуйста, предоставьте доступ к микрофону в настройках',
        );
        return;
      }
    }

    try {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path =
            '${tempDir.path}/voice_sample_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            sampleRate: 22050, // Higher quality for voice cloning
            bitRate: 192000,
          ),
          path: path,
        );

        recordingPath.value = path;
        isRecording.value = true;
        _recordingStartTime = DateTime.now();
        recordingDuration.value = 0;

        // Update duration every 100ms
        _updateRecordingDuration();

        if (kDebugMode) {
          print('Recording started at: $path');
        }
      }
    } catch (e) {
      SHelperFunctions.showSnackBar('Не удалось начать запись: $e');
      if (kDebugMode) {
        print('Error starting recording: $e');
      }
    }
  }

  void _updateRecordingDuration() async {
    while (isRecording.value && _recordingStartTime != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_recordingStartTime != null) {
        recordingDuration.value =
            DateTime.now().difference(_recordingStartTime!).inMilliseconds /
                1000.0;
      }
    }
  }

  /// Stop recording
  Future<File?> stopRecording() async {
    if (!isRecording.value) return null;

    try {
      final path = await _recorder.stop();
      await Future.delayed(const Duration(milliseconds: 200));
      if (path != null) {
        final file = File(path);

        // Verify file
        print('🔍 File exists: ${await file.exists()}');
        print('🔍 File size: ${await file.length()} bytes');
        print('🔍 File path: $path');

        // Get duration from actual audio file
        // (show me how you're calculating duration and I'll fix it)
      }
      isRecording.value = false;
      _recordingStartTime = null;

      if (path != null && await File(path).exists()) {
        recordingPath.value = path;
        if (kDebugMode) {
          print('Recording stopped: $path');
        }
        return File(path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
    }

    isRecording.value = false;
    return null;
  }

  /// Cancel recording
  Future<void> cancelRecording() async {
    if (isRecording.value) {
      await _recorder.stop();
      isRecording.value = false;
      _recordingStartTime = null;
    }

    // Clean up file
    if (recordingPath.value != null) {
      try {
        await File(recordingPath.value!).delete();
      } catch (_) {}
    }
    recordingPath.value = null;
    recordingDuration.value = 0;
    lastValidation.value = null;
  }

  /// Validate recorded audio
  Future<VoiceValidationResult?> validateRecording() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Small delay

    if (recordingPath.value == null) return null;

    final file = File(recordingPath.value!);
    if (!await file.exists()) return null;

    isLoading.value = true;
    try {
      final result = await VoiceService.validateAudio(file);
      lastValidation.value = result;
      return result;
    } finally {
      isLoading.value = false;
    }
  }

  /// Upload and process voice sample
  Future<bool> uploadVoice({String? voiceName}) async {
    if (userId == null) {
      SHelperFunctions.showSnackBar('Пожалуйста, войдите в систему');
      return false;
    }

    if (recordingPath.value == null) {
      SHelperFunctions.showSnackBar('Сначала запишите голос');
      return false;
    }

    final file = File(recordingPath.value!);
    if (!await file.exists()) {
      SHelperFunctions.showSnackBar('Файл записи не найден');
      return false;
    }

    isUploading.value = true;
    try {
      final result = await VoiceService.uploadVoice(
        userId: userId!,
        audioFile: file,
        voiceName: voiceName ?? 'Голос родителя',
      );

      if (result['ok'] == true) {
        SHelperFunctions.showSnackBar('Голос успешно сохранён!');

        // Refresh voice list
        await loadVoices();

        // Clean up recording
        await _cleanupRecording();

        return true;
      }
    } catch (e) {
      SHelperFunctions.showSnackBar('Ошибка загрузки: $e');
    } finally {
      isUploading.value = false;
    }

    return false;
  }

  /// Play recording preview
  Future<void> playRecording() async {
    if (recordingPath.value == null) return;

    if (isPlaying.value) {
      await _player.stop();
      return;
    }

    try {
      await _player.play(DeviceFileSource(recordingPath.value!));
    } catch (e) {
      if (kDebugMode) {
        print('Error playing recording: $e');
      }
    }
  }

  /// Preview cloned voice with TTS
  Future<void> previewVoice(String voiceId) async {
    if (userId == null) return;

    if (isPreviewing.value) {
      await _player.stop();
      isPreviewing.value = false;
      return;
    }

    isPreviewing.value = true;
    try {
      final audioBytes = await VoiceService.previewVoice(
        userId: userId!,
        voiceId: voiceId,
        text: 'Привет! Это мой голос. Как дела?',
      );

      if (audioBytes != null) {
        // Save to temp file and play
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/preview_$voiceId.mp3');
        await tempFile.writeAsBytes(audioBytes);

        await _player.play(DeviceFileSource(tempFile.path));
      } else {
        SHelperFunctions.showSnackBar('Не удалось загрузить предпросмотр');
      }
    } catch (e) {
      SHelperFunctions.showSnackBar('Ошибка предпросмотра: $e');
    } finally {
      isPreviewing.value = false;
    }
  }

  /// Set voice as default
  Future<void> setDefaultVoice(String voiceId) async {
    if (userId == null) return;

    isLoading.value = true;
    try {
      final success = await VoiceService.setDefaultVoice(userId!, voiceId);
      if (success) {
        defaultVoiceId.value = voiceId;
        SHelperFunctions.showSnackBar('Голос установлен по умолчанию');
      } else {
        SHelperFunctions.showSnackBar('Не удалось установить голос');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Clear default voice (use system default)
  Future<void> clearDefaultVoice() async {
    defaultVoiceId.value = null;
    SHelperFunctions.showSnackBar('Используется стандартный голос');
  }

  /// Delete a voice
  Future<void> deleteVoice(String voiceId) async {
    if (userId == null) return;

    isLoading.value = true;
    try {
      final success = await VoiceService.deleteVoice(userId!, voiceId);
      if (success) {
        availableVoices.removeWhere((v) => v.voiceId == voiceId);
        if (defaultVoiceId.value == voiceId) {
          defaultVoiceId.value = null;
        }
        SHelperFunctions.showSnackBar('Голос удалён');
      } else {
        SHelperFunctions.showSnackBar('Не удалось удалить голос');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if a voice is the default
  bool isDefault(String voiceId) => defaultVoiceId.value == voiceId;

  /// Get formatted duration string
  String formatDuration(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _cleanupRecording() async {
    if (recordingPath.value != null) {
      try {
        await File(recordingPath.value!).delete();
      } catch (_) {}
    }
    recordingPath.value = null;
    recordingDuration.value = 0;
    lastValidation.value = null;
  }
}
