import 'package:flutter/material.dart';
import 'package:shop/core/widgets/bouncing_widgets.dart';

import 'package:shop/features/admin/data/models/product_model.dart';
import 'package:shop/core/utils/wishlist_state.dart';

class FavoriteButton extends StatelessWidget {
  final ProductModel product;

  const FavoriteButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      onPressed: () {
        WishlistState.toggleWishlist(product);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ValueListenableBuilder<List<ProductModel>>(
          valueListenable: WishlistState.wishlistItemsNotifier,
          builder: (context, wishlist, child) {
            final isFavorite = WishlistState.isInWishlist(product.id ?? '');
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut,
                  )),
                  child: child,
                );
              },
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(isFavorite),
                color: isFavorite ? Colors.red : Colors.black,
                size: 20,
              ),
            );
          },
        ),
      ),
    );
  }
}
