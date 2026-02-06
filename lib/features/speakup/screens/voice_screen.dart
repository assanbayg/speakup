import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/common/widgets/app_bar.dart';
import 'package:speakup/features/speakup/controllers/voice_controller.dart';
import 'package:speakup/services/voice_service.dart';
import 'package:speakup/util/constants/sizes.dart';

class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VoiceController());

    return Scaffold(
      appBar: SAppBar(
        title: 'Мой голос',
        page: 'Voice',
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInstructionsModal(context),
            tooltip: 'Как это работает',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadVoices(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(SSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecordSection(context, controller),
              const SizedBox(height: SSizes.spaceBtwSections),
              Text(
                'Сохранённые голоса',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: SSizes.spaceBtwItems),
              _buildVoicesList(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  void _showInstructionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.record_voice_over,
                      color: Colors.teal,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Клонирование голоса',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInstructionItem(
                context,
                icon: Icons.mic,
                title: 'Запишите 15-30 секунд',
                description:
                    'Говорите естественно, как будто разговариваете с ребёнком. '
                    'Можете рассказать короткую историю или просто поговорить.',
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                context,
                icon: Icons.volume_up,
                title: 'Тихое место',
                description: 'Записывайте в тихом месте без фонового шума. '
                    'Говорите чётко, но не слишком громко.',
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                context,
                icon: Icons.psychology,
                title: 'Как это работает',
                description:
                    'Система анализирует особенности вашего голоса и создаёт '
                    'его цифровую копию. Спичи будет говорить вашим голосом!',
              ),
              const SizedBox(height: 16),
              _buildInstructionItem(
                context,
                icon: Icons.favorite,
                title: 'Зачем это нужно',
                description: 'Дети лучше реагируют на знакомые голоса. '
                    'Голос родителя создаёт чувство безопасности и доверия.',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Совет: Попробуйте прочитать любимую сказку ребёнка - '
                        'это даст естественный образец речи.',
                        style: TextStyle(color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Понятно!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.teal, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordSection(BuildContext context, VoiceController controller) {
    return Container(
      padding: const EdgeInsets.all(SSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/Audio.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.teal,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Записать голос',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '15-30 секунд естественной речи',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SSizes.spaceBtwItems),

          // Recording UI
          Obx(() => _buildRecordingUI(context, controller)),
        ],
      ),
    );
  }

  Widget _buildRecordingUI(BuildContext context, VoiceController controller) {
    final isRecording = controller.isRecording.value;
    final hasRecording = controller.recordingPath.value != null;
    final isUploading = controller.isUploading.value;
    final isLoading = controller.isLoading.value;
    final validation = controller.lastValidation.value;

    if (isUploading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              CircularProgressIndicator(color: Colors.teal),
              SizedBox(height: 16),
              Text('Обработка голоса...'),
              SizedBox(height: 8),
              Text(
                'Это может занять до минуты',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (isRecording) {
      return _buildRecordingInProgress(context, controller);
    }

    if (hasRecording && !isRecording) {
      return _buildRecordingPreview(context, controller, validation);
    }

    // Initial state - ready to record
    return _buildReadyToRecord(context, controller);
  }

  Widget _buildReadyToRecord(BuildContext context, VoiceController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => controller.startRecording(),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.teal.shade400, Colors.teal.shade600],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 48),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Нажмите, чтобы начать запись',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildRecordingInProgress(
      BuildContext context, VoiceController controller) {
    final duration = controller.recordingDuration.value;
    final isOptimal = duration >= 15 && duration <= 30;
    final isTooShort = duration < 6;

    return Column(
      children: [
        const SizedBox(height: 16),

        // Animated recording indicator
        GestureDetector(
          onTap: () => controller.stopRecording(),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.stop, color: Colors.white, size: 48),
          ),
        ),

        const SizedBox(height: 16),

        // Duration display
        Text(
          controller.formatDuration(duration),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOptimal ? Colors.green : Colors.red,
              ),
        ),

        const SizedBox(height: 8),

        // Status hint
        Text(
          isTooShort
              ? 'Минимум 6 секунд'
              : isOptimal
                  ? 'Отлично! Можете остановить'
                  : duration > 30
                      ? 'Достаточно!'
                      : 'Продолжайте говорить...',
          style: TextStyle(
            color: isOptimal ? Colors.green : Colors.grey.shade600,
            fontWeight: isOptimal ? FontWeight.bold : FontWeight.normal,
          ),
        ),

        const SizedBox(height: 16),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (duration / 30).clamp(0, 1),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(
              isOptimal
                  ? Colors.green
                  : isTooShort
                      ? Colors.red
                      : Colors.orange,
            ),
            minHeight: 8,
          ),
        ),

        const SizedBox(height: 8),

        // Cancel button
        TextButton.icon(
          onPressed: () => controller.cancelRecording(),
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Отмена'),
          style: TextButton.styleFrom(foregroundColor: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRecordingPreview(
    BuildContext context,
    VoiceController controller,
    VoiceValidationResult? validation,
  ) {
    final isPlaying = controller.isPlaying.value;
    final isLoading = controller.isLoading.value;

    return Column(
      children: [
        // Play/validate buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Play button
            IconButton.filled(
              onPressed: () => controller.playRecording(),
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              style: IconButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 16),

            // Validate button
            if (validation == null)
              ElevatedButton.icon(
                onPressed:
                    isLoading ? null : () => controller.validateRecording(),
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(isLoading ? 'Проверка...' : 'Проверить'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Validation result
        if (validation != null) _buildValidationResult(context, validation),

        // Action buttons
        if (validation != null && validation.valid) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.cancelRecording(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Перезаписать'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showUploadDialog(context, controller),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Сохранить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ] else if (validation != null && !validation.valid) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.cancelRecording(),
              icon: const Icon(Icons.refresh),
              label: const Text('Перезаписать'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildValidationResult(
      BuildContext context, VoiceValidationResult validation) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: validation.valid
            ? Colors.green.shade50
            : validation.errors.isNotEmpty
                ? Colors.red.shade50
                : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: validation.valid
              ? Colors.green.shade200
              : validation.errors.isNotEmpty
                  ? Colors.red.shade200
                  : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                validation.valid
                    ? Icons.check_circle
                    : validation.errors.isNotEmpty
                        ? Icons.error
                        : Icons.warning,
                color: validation.valid
                    ? Colors.green
                    : validation.errors.isNotEmpty
                        ? Colors.red
                        : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                validation.valid
                    ? 'Запись подходит!'
                    : validation.errors.isNotEmpty
                        ? 'Есть проблемы'
                        : 'Есть предупреждения',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: validation.valid
                      ? Colors.green.shade700
                      : validation.errors.isNotEmpty
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          if (validation.errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...validation.errors.map((e) => Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text('• $e',
                      style: TextStyle(color: Colors.red.shade700)),
                )),
          ],
          if (validation.warnings.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...validation.warnings.map((w) => Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text('• $w',
                      style: TextStyle(color: Colors.orange.shade700)),
                )),
          ],
          if (validation.recommendations.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...validation.recommendations.map((r) => Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text('💡 $r',
                      style: TextStyle(color: Colors.grey.shade700)),
                )),
          ],
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              'Длительность: ${validation.duration.toStringAsFixed(1)}с',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context, VoiceController controller) {
    final nameController = TextEditingController(text: 'Голос родителя');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сохранить голос'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Например: Мама, Папа',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.uploadVoice(voiceName: nameController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  Widget _buildVoicesList(BuildContext context, VoiceController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.availableVoices.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final voices = controller.availableVoices;

      if (voices.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.record_voice_over_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Нет сохранённых голосов',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Запишите голос выше',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: voices.length + 1, // +1 for default voice option
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Default system voice
            return _buildDefaultVoiceTile(context, controller);
          }
          final voice = voices[index - 1];
          return _buildVoiceTile(context, controller, voice);
        },
      );
    });
  }

  Widget _buildDefaultVoiceTile(
      BuildContext context, VoiceController controller) {
    return Obx(() {
      final isDefault = controller.defaultVoiceId.value == null;

      return GestureDetector(
        onTap: () => controller.clearDefaultVoice(),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDefault ? Colors.teal : Colors.grey.shade200,
              width: isDefault ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDefault
                    ? Colors.teal.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isDefault ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDefault
                      ? Colors.teal.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.smart_toy,
                  color: isDefault ? Colors.teal : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Стандартный голос',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isDefault ? FontWeight.w600 : FontWeight.w500,
                        color: isDefault ? Colors.teal : Colors.black87,
                      ),
                    ),
                    Text(
                      'Голос по умолчанию',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDefault)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildVoiceTile(
    BuildContext context,
    VoiceController controller,
    VoiceInfo voice,
  ) {
    return Obx(() {
      final isDefault = controller.isDefault(voice.voiceId);
      final isPreviewing = controller.isPreviewing.value;

      return GestureDetector(
        onTap: () => controller.setDefaultVoice(voice.voiceId),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDefault ? Colors.teal : Colors.grey.shade200,
              width: isDefault ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDefault
                    ? Colors.teal.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isDefault ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isDefault
                      ? Colors.teal.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.record_voice_over,
                  color: isDefault ? Colors.teal : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voice.voiceName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isDefault ? FontWeight.w600 : FontWeight.w500,
                        color: isDefault ? Colors.teal : Colors.black87,
                      ),
                    ),
                    Text(
                      '${voice.duration.toStringAsFixed(0)}с',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Preview button
              IconButton(
                onPressed: () => controller.previewVoice(voice.voiceId),
                icon: Icon(
                  isPreviewing ? Icons.stop : Icons.play_circle_outline,
                  color: Colors.teal,
                ),
                tooltip: 'Прослушать',
              ),

              // Delete button
              IconButton(
                onPressed: () => _confirmDelete(context, controller, voice),
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                tooltip: 'Удалить',
              ),

              // Selection indicator
              if (isDefault)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      );
    });
  }

  void _confirmDelete(
    BuildContext context,
    VoiceController controller,
    VoiceInfo voice,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить голос?'),
        content: Text('Удалить "${voice.voiceName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteVoice(voice.voiceId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
