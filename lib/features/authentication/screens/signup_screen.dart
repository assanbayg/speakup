import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/common/widgets/app_bar.dart';
import 'package:speakup/features/authentication/controllers/signup_controller.dart';
import 'package:speakup/util/constants/colors.dart';
import 'package:speakup/util/constants/sizes.dart';
import 'package:speakup/util/device/device_utility.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignUpController signUpCtrl = Get.put(SignUpController());

    return Scaffold(
      appBar: const SAppBar(
        title: "Создать аккаунт",
        page: "SignUp",
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(SSizes.defaultSpace),
            child: Center(
              child: SizedBox(
                width: SDeviceUtils.getScreenWidth(context) * .8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: signUpCtrl.fullName,
                      decoration: InputDecoration(
                        hintText: "ФИО",
                        prefixIcon: SvgPicture.asset(
                          'assets/icons/Person.svg',
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
                      controller: signUpCtrl.email,
                      decoration: InputDecoration(
                        hintText: "Электронная почта",
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
                    Obx(() => TextFormField(
                          controller: signUpCtrl.password,
                          obscureText: !signUpCtrl.isPasswordVisible.value,
                          decoration: InputDecoration(
                            hintText: "Пароль",
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
                                signUpCtrl.isPasswordVisible.value
                                    ? 'assets/icons/View.svg'
                                    : 'assets/icons/Not_view.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  SColors.darkGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () {
                                signUpCtrl.isPasswordVisible.value =
                                    !signUpCtrl.isPasswordVisible.value;
                              },
                            ),
                          ),
                        )),
                    const SizedBox(height: SSizes.spaceBtwInputFields),
                    Obx(() => TextFormField(
                          controller: signUpCtrl.rePassword,
                          obscureText: !signUpCtrl.isRePasswordVisible.value,
                          decoration: InputDecoration(
                            hintText: "Подтвердите пароль",
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
                                signUpCtrl.isRePasswordVisible.value
                                    ? 'assets/icons/View.svg'
                                    : 'assets/icons/Not_view.svg',
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  SColors.darkGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () {
                                signUpCtrl.isRePasswordVisible.value =
                                    !signUpCtrl.isRePasswordVisible.value;
                              },
                            ),
                          ),
                        )),
                    const SizedBox(height: SSizes.spaceBtwSections),
                    SizedBox(
                      width: SDeviceUtils.getScreenWidth(context) * .8,
                      child: ElevatedButton.icon(
                          onPressed: () => signUpCtrl.signUp(
                                context,
                                fullName: signUpCtrl.fullName.text,
                                email: signUpCtrl.email.text,
                                password: signUpCtrl.password.text,
                                rePassword: signUpCtrl.rePassword.text,
                              ),
                          icon: SvgPicture.asset(
                            'assets/icons/Add_Person.svg',
                            width: 20,
                            height: 20,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          label: const Text("SIGN UP")),
                    ),
                    const SizedBox(height: SSizes.spaceBtwSections / 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
