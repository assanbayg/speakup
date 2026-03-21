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
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: const SAppBar(title: "Профиль", page: "Profile"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // — Header block: name + email on a flat white surface
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else ...[
                    if (userModel?.displayName.isNotEmpty == true)
                      Text(
                        userModel!.displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                          letterSpacing: -0.3,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // — Section label
            _sectionLabel('Персонализация'),

            // — Settings group
            _settingsGroup([
              _settingsTile(
                icon: 'assets/icons/Edit.svg',
                label: 'Мои персонажи',
                onTap: () => Get.to(() => const SpritesScreen()),
              ),
              _settingsTile(
                icon: 'assets/icons/Audio.svg',
                label: 'Выбор голоса',
                onTap: () => Get.to(() => const SpeakersScreen()),
              ),
              _settingsTile(
                icon: 'assets/icons/Audio.svg',
                label: 'Мой голос',
                subtitle: 'Клонирование голоса родителя',
                onTap: () => Get.to(() => const VoiceScreen()),
                isLast: true,
              ),
            ]),

            const SizedBox(height: 16),

            _sectionLabel('Аккаунт'),

            _settingsGroup([
              _settingsTile(
                icon: 'assets/icons/Out_right.svg',
                label: 'Выйти из аккаунта',
                onTap: () async {
                  await SSupabaseHelper.auth.signOut();
                  Get.offAll(const LoginScreen());
                },
              ),
              _settingsTile(
                icon: 'assets/icons/Delete.svg',
                label: 'Удалить аккаунт',
                labelColor: Colors.red.shade600,
                iconColor: Colors.red.shade500,
                onTap: () => _confirmDeleteAccount(),
                showChevron: false,
                isLast: true,
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsGroup(List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: tiles),
    );
  }

  Widget _settingsTile({
    required String icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    Color? labelColor,
    Color? iconColor,
    bool showChevron = true,
    bool isLast = false,
  }) {
    final effectiveIconColor = iconColor ?? SColors.primary;
    final effectiveLabelColor = labelColor ?? const Color(0xFF1A1A2E);

    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            )
          : BorderRadius.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon container — small, subtle
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      icon,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        effectiveIconColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: effectiveLabelColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showChevron)
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              height: 1,
              thickness: 1,
              indent: 64,
              endIndent: 0,
              color: Colors.grey.shade100,
            ),
        ],
      ),
    );
  }

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
                Navigator.of(context).pop();
                _deleteAccount();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
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
