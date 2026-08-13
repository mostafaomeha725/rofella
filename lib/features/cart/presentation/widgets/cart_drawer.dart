import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/routes/route_paths.dart';
import 'package:shop/core/utils/cart_state.dart';
import 'package:shop/features/cart/data/models/cart_item_model.dart';
import 'cart_item_card.dart';

class CartDrawer extends StatelessWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ValueListenableBuilder<List<CartItemModel>>(
          valueListenable: CartState.cartItemsNotifier,
          builder: (context, cartItems, child) {
            double totalAmount = 0;
            for (var item in cartItems) {
              totalAmount += item.totalPrice;
            }

            return Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => context.pop(),
                      ),
                      AppText(
                        'سلة التسوق (${CartState.cartCountNotifier.value})',
                        style: font22w500.copyWith(color: Colors.black87),
                      ),
                      const SizedBox(width: 48), // Balance for centering
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEEEEEE),
                ),

                // Cart Items
                Flexible(
                  child: cartItems.isEmpty
                      ? Center(
                          child: AppText(
                            'السلة فارغة',
                            style: font16w600.copyWith(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          itemCount: cartItems.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 32,
                            color: Color(0xFFEEEEEE),
                          ),
                          itemBuilder: (context, index) {
                            return CartItemCard(cartItem: cartItems[index]);
                          },
                        ),
                ),

                // Footer (Total & Buttons)
                if (cartItems.isNotEmpty) ...[
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              'EGP ${totalAmount.toInt().toString()}',
                              style: font16w600.copyWith(color: Colors.black87),
                            ),
                            AppText(
                              'اجمالي المنتجات',
                              style: font16w600.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              context.pop(); // Close drawer
                              context.push(
                                Routes.checkoutScreen,
                              ); // Go to checkout
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: AppText(
                              'إتمام الطلب',
                              style: font18w700.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
