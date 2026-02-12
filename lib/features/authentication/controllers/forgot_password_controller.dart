import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/util/helpers/helper_functions.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController email = TextEditingController();

  RxBool isLoading = false.obs;

  /// Validate & send password reset email
  void resetPassword(BuildContext context) {
    final emailText = email.text.trim();

    if (emailText.isEmpty) {
      SHelperFunctions.showSnackBar("Введите электронную почту");
      return;
    }
    if (!SHelperFunctions.isEmailValid(email: emailText)) {
      SHelperFunctions.showSnackBar("Неверный формат почты");
      return;
    }

    _sendResetEmail(context, email: emailText);
  }

  /// Send password reset link via Supabase
  Future<void> _sendResetEmail(
    BuildContext context, {
    required String email,
  }) async {
    try {
      isLoading.value = true;
      SHelperFunctions.showProgressIndicator(context);

      await SSupabaseHelper.auth.resetPasswordForEmail(email);

      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;
      SHelperFunctions.showSnackBar(
          'Ссылка для сброса пароля отправлена на почту');
      Get.back();
    } on AuthException catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;

      String errorMessage = 'Ошибка отправки';
      switch (e.code) {
        case 'user_not_found':
          errorMessage = 'Аккаунт с этой почтой не найден';
          break;
        default:
          errorMessage = e.message;
      }

      SHelperFunctions.showSnackBar(errorMessage);
    } catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;
      SHelperFunctions.showSnackBar('Ошибка отправки: $e');
    }
  }

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }
}
