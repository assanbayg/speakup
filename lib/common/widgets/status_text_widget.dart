import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/controllers/speech_controller.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:speakup/util/constants/sizes.dart';

class StatusTextWidget extends StatelessWidget {
  const StatusTextWidget({super.key});

  String _getStatusText() {
    final speechController = Get.find<SpeechController>();
    final textController = Get.find<TextToSpeechController>();

    if (speechController.isListening) {
      return 'Слушаю...';
    } else if (textController.isThinking) {
      return 'Думаю...';
    } else if (textController.lastChatResponse.isEmpty) {
      return '';
    } else {
      return textController.lastChatResponse;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(SSizes.spaceBtwSections),
        width: MediaQuery.of(context).size.width,
        child: Text(
          _getStatusText(),
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontSize: 14, height: 2),
        ),
      );
    });
  }
}

