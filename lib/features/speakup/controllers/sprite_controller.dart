import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakup/services/sprite_service.dart';
import 'package:speakup/util/helpers/helper_functions.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';

class SpriteController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final RxList<String> availableSprites = <String>[].obs;
  final RxList<String> pendingSprites = <String>[].obs;
  final RxString selectedSprite = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

  String? get userId => SSupabaseHelper.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    loadSprites();
  }

  Future<void> loadSprites() async {
    if (userId == null) return;
    isLoading.value = true;
    try {
      final results = await Future.wait([
        SpriteService.listApprovedSprites(userId!),
        SpriteService.listPendingSprites(userId!),
      ]);
      availableSprites.value = results[0];
      pendingSprites.value = results[1];

      // Reset selection if selected sprite was deleted
      if (selectedSprite.value.isNotEmpty &&
          !availableSprites.contains(selectedSprite.value)) {
        selectedSprite.value = '';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectSprite(String? filename) {
    selectedSprite.value = filename ?? '';
  }

  void useDefaultCharacter() {
    selectedSprite.value = '';
  }

  bool isSelected(String filename) => selectedSprite.value == filename;

  bool get isUsingDefault => selectedSprite.value.isEmpty;

  String? get selectedSpriteUrl {
    if (userId == null || selectedSprite.value.isEmpty) return null;
    return SpriteService.getSpriteImageUrl(userId!, selectedSprite.value);
  }

  Future<void> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) await _uploadSprite(File(image.path));
    } catch (e) {
      SHelperFunctions.showSnackBar('Не удалось открыть камеру: $e');
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) await _uploadSprite(File(image.path));
    } catch (e) {
      SHelperFunctions.showSnackBar('Не удалось открыть галерею: $e');
    }
  }

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
          'Рисунок отправлен на проверку! Обычно это занимает 1-2 дня.',
        );
        // Refresh to show the new pending sprite
        await loadSprites();
      }
    } catch (e) {
      SHelperFunctions.showSnackBar('Ошибка загрузки: $e');
    } finally {
      isUploading.value = false;
    }
  }
}
