import 'package:flutter/foundation.dart';
import 'package:shop/features/admin/data/models/product_model.dart';

class WishlistState {
  static final ValueNotifier<List<ProductModel>> wishlistItemsNotifier = ValueNotifier<List<ProductModel>>([]);

  static void toggleWishlist(ProductModel product) {
    final currentItems = List<ProductModel>.from(wishlistItemsNotifier.value);
    
    final existingIndex = currentItems.indexWhere((item) => item.id == product.id);
    
    if (existingIndex >= 0) {
      currentItems.removeAt(existingIndex);
    } else {
      currentItems.add(product);
    }
    
    wishlistItemsNotifier.value = currentItems;
  }

  static bool isInWishlist(String productId) {
    return wishlistItemsNotifier.value.any((item) => item.id == productId);
  }
}
