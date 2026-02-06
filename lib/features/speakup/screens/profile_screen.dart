import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:speakup/common/widgets/app_bar.dart';
import 'package:speakup/features/authentication/screens/login_screen.dart';
import 'package:speakup/features/speakup/models/user_model.dart';
import 'package:speakup/features/speakup/screens/speakers_screen.dart';
import 'package:speakup/features/speakup/screens/sprites_screen.dart';
import 'package:speakup/features/speakup/screens/voice_screen.dart';
import 'package:speakup/util/constants/colors.dart';
import 'package:speakup/util/helpers/helper_functions.dart';
import 'package:speakup/util/helpers/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserModel? userModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Supabase
  Future<void> _loadUserData() async {
    try {
      if (SSupabaseHelper.currentUser != null) {
        final response = await SSupabaseHelper.client
            .from('users')
            .select()
            .eq('id', SSupabaseHelper.currentUser!.id)
            .single();

        setState(() {
          userModel = UserModel.fromJson(response);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      SHelperFunctions.showSnackBar('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = SSupabaseHelper.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Пожалуйста, войдите в систему для доступа к профилю.'),
        ),
      );
    }

    return Scaffold(
      appBar: const SAppBar(title: "Профиль", page: "Profile"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade300,
                      Colors.purple.shade300,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/Person_fill.svg',
                        width: 100,
                        height: 100,
                        colorFilter: ColorFilter.mode(
                          Colors.blueGrey.shade700,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // User Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (userModel?.displayName.isNotEmpty == true)
                      Text(
                        userModel!.displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (userModel?.displayName.isNotEmpty == true)
                      const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              user.email ?? 'Нет электронной почты',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Sprites Button
              _buildActionButton(
                icon: 'assets/icons/Edit.svg',
                label: 'Мои персонажи',
                color: SColors.primary,
                onPressed: () => Get.to(() => const SpritesScreen()),
              ),
              const SizedBox(height: 16),
              // Voice Selection Button
              _buildActionButton(
                icon: 'assets/icons/Audio.svg',
                label: 'Выбор голоса',
                color: Colors.teal,
                onPressed: () => Get.to(() => const SpeakersScreen()),
              ),
              const SizedBox(height: 16),
              // Voice Cloning Button - NEW
              _buildActionButton(
                icon: 'assets/icons/Audio.svg',
                label: 'Мой голос',
                subtitle: 'Клонирование голоса родителя',
                color: Colors.deepPurple,
                onPressed: () => Get.to(() => const VoiceScreen()),
              ),
              const SizedBox(height: 16),
              // Logout Button
              _buildActionButton(
                icon: 'assets/icons/Out_right.svg',
                label: 'Выйти из аккаунта',
                color: Colors.blue,
                onPressed: () async {
                  await SSupabaseHelper.auth.signOut();
                  Get.offAll(const LoginScreen());
                },
              ),
              const SizedBox(height: 16),
              // Delete Account Button
              _buildActionButton(
                icon: 'assets/icons/Delete.svg',
                label: 'Удалить аккаунт',
                color: Colors.red,
                onPressed: () => _confirmDeleteAccount(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    String? subtitle,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  // Confirmation dialog for account deletion
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтвердите удаление'),
          content: const Text(
              'Вы уверены, что хотите удалить свой аккаунт? Это действие необратимо.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteAccount(); // Proceed with deletion
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final response = await http.post(
          Uri.parse("${dotenv.env['BACKEND_URL']}/delete-user"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": user.id}),
        );

        if (response.statusCode == 200) {
          await supabase.auth.signOut();
          Get.offAll(const LoginScreen());
          Get.snackbar('Успех', 'Аккаунт успешно удален.');
        } else {
          Get.snackbar('Ошибка', 'Сервер вернул ошибку: ${response.body}');
        }
      } catch (e) {
        Get.snackbar('Ошибка', 'Не удалось удалить аккаунт: $e');
      }
    }
  }
}
