import 'package:flutter/material.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/utils/spacing.dart';
import 'package:shop/core/widgets/responsive_container.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF9E6566), // Match AppBar color
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Help Customers',
                style: font16w700.copyWith(color: Colors.white),
              ),
              verticalSpacing(16),
              AppText(
                'Cairo,Egypt',
                style: font14w400.copyWith(color: Colors.white),
              ),
              verticalSpacing(8),
              AppText(
                '+201005797956',
                style: font14w400.copyWith(color: Colors.white),
              ),
              verticalSpacing(8),
              AppText(
                'contact@beautyskin-shop.com',
                style: font14w400.copyWith(color: Colors.white),
              ),
              verticalSpacing(24),
              Row(
                children: [
                  _SocialIcon(icon: Icons.facebook),
                  horizontalSpacing(16),
                  _SocialIcon(
                    icon: Icons.camera_alt_outlined,
                  ), // Instagram placeholder
                  horizontalSpacing(16),
                  _SocialIcon(icon: Icons.music_note), // TikTok placeholder
                ],
              ),
              verticalSpacing(32),

              verticalSpacing(24),
              AppText(
                'Copyright © 2026 Beauty & Skin Shop all rights reserved. Powered by Marginis',
                style: font12w400.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const AppText(this.text, {super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style);
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;

  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
      ),
      child: Center(child: Icon(icon, color: Colors.white, size: 20)),
    );
  }
}
