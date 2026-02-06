import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/controllers/sprite_controller.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:video_player/video_player.dart';

class VideoImageWidget extends StatelessWidget {
  const VideoImageWidget({
    super.key,
    required this.videoController,
  });

  final VideoPlayerController videoController;

  @override
  Widget build(BuildContext context) {
    final textController = Get.find<TextToSpeechController>();

    final SpriteController? spriteController =
        Get.isRegistered<SpriteController>()
            ? Get.find<SpriteController>()
            : null;

    return Obx(() {
      final isSpeaking = textController.isSpeaking;
      final selectedSpriteUrl = spriteController?.selectedSpriteUrl;
      final isUsingCustomSprite = selectedSpriteUrl != null;

      // Custom sprite: always static image
      if (isUsingCustomSprite) {
        videoController.pause();
        return Image.network(
          selectedSpriteUrl,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/speechy_default.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            );
          },
        );
      }

      // Default Speechy: video when speaking, static when not
      if (isSpeaking) {
        videoController.play();
        return AspectRatio(
          aspectRatio: videoController.value.aspectRatio,
          child: VideoPlayer(videoController),
        );
      } else {
        videoController.pause();
        return Image.asset(
          'assets/images/speechy_default.png',
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        );
      }
    });
  }
}
