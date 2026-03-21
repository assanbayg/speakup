import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/common/widgets/app_bar.dart';
import 'package:speakup/features/speakup/controllers/sprite_controller.dart';
import 'package:speakup/services/sprite_service.dart';
import 'package:speakup/util/constants/colors.dart';
import 'package:speakup/util/constants/sizes.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';

class SpritesScreen extends StatelessWidget {
  const SpritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpriteController());

    return Scaffold(
      appBar: SAppBar(
        title: 'Мои персонажи',
        page: 'Sprites',
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInstructionsModal(context),
            tooltip: 'Как это работает',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadSprites(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(SSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUploadSection(context, controller),
              const SizedBox(height: SSizes.spaceBtwSections),

              // Pending section
              Obx(() {
                final pending = controller.pendingSprites;
                if (pending.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      icon: Icons.hourglass_top_rounded,
                      iconColor: Colors.orange,
                      title: 'На проверке',
                      subtitle: '${pending.length} рис. ожидает одобрения',
                    ),
                    const SizedBox(height: SSizes.spaceBtwItems),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: pending.length,
                      itemBuilder: (context, index) {
                        return _buildPendingSpriteCard(
                          context: context,
                          filename: pending[index],
                        );
                      },
                    ),
                    const SizedBox(height: SSizes.spaceBtwSections),
                  ],
                );
              }),

              // Approved section
              _buildSectionHeader(
                context,
                icon: Icons.check_circle_outline,
                iconColor: Colors.green,
                title: 'Доступные персонажи',
              ),
              const SizedBox(height: SSizes.spaceBtwItems),
              _buildApprovedGrid(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingSpriteCard({
    required BuildContext context,
    required String filename,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Stack(
        children: [
          // Placeholder image area with dashed feel
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.orange.shade50,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Colors.orange.shade300,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatFilename(filename),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // "Under review" badge at top
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_top_rounded,
                        size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'На проверке',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom label
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Text(
                'Обычно 1-2 дня',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedGrid(BuildContext context, SpriteController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.availableSprites.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final sprites = controller.availableSprites;
      final userId = SSupabaseHelper.currentUser?.id;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: sprites.length + 1, // +1 for default Speechy
        itemBuilder: (context, index) {
          if (index == 0) {
            return Obx(() => _buildSpriteCard(
                  context: context,
                  isDefault: true,
                  isSelected: controller.isUsingDefault,
                  onTap: () => controller.useDefaultCharacter(),
                ));
          }
          final filename = sprites[index - 1];
          final imageUrl = userId != null
              ? SpriteService.getSpriteImageUrl(userId, filename)
              : null;
          return Obx(() => _buildSpriteCard(
                key: ValueKey(filename),
                context: context,
                imageUrl: imageUrl,
                filename: filename,
                isSelected: controller.isSelected(filename),
                onTap: () => controller.selectSprite(filename),
              ));
        },
      );
    });
  }

  Widget _buildSpriteCard({
    Key? key,
    required BuildContext context,
    bool isDefault = false,
    String? imageUrl,
    String? filename,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? SColors.primary : Colors.grey.shade200,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? SColors.primary.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: isDefault
                  ? Image.asset(
                      'assets/images/speechy_default.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  color: Colors.grey.shade400, size: 40),
                              const SizedBox(height: 8),
                              Text('Ошибка загрузки',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: SColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Text(
                  isDefault
                      ? 'Спичи (по умолчанию)'
                      : _formatFilename(filename!),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFilename(String filename) {
    final name = filename.split('.').first;
    return name.replaceAll('_', ' ').replaceAll('-', ' ');
  }

  Widget _buildUploadSection(
      BuildContext context, SpriteController controller) {
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
                  color: SColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/Add_Person.svg',
                  width: 24,
                  height: 24,
                  colorFilter:
                      const ColorFilter.mode(SColors.primary, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Загрузить рисунок',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Нарисуй персонажа и отправь на проверку',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SSizes.spaceBtwItems),
          Obx(() {
            if (controller.isUploading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Загружаем рисунок...'),
                    ],
                  ),
                ),
              );
            }
            return Row(
              children: [
                Expanded(
                  child: _buildUploadButton(
                    context: context,
                    icon: 'assets/icons/Camera.svg',
                    label: 'Камера',
                    onTap: () => controller.pickFromCamera(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUploadButton(
                    context: context,
                    icon: 'assets/icons/Document.svg',
                    label: 'Галерея',
                    onTap: () => controller.pickFromGallery(),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: SSizes.sm),
          // Info row about review process
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'После отправки рисунок проверяется администратором. Обычно 1–2 дня.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: SColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                colorFilter:
                    const ColorFilter.mode(SColors.primary, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                    color: SColors.primary, fontWeight: FontWeight.w600),
              ),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                      color: SColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.palette,
                        color: SColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Как создать персонажа',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              _buildStep(context, 1, Icons.draw, 'Нарисуй персонажа',
                  'Возьми бумагу и карандаши. Нарисуй дружелюбного персонажа — животное, монстрика, космического друга или что-то своё!'),
              const SizedBox(height: 20),
              _buildStep(context, 2, Icons.camera_alt, 'Сфотографируй',
                  'Сделай фото рисунка или выбери из галереи. Убедись, что хорошо видно!'),
              const SizedBox(height: 20),
              _buildStep(context, 3, Icons.upload, 'Загрузи',
                  'Нажми кнопку «Камера» или «Галерея» и выбери рисунок.'),
              const SizedBox(height: 20),
              _buildStep(context, 4, Icons.hourglass_empty, 'Подожди проверки',
                  'Рисунок появится в разделе «На проверке». Администратор одобрит его за 1–2 дня.'),
              const SizedBox(height: 20),
              _buildStep(context, 5, Icons.celebration, 'Персонаж готов!',
                  'Одобренный персонаж переместится в «Доступные». Выбери его и начни разговаривать!'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Понятно!',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, int n, IconData icon, String title,
      String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: SColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: SColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Center(
              child: Text('$n',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 18, color: SColors.primary),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 4),
              Text(description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade700, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }
}
