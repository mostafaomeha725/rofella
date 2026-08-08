import 'package:flutter/material.dart';
import 'package:shop/core/widgets/custom_text.dart';

import 'package:shop/core/theme/styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: AppText(
        title,
        alignment: AlignmentDirectional.center,
        style: font24w700.copyWith(
          color: const Color(0xFF5C2428), // Maroon
        ),
      ),
    );
  }
}
