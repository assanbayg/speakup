import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/controllers/speech_controller.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:speakup/util/constants/colors.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen>
    with TickerProviderStateMixin {
  final SpeechController speechController = Get.put(SpeechController());
  final TextToSpeechController textController =
      Get.put(TextToSpeechController());

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // History of transcribed texts for the current session
  final RxList<_TranscriptEntry> _history = <_TranscriptEntry>[].obs;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Watch for new transcriptions
    ever(speechController.listenText, (String text) {
      if (text.isNotEmpty) {
        _history.insert(
          0,
          _TranscriptEntry(
            text: text,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
            _buildMicSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.text_fields_rounded,
                  color: SColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Конвертер',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'Речь → Текст',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: SColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                if (_history.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  onPressed: () => _history.clear(),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                  tooltip: 'Очистить историю',
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      final isListening = speechController.isListening;
      final isThinking = textController.isThinking;
      final isSpeaking = textController.isSpeaking;
      final hasHistory = _history.isNotEmpty;

      if (isListening) {
        return _buildListeningState(context);
      }

      if (isThinking) {
        return _buildProcessingState(context);
      }

      if (isSpeaking && _history.isNotEmpty) {
        return _buildResultsList(context, playingBack: true);
      }

      if (hasHistory) {
        return _buildResultsList(context);
      }

      return _buildEmptyState(context);
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: SColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mic_none_rounded,
                    size: 36,
                    color: SColors.primary.withValues(alpha: 0.7),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 22,
                    color: SColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: SColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notes_rounded,
                    size: 36,
                    color: SColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Скажи что-нибудь!',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Нажми на микрофон и говори.\nТвои слова появятся здесь как текст.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // How-it-works pills
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepChip(
                    '1', 'Говори', Icons.mic, const Color(0xFFEF5350)),
                _buildStepArrow(),
                _buildStepChip(
                    '2', 'Текст', Icons.text_fields, SColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepChip(
      String number, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 18,
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildListeningState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated waveform
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(7, (i) {
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final offset = (i - 3).abs();
                    final progress = (_pulseController.value + i * 0.12) % 1.0;
                    final height = 16 + 40 * (1 - (offset * 0.2)) * progress;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 6,
                      height: height.clamp(12.0, 60.0),
                      decoration: BoxDecoration(
                        color: SColors.primary
                            .withValues(alpha: 0.4 + 0.5 * progress),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Слушаю...',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF42A5F5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Говори чётко и не торопись',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
              backgroundColor: SColors.primary.withValues(alpha: 0.12),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Распознаю речь...',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, {bool playingBack = false}) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      reverse: false,
      itemCount: _history.length + 1, // +1 for the info card at top
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildInfoBanner(playingBack: playingBack);
        }
        final entry = _history[index - 1];
        final isLatest = index == 1;
        return _buildTranscriptCard(entry, isLatest: isLatest);
      },
    );
  }

  Widget _buildInfoBanner({bool playingBack = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: playingBack
            ? SColors.primary.withValues(alpha: 0.08)
            : const Color(0xFF66BB6A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: playingBack
              ? SColors.primary.withValues(alpha: 0.15)
              : const Color(0xFF66BB6A).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            playingBack ? Icons.volume_up_rounded : Icons.check_circle_outline,
            size: 18,
            color: playingBack ? SColors.primary : const Color(0xFF66BB6A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              playingBack
                  ? 'Озвучиваю результат...'
                  : 'Нажми на микрофон, чтобы продолжить',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: playingBack
                    ? const Color(0xFF1565C0)
                    : const Color(0xFF2E7D32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptCard(_TranscriptEntry entry, {bool isLatest = false}) {
    final timeStr =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLatest
                ? SColors.primary.withValues(alpha: 0.3)
                : Colors.grey.shade100,
            width: isLatest ? 1.5 : 1,
          ),
          boxShadow: [
            if (isLatest)
              BoxShadow(
                color: SColors.primary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: time + badge
            Row(
              children: [
                if (isLatest)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: SColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Новое',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade400,
                  ),
                ),
                const Spacer(),
                // Copy button
                GestureDetector(
                  onTap: () {
                    // Copy to clipboard
                    // Clipboard.setData(ClipboardData(text: entry.text));
                    Get.snackbar(
                      'Скопировано',
                      entry.text,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 1),
                    );
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Transcribed text
            Text(
              entry.text,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: isLatest ? 18 : 16,
                fontWeight: isLatest ? FontWeight.w700 : FontWeight.w600,
                color: const Color(0xFF1A1A2E),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicSection(BuildContext context) {
    return Obx(() {
      final isListening = speechController.isListening;
      final isThinking = textController.isThinking;
      final isSpeaking = textController.isSpeaking;
      final isActive = !isThinking && !isSpeaking;

      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Mic button
            GestureDetector(
              onTap: isActive
                  ? () {
                      speechController.listen(true); // onlyListen = true
                      textController.lastChatResponse = '';
                    }
                  : null,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = isListening ? _pulseAnimation.value : 1.0;
                  return Transform.scale(scale: scale, child: child);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isListening
                          ? [
                              SColors.primary,
                              const Color(0xFF1E88E5),
                            ]
                          : [
                              Colors.red.shade400,
                              Colors.red.shade600,
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isListening ? SColors.primary : Colors.red)
                            .withValues(alpha: 0.3),
                        blurRadius: isListening ? 24 : 12,
                        spreadRadius: isListening ? 4 : 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Opacity(
                    opacity: isActive ? 1.0 : 0.5,
                    child: Icon(
                      isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Status label
            Text(
              isListening
                  ? 'Нажми, чтобы остановить'
                  : isThinking
                      ? 'Обработка...'
                      : isSpeaking
                          ? 'Озвучиваю...'
                          : 'Нажми, чтобы говорить',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isListening ? SColors.primary : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// A single transcript entry in session history.
class _TranscriptEntry {
  final String text;
  final DateTime timestamp;

  _TranscriptEntry({
    required this.text,
    required this.timestamp,
  });
}
