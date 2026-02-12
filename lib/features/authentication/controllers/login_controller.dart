import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/models/user_model.dart';
import 'package:speakup/features/speakup/screens/main_navigation_screen.dart';
import 'package:speakup/util/helpers/helper_functions.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends GetxController {
  /// Text Fields Controller
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  RxBool isLoading = false.obs;

  /// Login & Fields Validation
  void login(
    context, {
    required String email,
    required String password,
  }) {
    if (email.isEmpty || password.isEmpty) {
      SHelperFunctions.showSnackBar("Заполните все поля");
      return;
    }
    if (!SHelperFunctions.isEmailValid(email: email)) {
      SHelperFunctions.showSnackBar("Неверный формат почты");
      return;
    }
    loginUser(context, email: email, password: password);
  }

  /// User Login With Email & Password
  Future<void> loginUser(
    context, {
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      SHelperFunctions.showProgressIndicator(context);

      final AuthResponse response = await SSupabaseHelper.auth
          .signInWithPassword(email: email, password: password);

      if (response.user != null) {
        // Ensure user row exists in 'users' table (created on first login
        // since signup can't insert due to email confirmation RLS).
        await _ensureUserData(response.user!);

        SHelperFunctions.hideProgressIndicator();
        isLoading.value = false;
        SHelperFunctions.showSnackBar('Успешный вход в систему!');
        Get.offAll(() => const MainNavigationScreen());
      }
    } on AuthException catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;

      String errorMessage = 'Ошибка входа';
      switch (e.code) {
        case 'invalid_credentials':
          errorMessage = 'Неверная почта или пароль';
          break;
        case 'email_not_confirmed':
          errorMessage =
              'Подтвердите почту — перейдите по ссылке в письме';
          break;
      }

      SHelperFunctions.showSnackBar(errorMessage);
    } catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;
      SHelperFunctions.showSnackBar('Ошибка входа: $e');
    }
  }

  /// Create user row in 'users' table if it doesn't exist yet.
  Future<void> _ensureUserData(User user) async {
    try {
      final existing = await SSupabaseHelper.client
          .from('users')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existing == null) {
        final displayName =
            user.userMetadata?['display_name'] as String? ?? '';
        await SSupabaseHelper.client.from('users').insert(
              UserModel(
                id: user.id,
                displayName: displayName,
                email: user.email ?? '',
              ).toSupabaseJson(),
            );
      }
    } catch (_) {
      // Non-critical — user can still use the app
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
