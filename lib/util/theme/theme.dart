import 'package:flutter/material.dart';
import 'package:speakup/util/theme/widgets%20themes/elevated_button_theme.dart';
import 'package:speakup/util/theme/widgets%20themes/text_button_theme.dart';
import 'package:speakup/util/theme/widgets%20themes/text_field_theme.dart';
import 'package:speakup/util/theme/widgets%20themes/text_theme.dart';

class STheme {
  /// Light Theme
  static ThemeData sTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Quicksand',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
    ),
    // scaffoldBackgroundColor: const Color(0xFFE2E9F3),
    elevatedButtonTheme: SElevatedButtonTheme.lightElevatedButtonTheme,
    inputDecorationTheme: STextFormFieldTheme.lightInputDecorationTheme,
    textButtonTheme: STextButtonTheme.lightTextButtonTheme,
    textTheme: STextTheme.lightTextTheme,
  );

  /// Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Quicksand',
  );
}
