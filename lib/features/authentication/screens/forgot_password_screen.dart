import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:speakup/common/widgets/app_bar.dart';
import 'package:speakup/features/authentication/controllers/forgot_password_controller.dart';
import 'package:speakup/util/constants/colors.dart';
import 'package:speakup/util/constants/sizes.dart';
import 'package:speakup/util/device/device_utility.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller =
        Get.put(ForgotPasswordController());

    return Scaffold(
      appBar: const SAppBar(
        title: "Сброс пароля",
        page: "ForgotPassword",
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
                    Text(
                      "Введите почту, привязанную к аккаунту, и мы отправим ссылку для сброса пароля",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SSizes.spaceBtwSections),
                    TextFormField(
                      controller: controller.email,
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
                    const SizedBox(height: SSizes.spaceBtwSections),
                    SizedBox(
                      width: SDeviceUtils.getScreenWidth(context) * .8,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.resetPassword(context),
                        icon: SvgPicture.asset(
                          'assets/icons/Mail.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        label: const Text("ОТПРАВИТЬ ССЫЛКУ"),
                      ),
                    ),
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
