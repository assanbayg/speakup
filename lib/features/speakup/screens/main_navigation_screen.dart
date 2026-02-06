import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/common/widgets/bottom_navigation_bar.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:speakup/features/speakup/screens/converter_screen.dart';
import 'package:speakup/features/speakup/screens/home_screen.dart';
import 'package:speakup/features/speakup/screens/map_screen.dart';
import 'package:speakup/features/speakup/screens/profile_screen.dart';

/// Hosts the bottom navigation and swaps tab bodies without stacking routes.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = const [
      HomeScreen(),
      ConverterScreen(),
      MapScreen(text: ''),
      UserProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });

    // Clear any residual TTS response when switching tabs to keep UI tidy.
    final textController = Get.find<TextToSpeechController>();
    textController.lastChatResponse = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: SBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
