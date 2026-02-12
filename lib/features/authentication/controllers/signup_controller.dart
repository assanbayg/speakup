import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/models/user_model.dart';
import 'package:speakup/features/speakup/screens/main_navigation_screen.dart';
import 'package:speakup/util/helpers/helper_functions.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpController extends GetxController {
  /// Text Fields Controller
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController fullName = TextEditingController();
  final TextEditingController rePassword = TextEditingController();

  /// Password Visibility Toggles
  RxBool isPasswordVisible = false.obs;
  RxBool isRePasswordVisible = false.obs;
  RxBool isLoading = false.obs;

  // Sign Up Function
  void signUp(
    BuildContext context, {
    required String fullName,
    required String email,
    required String password,
    required String rePassword,
  }) {
    // Validate Fields
    if (email.isEmpty ||
        fullName.isEmpty ||
        password.isEmpty ||
        rePassword.isEmpty) {
      SHelperFunctions.showSnackBar("Заполните все поля");
      return;
    }
    if (!SHelperFunctions.isEmailValid(email: email)) {
      SHelperFunctions.showSnackBar("Неверный формат почты");
      return;
    }
    if (password != rePassword) {
      SHelperFunctions.showSnackBar("Пароли не совпадают");
      return;
    }
    if (password.length < 6) {
      SHelperFunctions.showSnackBar(
          "Пароль должен содержать не менее 6 символов");
      return;
    }

    signUpUser(context, fullName: fullName, email: email, password: password);
  }

  /// User SignUp With Mail & Password Function
  Future<void> signUpUser(
    BuildContext context, {
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      SHelperFunctions.showProgressIndicator(context);

      // Sign up user with Supabase Auth (email confirmation disabled)
      final AuthResponse response = await SSupabaseHelper.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': fullName},
      );

      if (response.user != null) {
        // Create user row in 'users' table
        await SSupabaseHelper.client.from('users').insert(
              UserModel(
                id: response.user!.id,
                displayName: fullName,
                email: email,
              ).toSupabaseJson(),
            );

        SHelperFunctions.hideProgressIndicator();
        isLoading.value = false;
        SHelperFunctions.showSnackBar('Аккаунт создан!');
        Get.offAll(() => const MainNavigationScreen());
      }
    } on AuthException catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;

      String errorMessage = 'Ошибка регистрации';
      switch (e.code) {
        case 'email_exists':
        case 'user_already_exists':
          errorMessage = 'Аккаунт с этой почтой уже существует';
          break;
        case 'invalid_credentials':
          errorMessage = 'Введите корректные данные';
          break;
        default:
          errorMessage = e.message;
      }

      SHelperFunctions.showSnackBar(errorMessage);
    } catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;
      SHelperFunctions.showSnackBar('Ошибка регистрации: $e');
    }
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    fullName.dispose();
    rePassword.dispose();
    super.onClose();
  }
}
