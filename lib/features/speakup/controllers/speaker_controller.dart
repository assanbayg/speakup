import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speakup/services/speaker_service.dart';
import 'package:speakup/util/helpers/helper_functions.dart';

class SpeakerController extends GetxController {
  final RxList<Speaker> availableSpeakers = <Speaker>[].obs;
  final Rx<Speaker?> selectedSpeaker = Rx<Speaker?>(null);
  final RxBool isLoading = false.obs;

  // null = idle, set = fetching audio for this speaker id
  final Rx<String?> loadingPreviewId = Rx<String?>(null);

  // null = nothing playing, set = this speaker's audio is playing
  final Rx<String?> playingPreviewId = Rx<String?>(null);

  final _player = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    loadSpeakers();
    _player.onPlayerComplete.listen((_) {
      playingPreviewId.value = null;
    });
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }

  Future<void> loadSpeakers() async {
    isLoading.value = true;
    try {
      final speakers = await SpeakerService.fetchSpeakers();
      availableSpeakers.value = speakers;
      if (selectedSpeaker.value == null && speakers.isNotEmpty) {
        selectedSpeaker.value = speakers.first;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectSpeaker(Speaker speaker) {
    selectedSpeaker.value = speaker;
  }

  String? get selectedSpeakerId => selectedSpeaker.value?.id;
  bool isSelected(Speaker speaker) => selectedSpeaker.value?.id == speaker.id;
  bool isLoadingPreview(Speaker speaker) =>
      loadingPreviewId.value == speaker.id;
  bool isPlayingPreview(Speaker speaker) =>
      playingPreviewId.value == speaker.id;

  Future<void> togglePreview(Speaker speaker) async {
    // Already playing this one — stop it
    if (playingPreviewId.value == speaker.id) {
      await _player.stop();
      playingPreviewId.value = null;
      return;
    }

    // Already loading this one — ignore double tap
    if (loadingPreviewId.value == speaker.id) return;

    // Stop any other playback
    await _player.stop();
    playingPreviewId.value = null;

    loadingPreviewId.value = speaker.id;

    try {
      final bytes = await SpeakerService.previewSpeaker(speaker.id);

      // User cancelled while we were waiting
      if (loadingPreviewId.value != speaker.id) return;

      if (bytes == null || bytes.isEmpty) {
        SHelperFunctions.showSnackBar('Не удалось загрузить предпросмотр');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      // Sanitise ID for use in filename
      final safeId = speaker.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final file = File('${tempDir.path}/speaker_preview_$safeId.mp3');
      await file.writeAsBytes(bytes);

      if (loadingPreviewId.value != speaker.id) return;

      loadingPreviewId.value = null;
      playingPreviewId.value = speaker.id;
      await _player.play(DeviceFileSource(file.path));
    } catch (e) {
      if (kDebugMode) print('Preview error: $e');
      SHelperFunctions.showSnackBar('Ошибка предпросмотра — попробуйте позже');
    } finally {
      if (loadingPreviewId.value == speaker.id) {
        loadingPreviewId.value = null;
      }
    }
  }
}
