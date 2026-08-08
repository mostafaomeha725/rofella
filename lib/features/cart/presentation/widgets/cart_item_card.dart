import 'package:flutter/material.dart';
import 'package:shop/core/widgets/app_image.dart';
import 'package:shop/core/theme/styles.dart';

import 'package:shop/features/cart/data/models/cart_item_model.dart';
import 'package:shop/core/utils/cart_state.dart';
import 'package:shop/core/widgets/favorite_button.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/routes/route_paths.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel cartItem;

  const CartItemCard({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final product = cartItem.product;
    final imageUrl = product.images.isNotEmpty
        ? product.images.first
        : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () => context.push(Routes.productDetailsScreen, extra: product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0, left: 16, right: 16),
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      // Left Column (Title, Subtitle, Price, Delete)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title & Subtitle (Gradient)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: font16w600.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        colors: [
                                          Colors.pinkAccent,
                                          Colors.cyan,
                                        ],
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                      ).createShader(bounds),
                                  child: Text(
                                    product.category.toUpperCase(),
                                    style: font16w600.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Price Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'السعر',
                                  style: font12w400.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                    height: 1.2,
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      product.price.toStringAsFixed(2),
                                      style: font16w600.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ج.م',
                                      style: font16w600.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF5C2428),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Delete Button
                            InkWell(
                              onTap: () => CartState.removeFromCart(product),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCEEED),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFE2434B),
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Right Column (Image & Quantity)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Image
                          Expanded(
                            child: Center(
                              child: AppImage(
                                imageUrl: imageUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Quantity Controls
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Directionality(
                              textDirection:
                                  TextDirection.ltr, // LTR to match: - | 1 | +
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () =>
                                        CartState.decrementQuantity(product),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF5C2428),
                                        borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(8),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${cartItem.quantity}',
                                      style: font14w700.copyWith(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        CartState.incrementQuantity(product),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF5C2428),
                                        borderRadius: BorderRadius.horizontal(
                                          right: Radius.circular(8),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Favorite Button
              Positioned(
                top: 12,
                left: 12, // Visual left in RTL
                child: FavoriteButton(product: product),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
