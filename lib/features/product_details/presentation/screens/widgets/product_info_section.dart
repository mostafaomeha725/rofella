import 'package:flutter/material.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/core/theme/styles.dart';

class ProductInfoSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String? oldPrice;

  const ProductInfoSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    this.oldPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            subtitle,
            style: font14w400.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            alignment: AlignmentDirectional.center,
          ),
          const SizedBox(height: 12),
          AppText(
            title,
            style: font22w500.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            alignment: AlignmentDirectional.center,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 24),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              AppText(
                price,
                style: font28w500.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                alignment: AlignmentDirectional.center,
              ),
              if (oldPrice != null) ...[
                const SizedBox(width: 12),
                AppText(
                  oldPrice!,
                  style: font22w500.copyWith(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                  textAlign: TextAlign.center,
                  alignment: AlignmentDirectional.center,
                ),
              ],
            ],
          ),
          ),
        ],
      ),
    );
  }
}
