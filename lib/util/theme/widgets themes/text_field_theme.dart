import 'package:flutter/material.dart';
import 'package:speakup/util/constants/colors.dart';
import 'package:speakup/util/constants/sizes.dart';

class STextFormFieldTheme {
  STextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: SColors.dark,
    suffixIconColor: SColors.dark,
    // constraints: const BoxConstraints.expand(height: ASizes.inputFieldHeight),
    labelStyle: const TextStyle()
        .copyWith(fontSize: SSizes.fontSizeMd, color: SColors.black),
    hintStyle: const TextStyle()
        .copyWith(fontSize: SSizes.fontSizeSm, color: SColors.black),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle:
        const TextStyle().copyWith(color: SColors.black.withValues(alpha: 0.8)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(SSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: SColors.textFieldColor),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(SSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: SColors.textFieldColor),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(SSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: SColors.textFieldColor),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(SSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: SColors.warning),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(SSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: SColors.warning),
    ),
  );
}
