import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakup/services/sprite_service.dart';
import 'package:speakup/util/helpers/helper_functions.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';

class SpriteController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  // Observable state
  final RxList<String> availableSprites = <String>[].obs;
  final RxString selectedSprite = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  String? get userId => SSupabaseHelper.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    loadSprites();
  }

  /// Load available sprites from backend
  Future<void> loadSprites() async {
    if (userId == null) return;

    isLoading.value = true;
    try {
      final sprites = await SpriteService.listApprovedSprites(userId!);
      availableSprites.value = sprites;

      // If we have sprites but none selected, keep default
      // If selected sprite was deleted, reset to default
      if (selectedSprite.value.isNotEmpty &&
          !sprites.contains(selectedSprite.value)) {
        selectedSprite.value = '';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading sprites: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a sprite to use as the character
  void selectSprite(String? filename) {
    selectedSprite.value = filename ?? '';
    if (kDebugMode) {
      print(
          'Selected sprite: ${selectedSprite.value.isEmpty ? "default" : selectedSprite.value}');
    }
  }

  /// Use default Speechy character
  void useDefaultCharacter() {
    selectedSprite.value = '';
  }

  /// Check if a sprite is currently selected
  bool isSelected(String filename) {
    return selectedSprite.value == filename;
  }

  /// Check if using default character
  bool get isUsingDefault => selectedSprite.value.isEmpty;

  /// Get URL for the selected sprite (or null for default)
  String? get selectedSpriteUrl {
    if (userId == null || selectedSprite.value.isEmpty) {
      return null;
    }
    return SpriteService.getSpriteImageUrl(userId!, selectedSprite.value);
  }

  /// Pick image from camera
  Future<void> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadSprite(File(image.path));
      }
    } catch (e) {
      SHelperFunctions.showSnackBar('Не удалось открыть камеру: $e');
    }
  }

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadSprite(File(image.path));
      }
    } catch (e) {
      SHelperFunctions.showSnackBar('Не удалось открыть галерею: $e');
    }
  }

  /// Upload sprite to backend for review
  Future<void> _uploadSprite(File imageFile) async {
    if (userId == null) {
      SHelperFunctions.showSnackBar('Пожалуйста, войдите в систему');
      return;
    }

    isUploading.value = true;
    try {
      final result = await SpriteService.uploadPendingSprite(
        userId: userId!,
        imageFile: imageFile,
      );

      if (result['ok'] == true) {
        SHelperFunctions.showSnackBar(
          'Рисунок отправлен на проверку! После одобрения он появится в списке.',
        );
      }
    } catch (e) {
      SHelperFunctions.showSnackBar('Ошибка загрузки: $e');
    } finally {
      isUploading.value = false;
    }
  }
}
