import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speakup/features/speakup/models/user_model.dart';
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
      {
        SHelperFunctions.showSnackBar("Заполните все поля");
        return;
      }
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

      // Sign up user with Supabase Auth
      final AuthResponse response = await SSupabaseHelper.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': fullName}, // Store display name in auth metadata
      );

      if (response.user != null) {
        await uploadUserData(UserModel(
          id: response.user!.id,
          displayName: fullName,
          email: email,
        ));
        SHelperFunctions.hideProgressIndicator();
        isLoading.value = false;
        return;
      }
    } on AuthException catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;

      // Refer here later:
      // https://supabase.com/docs/guides/auth/debugging/error-codes
      String errorMessage = 'Registration failed';
      switch (e.code) {
        case 'email_exists':
          errorMessage = 'An account with this email already exists';
          break;
        case 'invalid_credentials':
          errorMessage = 'Please enter valid credentials';
          break;
        default:
          errorMessage = e.code!;
      }

      SHelperFunctions.showSnackBar(errorMessage);
    } catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;
      SHelperFunctions.showSnackBar('Registration failed: $e');
    }
  }

  /// Upload User Data to Supabase Database
  Future<void> uploadUserData(UserModel user) async {
    try {
      await SSupabaseHelper.client.from('users').insert({
        'id': user.id,
        'display_name': user.displayName,
        'email': user.email,
      });
    } catch (e) {
      SHelperFunctions.hideProgressIndicator();
      isLoading.value = false;
      SHelperFunctions.showSnackBar("Error uploading user data: $e");
      rethrow;
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
