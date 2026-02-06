import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SHelperFunctions {
  static void showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showAlert(String title, String message) {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  static bool isEmailValid({required String email}) {
    /// Regular expression for validating email addresses
    final RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );

    /// Check if the email matches the regex
    return emailRegex.hasMatch(email);
  }

  static OverlayEntry? overlayEntry;

  static void showProgressIndicator(BuildContext context) {
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Stack(
        children: <Widget>[
          Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  static void hideProgressIndicator() {
    if (overlayEntry != null) {
      overlayEntry?.remove();
      overlayEntry = null;
    }
  }
}
