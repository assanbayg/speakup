import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/common/widgets/app_bar.dart';
import 'package:speakup/features/speakup/controllers/speaker_controller.dart';
import 'package:speakup/services/speaker_service.dart';
import 'package:speakup/util/constants/colors.dart';
import 'package:speakup/util/constants/sizes.dart';

class SpeakersScreen extends StatelessWidget {
  const SpeakersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpeakerController());

    return Scaffold(
      appBar: const SAppBar(
        title: 'Выбор голоса',
        page: 'Speakers',
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadSpeakers(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(SSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              _buildInfoCard(context),
              const SizedBox(height: SSizes.spaceBtwSections),

              // Speakers list
              Text(
                'Доступные голоса',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: SSizes.spaceBtwItems),
              _buildSpeakersList(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              'assets/icons/Audio.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                SColors.primary,
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
                  'Голос Спичи',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Выберите голос, которым будет говорить Спичи',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakersList(
      BuildContext context, SpeakerController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final speakers = controller.availableSpeakers;

      if (speakers.isEmpty) {
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
                  'Голоса недоступны',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => controller.loadSpeakers(),
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: speakers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final speaker = speakers[index];
          return _buildSpeakerTile(context, controller, speaker);
        },
      );
    });
  }

  Widget _buildSpeakerTile(
    BuildContext context,
    SpeakerController controller,
    Speaker speaker,
  ) {
    return Obx(() {
      final isSelected = controller.isSelected(speaker);

      return GestureDetector(
        onTap: () => controller.selectSpeaker(speaker),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? SColors.primary : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? SColors.primary.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Speaker icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? SColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.record_voice_over,
                  color: isSelected ? SColors.primary : Colors.grey.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Speaker name
              Expanded(
                child: Text(
                  speaker.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? SColors.primary : Colors.black87,
                  ),
                ),
              ),

              // Selection indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: SColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
