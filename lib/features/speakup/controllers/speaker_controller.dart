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

  // Preview state
  final Rx<String?> previewingId = Rx<String?>(null);
  final _player = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    loadSpeakers();
    _player.onPlayerComplete.listen((_) {
      previewingId.value = null;
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

  bool isPreviewing(Speaker speaker) => previewingId.value == speaker.id;

  /// Toggle preview for a speaker. Stops if already playing this one.
  Future<void> togglePreview(Speaker speaker) async {
    // Already previewing this speaker — stop
    if (previewingId.value == speaker.id) {
      await _player.stop();
      previewingId.value = null;
      return;
    }

    // Stop any current preview first
    await _player.stop();
    previewingId.value = speaker.id;

    try {
      final bytes = await SpeakerService.previewSpeaker(speaker.id);
      if (bytes == null || bytes.isEmpty) {
        previewingId.value = null;
        SHelperFunctions.showSnackBar('Не удалось загрузить предпросмотр');
        return;
      }

      // Write to temp file and play
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/speaker_preview_${speaker.id}.mp3');
      await file.writeAsBytes(bytes);

      // Check that this preview is still wanted (user may have tapped elsewhere)
      if (previewingId.value != speaker.id) return;

      await _player.play(DeviceFileSource(file.path));
    } catch (e) {
      previewingId.value = null;
      if (kDebugMode) print('Preview error: $e');
      SHelperFunctions.showSnackBar('Ошибка предпросмотра');
    }
  }
}
