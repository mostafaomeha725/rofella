import 'package:flutter/material.dart';

import 'package:shop/core/utils/url_launcher_util.dart';

class WhatsappFloatingButton extends StatelessWidget {
  const WhatsappFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UrlLauncherUtil.launchWhatsApp(
          phone: '+201005797956',
          message: 'مرحباً، لدي استفسار بخصوص المنتجات.',
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFF25D366),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.chat,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
