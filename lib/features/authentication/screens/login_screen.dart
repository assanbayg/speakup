import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/features/authentication/controllers/login_controller.dart';
import 'package:speakup/features/authentication/screens/signup_screen.dart';
import 'package:speakup/util/constants/sizes.dart';
import 'package:speakup/util/device/device_utility.dart';

import '../../../util/constants/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final LoginController loginCtrl = Get.put(LoginController());
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(SSizes.defaultSpace),
          child: Center(
            child: SizedBox(
              width: SDeviceUtils.getScreenWidth(context) * .8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Добро пожаловать в",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 24, fontWeight: FontWeight.w300)),
                  Text("SpeakUP",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const Divider(
                    color: SColors.borderSecondary,
                    thickness: 1,
                    endIndent: SSizes.spaceBtwSections,
                    indent: SSizes.spaceBtwSections,
                  ),
                  SizedBox(
                    height: SDeviceUtils.getScreenHeight(context) * .1,
                  ),
                  TextFormField(
                    controller: loginCtrl.email,
                    decoration: InputDecoration(
                      hintText: "Электронная почта ",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: SColors.borderPrimary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: SColors.borderSecondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: SColors.primary, width: 1.4),
                      ),
                      prefixIcon: SvgPicture.asset(
                        'assets/icons/Mail.svg',
                        width: 20,
                        height: 20,
                        fit: BoxFit.scaleDown,
                        colorFilter: const ColorFilter.mode(
                          SColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: SSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: loginCtrl.password,
                    decoration: InputDecoration(
                      hintText: "Пароль",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: SColors.borderPrimary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: SColors.borderSecondary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: SColors.primary, width: 1.4),
                      ),
                      prefixIcon: SvgPicture.asset(
                        'assets/icons/Protection.svg',
                        width: 20,
                        height: 20,
                        fit: BoxFit.scaleDown,
                        colorFilter: const ColorFilter.mode(
                          SColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: SvgPicture.asset(
                          _obscureText
                              ? 'assets/icons/Not_view.svg'
                              : 'assets/icons/View.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            SColors.darkGrey,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText,
                  ),
                  const SizedBox(height: SSizes.spaceBtwSections),
                  SizedBox(
                      width: SDeviceUtils.getScreenWidth(context) * .8,
                      child: ElevatedButton.icon(
                          onPressed: () => loginCtrl.login(
                                context,
                                email: loginCtrl.email.text.toString(),
                                password: loginCtrl.password.text.toString(),
                              ),
                          icon: SvgPicture.asset(
                            'assets/icons/Arrow_right.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: const Text("LOG IN"))),
                  const SizedBox(height: SSizes.spaceBtwSections / 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Нет аккаунта?",
                          style: Theme.of(context).textTheme.titleLarge),
                      TextButton(
                          onPressed: () {
                            Get.to(() => const SignUpScreen());
                          },
                          child: Text(
                            "Создать аккаунт",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: SColors.primary),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
