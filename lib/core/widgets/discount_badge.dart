import 'package:flutter/material.dart';
import 'package:shop/core/widgets/custom_text.dart';

import 'package:shop/core/theme/styles.dart';

class DiscountBadge extends StatelessWidget {
  final String text;

  const DiscountBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF67232B), // Maroon
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AppText(
              text,
              textAlign: TextAlign.center,
              style: font12w700.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const Icon(
            Icons.flash_on,
            color: Colors.white,
            size: 14,
          ),
        ],
      ),
    );
  }
}
