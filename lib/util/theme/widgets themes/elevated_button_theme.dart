import 'package:flutter/material.dart';
import 'package:speakup/util/constants/colors.dart';
import 'package:speakup/util/constants/sizes.dart';

/* -- Light & Dark Elevated Button Themes -- */
class SElevatedButtonTheme {
  SElevatedButtonTheme._(); //To avoid creating instances
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: SColors.light,
      backgroundColor: SColors.primary,
      disabledForegroundColor: SColors.darkGrey,
      disabledBackgroundColor: SColors.buttonDisabled,
      side: const BorderSide(color: SColors.primary),
      padding: const EdgeInsets.symmetric(vertical: SSizes.buttonHeight),
      textStyle: const TextStyle(
          fontSize: 16, color: SColors.textWhite, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(250)),
    ),
  );
}
