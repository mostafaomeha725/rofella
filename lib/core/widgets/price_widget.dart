import 'package:flutter/material.dart';
import 'package:shop/core/widgets/custom_text.dart';

import 'package:shop/core/theme/styles.dart';

class PriceWidget extends StatelessWidget {
  final String currentPrice;
  final String? oldPrice;

  const PriceWidget({super.key, required this.currentPrice, this.oldPrice});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: currentPrice,
              style: font14w700.copyWith(color: const Color(0xFF5C2428)),
            ),
            if (oldPrice != null) ...[
              const TextSpan(text: '  '),
              TextSpan(
                text: oldPrice!,
                style: font12w400.copyWith(
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
