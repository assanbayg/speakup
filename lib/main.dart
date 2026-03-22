import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:speakup/features/authentication/screens/login_screen.dart';
import 'package:speakup/features/speakup/controllers/speaker_controller.dart';
import 'package:speakup/features/speakup/controllers/sprite_controller.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:speakup/features/speakup/controllers/voice_controller.dart';
import 'package:speakup/features/speakup/screens/main_navigation_screen.dart';
import 'package:speakup/features/speakup/screens/onboarding_screen.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';
import 'package:speakup/util/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Check onboarding status before building the app
  final onboardingDone = await OnboardingScreen.isCompleted();

  // Register controllers
  Get.lazyPut(() => TextToSpeechController());
  Get.lazyPut(() => SpriteController());
  Get.lazyPut(() => SpeakerController());
  Get.lazyPut(() => VoiceController());

  runApp(SpeakUp(onboardingComplete: onboardingDone));
}

class SpeakUp extends StatelessWidget {
  const SpeakUp({super.key, required this.onboardingComplete});

  final bool onboardingComplete;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: STheme.sTheme,
      debugShowCheckedModeBanner: false,
      home: _getHomeScreen(),
    );
  }

  Widget _getHomeScreen() {
    // First launch → onboarding
    if (!onboardingComplete) {
      return const OnboardingScreen();
    }
    // Logged in → main app
    if (SSupabaseHelper.currentUser != null) {
      return const MainNavigationScreen();
    }
    // Not logged in → login
    return const LoginScreen();
  }
}
