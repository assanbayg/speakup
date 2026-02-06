import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/controllers/speech_controller.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';

class MicrophoneButton extends StatelessWidget {
  const MicrophoneButton({
    super.key,
    this.onlyListen = false,
  });

  final bool onlyListen;

  @override
  Widget build(BuildContext context) {
    final speechController = Get.find<SpeechController>();
    final textController = Get.find<TextToSpeechController>();

    return Obx(() {
      final isListening = speechController.isListening;
      final isThinking = textController.isThinking;
      final isSpeaking = textController.isSpeaking;
      final isActive = !isThinking && !isSpeaking;
      final hasResponse = textController.lastChatResponse.isNotEmpty;

      String hintText = '';
      if (isListening) {
        hintText = 'Говорите...';
      } else if (isThinking) {
        hintText = 'Ожидайте ответа...';
      } else if (isSpeaking) {
        hintText = 'Говорю ответ...';
      } else if (hasResponse) {
        hintText = 'Нажмите на микрофон, чтобы продолжить';
      } else {
        hintText = 'Нажмите на микрофон, чтобы начать';
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              hintText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.grey.shade700 : Colors.grey.shade500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: GestureDetector(
              onTap: isActive
                  ? () {
                      speechController.listen(onlyListen);
                      textController.lastChatResponse = '';
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isListening
                        ? [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ]
                        : [
                            Colors.red.shade400,
                            Colors.red.shade600,
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isListening ? Colors.green : Colors.red)
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: (isListening ? Colors.green : Colors.red)
                          .withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: isActive ? 1.0 : 0.5,
                      child: SvgPicture.asset(
                        'assets/icons/Audio.svg',
                        width: 60,
                        height: 60,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
