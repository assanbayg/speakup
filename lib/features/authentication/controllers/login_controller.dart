import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/screens/main_navigation_screen.dart';
import 'package:speakup/util/helpers/helper_functions.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LoginController extends GetxController {
  /// Text Fields Controller
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  RxBool isLoading = false.obs;

  /// LoginUp & Fields Validations Function
  void login(
    context, {
    required String email,
    required String password,
  }) {
    if (email.isNotEmpty && password.isNotEmpty) {
      if (SHelperFunctions.isEmailValid(email: email)) {
        loginUser(context, email: email, password: password);
      } else {
        SHelperFunctions.showSnackBar("Your email invalid");
      }
    } else {
      SHelperFunctions.showSnackBar("Please Fill All Fields");
    }
  }

  /// User Login With Email & Password Function
  Future<void> loginUser(
    context, {
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      SHelperFunctions.showProgressIndicator(context);

      // Sign in with Supabase Auth
      final AuthResponse response = await SSupabaseHelper.auth
          .signInWithPassword(email: email, password: password);

      if (response.user != null) {
        SHelperFunctions.hideProgressIndicator();
        isLoading.value = false;
        SHelperFunctions.showSnackBar('Успешный вход в систему!');
        Get.offAll(() => const MainNavigationScreen());
      }
    } on AuthException catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;

      // Refer here later:
      // https://supabase.com/docs/guides/auth/debugging/error-codes
      String errorMessage = e.code ?? 'Login failed';
      switch (e.code) {
        case 'invalid_credentials':
          errorMessage = 'Please enter valid credentials';
          break;
      }

      SHelperFunctions.showSnackBar(errorMessage);
    } catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;
      SHelperFunctions.showSnackBar(e.toString());
    }
  }
}
