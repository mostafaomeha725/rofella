import 'package:flutter/material.dart';
import 'package:shop/core/widgets/custom_button.dart';

import 'package:shop/core/utils/cart_state.dart';
import 'package:shop/features/admin/data/models/product_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:shop/core/utils/cart_animation_service.dart';

class AddToCartButton extends StatelessWidget {
  final ProductModel product;
  final GlobalKey? imageKey;

  const AddToCartButton({super.key, required this.product, this.imageKey});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Add To Cart',
      onPressed: () async {
        CartState.addToCart(product);
        if (imageKey != null) {
          await CartAnimationService.runAddToCartAnimation(imageKey!);
        } else {
          EasyLoading.showSuccess('تمت الإضافة للسلة');
        }
      },
      height: 40,
      color: Color(0xFFF7DEB1), // Cream background
      textColor: Color(0xFF5C2428), // Maroon text
      textSize: 14,
      textWeight: FontWeight.w600,
      radius: 20,
      margin: EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
