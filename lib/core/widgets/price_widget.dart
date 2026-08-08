import 'package:flutter/material.dart';
import 'package:shop/core/widgets/custom_text.dart';

import 'package:shop/core/theme/styles.dart';

class PriceWidget extends StatelessWidget {
  final String currentPrice;
  final String? oldPrice;

  const PriceWidget({super.key, required this.currentPrice, this.oldPrice});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          currentPrice,
          style: font14w700.copyWith(color: const Color(0xFF5C2428)),
        ),
        if (oldPrice != null) ...[
          const SizedBox(width: 8),
          AppText(
            oldPrice!,
            style: font12w400.copyWith(
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}
