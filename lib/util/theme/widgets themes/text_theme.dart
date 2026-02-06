import 'package:flutter/material.dart';

import '../../constants/colors.dart';

/// Custom Class for Light & Dark Text Themes
class STextTheme {
  STextTheme._(); // To avoid creating instances

  /// Customizable Light Text Theme
  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 32.0, fontWeight: FontWeight.bold, color: SColors.dark),
    headlineMedium: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 24.0, fontWeight: FontWeight.w600, color: SColors.dark),
    headlineSmall: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 18.0, fontWeight: FontWeight.w600, color: SColors.dark),
    titleLarge: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 16.0, fontWeight: FontWeight.w600, color: SColors.dark),
    titleMedium: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 16.0, fontWeight: FontWeight.w500, color: SColors.dark),
    titleSmall: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 16.0, fontWeight: FontWeight.w400, color: SColors.dark),
    bodyLarge: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 14.0, fontWeight: FontWeight.w500, color: SColors.dark),
    bodyMedium: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 14.0, fontWeight: FontWeight.normal, color: SColors.dark),
    bodySmall: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: SColors.dark.withValues(alpha: 0.5)),
    labelLarge: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 12.0, fontWeight: FontWeight.normal, color: SColors.dark),
    labelMedium: const TextStyle().copyWith(
        fontFamily: 'Quicksand',
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: SColors.dark.withValues(alpha: 0.5)),
  );
}
