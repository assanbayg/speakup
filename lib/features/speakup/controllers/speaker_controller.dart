import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speakup/services/speaker_service.dart';

class SpeakerController extends GetxController {
  final RxList<Speaker> availableSpeakers = <Speaker>[].obs;
  final Rx<Speaker?> selectedSpeaker = Rx<Speaker?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSpeakers();
  }

  /// Load available speakers from backend
  Future<void> loadSpeakers() async {
    isLoading.value = true;
    try {
      final speakers = await SpeakerService.fetchSpeakers();
      availableSpeakers.value = speakers;

      // Auto-select first speaker if none selected
      if (selectedSpeaker.value == null && speakers.isNotEmpty) {
        selectedSpeaker.value = speakers.first;
      }

      if (kDebugMode) {
        print('Loaded ${speakers.length} speakers');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading speakers: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a speaker
  void selectSpeaker(Speaker speaker) {
    selectedSpeaker.value = speaker;
    if (kDebugMode) {
      print('Selected speaker: ${speaker.name}');
    }
  }

  /// Get currently selected speaker ID (for API calls)
  String? get selectedSpeakerId => selectedSpeaker.value?.id;

  /// Check if a speaker is selected
  bool isSelected(Speaker speaker) {
    return selectedSpeaker.value?.id == speaker.id;
  }
}
