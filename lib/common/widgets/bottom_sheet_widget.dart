import 'package:flutter/material.dart';
import 'package:speakup/common/widgets/microphone_button.dart';
import 'package:speakup/common/widgets/status_text_widget.dart';
import 'package:speakup/util/constants/sizes.dart';
import 'package:speakup/util/device/device_utility.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({
    super.key,
    this.onlyListen = false,
  });

  final bool onlyListen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      height: SDeviceUtils.getScreenHeight(context) * .4,
      width: SDeviceUtils.getScreenWidth(context),
      child: Column(
        children: [
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusTextWidget(),
                ],
              ),
            ),
          ),
          const SizedBox(height: SSizes.spaceBtwSections),
          MicrophoneButton(onlyListen: onlyListen),
        ],
      ),
    );
  }
}

