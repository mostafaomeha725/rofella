import 'package:flutter/foundation.dart';
import 'package:shop/features/admin/data/models/product_model.dart';
import 'package:shop/features/cart/data/models/cart_item_model.dart';

class CartState {
  // Store the list of cart items
  static final ValueNotifier<List<CartItemModel>> cartItemsNotifier = ValueNotifier<List<CartItemModel>>([]);
  
  // Keep cartCountNotifier for backwards compatibility with the UI badges
  static final ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);

  static void addToCart(ProductModel product) {
    final currentItems = List<CartItemModel>.from(cartItemsNotifier.value);
    
    // Check if product already exists in cart
    final existingIndex = currentItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      // Increment quantity if exists
      currentItems[existingIndex].quantity++;
    } else {
      // Add new if it doesn't exist
      currentItems.add(CartItemModel(product: product));
    }
    
    cartItemsNotifier.value = currentItems;
    _updateTotalCount();
  }

  static void incrementQuantity(ProductModel product) {
    final currentItems = List<CartItemModel>.from(cartItemsNotifier.value);
    final index = currentItems.indexWhere((item) => item.product.id == product.id);
    
    if (index >= 0) {
      currentItems[index].quantity++;
      cartItemsNotifier.value = currentItems;
      _updateTotalCount();
    }
  }

  static void decrementQuantity(ProductModel product) {
    final currentItems = List<CartItemModel>.from(cartItemsNotifier.value);
    final index = currentItems.indexWhere((item) => item.product.id == product.id);
    
    if (index >= 0) {
      if (currentItems[index].quantity > 1) {
        currentItems[index].quantity--;
      } else {
        currentItems.removeAt(index);
      }
      cartItemsNotifier.value = currentItems;
      _updateTotalCount();
    }
  }

  static void removeFromCart(ProductModel product) {
    final currentItems = List<CartItemModel>.from(cartItemsNotifier.value);
    currentItems.removeWhere((item) => item.product.id == product.id);
    cartItemsNotifier.value = currentItems;
    _updateTotalCount();
  }

  static void clear() {
    cartItemsNotifier.value = [];
    _updateTotalCount();
  }

  static void _updateTotalCount() {
    // Total count of distinct items or total quantities? 
    // Usually it's total unique items, but let's do total quantity.
    int total = 0;
    for (var item in cartItemsNotifier.value) {
      total += item.quantity;
    }
    cartCountNotifier.value = total;
  }
}
