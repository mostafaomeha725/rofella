import 'package:flutter/material.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/core/theme/styles.dart';

import 'package:shop/features/admin/data/models/product_model.dart';
import 'package:shop/core/utils/cart_state.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AddToCartBottomBar extends StatefulWidget {
  final ProductModel product;

  const AddToCartBottomBar({super.key, required this.product});

  @override
  State<AddToCartBottomBar> createState() => _AddToCartBottomBarState();
}

class _AddToCartBottomBarState extends State<AddToCartBottomBar> {
  int quantity = 1;

  void increment() {
    setState(() {
      quantity++;
    });
  }

  void decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector
            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.black87),
                    onPressed: decrement,
                  ),
                  SizedBox(
                    width: 30,
                    child: AppText(
                      '$quantity',
                      style: font16w600.copyWith(color: Colors.black87),
                      textAlign: TextAlign.center,
                      alignment: AlignmentDirectional.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black87),
                    onPressed: increment,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Add to Cart Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    for (int i = 0; i < quantity; i++) {
                      CartState.addToCart(widget.product);
                    }
                    EasyLoading.showSuccess('تم إضافة $quantity إلى السلة');
                    
                    // Reset quantity after adding
                    setState(() {
                      quantity = 1;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: AppText(
                    'أضف للسلة',
                    style: font18w700.copyWith(color: Colors.blue),
                    alignment: AlignmentDirectional.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
