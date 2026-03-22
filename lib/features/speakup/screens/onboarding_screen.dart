import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakup/features/speakup/screens/main_navigation_screen.dart';
import 'package:speakup/util/constants/colors.dart';

/// Data model for a single onboarding page.
class _OnboardingPage {
  final String image; // asset path
  final String title;
  final String subtitle;
  final List<String>? pills; // optional feature pills (welcome slide only)
  final Color accentColor;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
    this.pills,
    this.accentColor = SColors.primary,
  });
}

const _pages = [
  _OnboardingPage(
    image: 'assets/images/speechy_default.png',
    title: 'Привет! Я — Спичи',
    subtitle:
        'Твой друг для разговоров. Вместе мы будем тренировать речь, играя и общаясь!',
    pills: ['Разговоры', 'Речь → Текст', 'Карта центров', 'Мой профиль'],
  ),
  _OnboardingPage(
    image: 'assets/images/speechy_default.png',
    title: 'Говори со Спичи',
    subtitle:
        'Нажми на красную кнопку микрофона и скажи что угодно. Спичи тебя выслушает и ответит голосом!',
    accentColor: Color(0xFFEF5350),
  ),
  _OnboardingPage(
    image: 'assets/images/speechy_default.png',
    title: 'Конвертер речи',
    subtitle:
        'Говори — и смотри как твои слова превращаются в текст. Здесь Спичи только слушает.',
    accentColor: Color(0xFF42A5F5),
  ),
  _OnboardingPage(
    image: 'assets/images/speechy_default.png',
    title: 'Карта и профиль',
    subtitle:
        'Найди логопедические центры рядом. А в профиле — нарисуй своего персонажа и настрой голос Спичи!',
    accentColor: Color(0xFF66BB6A),
  ),
  _OnboardingPage(
    image: 'assets/images/speechy_default.png',
    title: 'Давай начнём!',
    subtitle:
        'Нажми на микрофон и скажи «Привет, Спичи!» — он тебе ответит. Не бойся ошибок — тут тебя всегда поймут.',
    accentColor: Color(0xFF66BB6A),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  /// Check if onboarding has been completed.
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  /// Mark onboarding as completed.
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _goToPage(_currentPage + 1);
    }
  }

  Future<void> _finish() async {
    await OnboardingScreen.markCompleted();
    Get.offAll(() => const MainNavigationScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: SafeArea(
        child: Column(
          children: [
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) =>
                    _buildPage(_pages[index], index),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  _buildDots(),
                  const SizedBox(height: 20),
                  _buildButtons(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    final isLastPage = index == _pages.length - 1;
    final isFirstPage = index == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // Character image with floating animation and accent ring
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: _buildCharacterImage(page, index),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              height: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),

          // Feature pills on welcome page
          if (isFirstPage && page.pills != null) ...[
            const SizedBox(height: 24),
            _buildPills(page.pills!),
          ],

          // Mic hint on chat page
          if (index == 1) ...[
            const SizedBox(height: 24),
            _buildMicHint(),
          ],

          // Celebration on last page
          if (isLastPage) ...[
            const SizedBox(height: 24),
            _buildCelebration(),
          ],

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildCharacterImage(_OnboardingPage page, int index) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: page.accentColor.withValues(alpha: 0.08),
        border: Border.all(
          color: page.accentColor.withValues(alpha: 0.15),
          width: 2,
        ),
      ),
      child: Center(
        child: ClipOval(
          child: Image.asset(
            page.image,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if asset isn't found
              return Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: page.accentColor.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  size: 64,
                  color: page.accentColor,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPills(List<String> pills) {
    const colors = [
      (Color(0xFFEEEDFE), Color(0xFF5740B1)),
      (Color(0xFFE8F5E9), Color(0xFF2E7D32)),
      (Color(0xFFFFF3E0), Color(0xFFE65100)),
      (Color(0xFFE3F2FD), Color(0xFF1565C0)),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(pills.length, (i) {
        final (bg, fg) = colors[i % colors.length];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + i * 100),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pills[i],
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMicHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'Нажми — говори — отпусти',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['🎉', '🗣️', '✨'].map((emoji) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(emoji, style: const TextStyle(fontSize: 28)),
        );
      }).toList(),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? SColors.primary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildButtons() {
    final isLastPage = _currentPage == _pages.length - 1;

    if (isLastPage) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _finish,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF66BB6A),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('Начать разговор'),
        ),
      );
    }

    return Row(
      children: [
        // Skip button
        SizedBox(
          height: 54,
          child: OutlinedButton(
            onPressed: () => _goToPage(_pages.length - 1),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              textStyle: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Пропустить'),
          ),
        ),
        const SizedBox(width: 12),
        // Next button
        Expanded(
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: SColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Далее'),
            ),
          ),
        ),
      ],
    );
  }
}
