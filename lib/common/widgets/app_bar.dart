import 'package:flutter/material.dart';
import 'package:speakup/util/constants/sizes.dart';
import 'package:speakup/util/device/device_utility.dart';

class SAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SAppBar({
    super.key,
    required this.title,
    required this.page,
    this.actions,
  });

  final String title;
  final String page;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: .08),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: SSizes.md, vertical: SSizes.sm / 2),
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: actions,
        iconTheme: const IconThemeData());
  }

  @override
  Size get preferredSize => Size.fromHeight(SDeviceUtils.getAppBarHeight());
}
