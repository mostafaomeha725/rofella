import 'package:flutter/material.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/core/theme/styles.dart';

class ProductDescriptionSection extends StatelessWidget {
  final String description;

  const ProductDescriptionSection({
    super.key, 
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'وصف المنتج',
              style: font18w700.copyWith(color: const Color(0xFF5C2428)),
            ),
            const SizedBox(height: 12),
            AppText(
              description,
              style: font14w400.copyWith(color: Colors.grey[700], height: 1.5),
              maxLines: 20, // increased max lines to fit real descriptions
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
