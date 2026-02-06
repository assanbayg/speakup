import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/common/widgets/app_bar.dart';
import 'package:speakup/common/widgets/bottom_sheet_widget.dart';
import 'package:speakup/common/widgets/video_image_widget.dart';
import 'package:speakup/features/speakup/controllers/speech_controller.dart';
import 'package:speakup/features/speakup/controllers/text_to_speech_controller.dart';
import 'package:speakup/util/constants/sizes.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechController speechController = Get.put(SpeechController());
  final TextToSpeechController textController =
      Get.put(TextToSpeechController());

  late final VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.asset('assets/images/video.mp4')
      ..initialize().then((_) {
        videoController.setLooping(true);
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SAppBar(
        page: "Home",
        title: "Привет, я Спичи!",
      ),
      body: Stack(
        children: [
          buildBody(),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetWidget(),
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(SSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            VideoImageWidget(videoController: videoController),
          ],
        ),
      ),
    );
  }
}
