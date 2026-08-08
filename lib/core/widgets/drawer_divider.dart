import 'package:flutter/material.dart';

class DrawerDivider extends StatelessWidget {
  const DrawerDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(
        color: Colors.white.withValues(alpha: 0.5), // Faint light divider
        thickness: 1.0,
        height: 1.0,
      ),
    );
  }
}
