import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import 'package:shop/features/cart/data/models/order_model.dart';

class PaginatedProductsResult {
  final List<ProductModel> products;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PaginatedProductsResult({
    required this.products,
    this.lastDocument,
    required this.hasMore,
  });
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'products';
  final String _categoryCollection = 'categories';

  Future<void> _shiftOrdersIfNeeded(
    int newOrder,
    String? excludeId,
    WriteBatch batch,
  ) async {
    if (newOrder == 9999) return;

    final snapshot = await _firestore.collection(_categoryCollection).get();

    final categories = snapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data(), doc.id))
        .where((cat) => cat.id != excludeId && cat.order != 9999)
        .toList();

    categories.sort((a, b) => a.order.compareTo(b.order));

    int currentCheckOrder = newOrder;
    for (var cat in categories) {
      if (cat.order == currentCheckOrder) {
        batch.update(_firestore.collection(_categoryCollection).doc(cat.id), {
          'order': cat.order + 1,
        });
        currentCheckOrder++;
      } else if (cat.order > currentCheckOrder) {
        break;
      }
    }
  }

  Future<String?> addCategory(CategoryModel category) async {
    try {
      final batch = _firestore.batch();
      final newDocRef = _firestore.collection(_categoryCollection).doc();

      await _shiftOrdersIfNeeded(category.order, null, batch);

      batch.set(newDocRef, category.toJson());
      await batch.commit().timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Add Category): $e');
      return e.toString();
    }
  }

  Stream<List<CategoryModel>> getCategories() {
    return _firestore.collection(_categoryCollection).snapshots().map((
      snapshot,
    ) {
      final list = snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data(), doc.id))
          .toList();
      list.sort((a, b) {
        if (a.order != b.order) {
          return a.order.compareTo(b.order);
        }
        return b.createdAt.compareTo(a.createdAt);
      });
      return list;
    });
  }

  Future<List<CategoryModel>> getCategoriesFuture() async {
    try {
      final snapshot = await _firestore
          .collection(_categoryCollection)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 10));
      final list = snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data(), doc.id))
          .toList();
      list.sort((a, b) {
        if (a.order != b.order) {
          return a.order.compareTo(b.order);
        }
        return b.createdAt.compareTo(a.createdAt);
      });
      return list;
    } catch (e) {
      debugPrint('Firebase Fetch Categories Error: $e');
      return [];
    }
  }

  Future<String?> updateCategory(CategoryModel category) async {
    try {
      final batch = _firestore.batch();
      final docRef = _firestore
          .collection(_categoryCollection)
          .doc(category.id);

      await _shiftOrdersIfNeeded(category.order, category.id, batch);

      final updateData = {
        'name': category.name,
        'imageUrl': category.imageUrl,
        'order': category.order,
        // We do not update createdAt
      };
      batch.update(docRef, updateData);

      await batch.commit().timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Update Category): $e');
      return e.toString();
    }
  }

  Future<void> _shiftOrdersDownIfNeeded(
    int deletedOrder,
    WriteBatch batch,
  ) async {
    if (deletedOrder == 9999) return;

    final snapshot = await _firestore.collection(_categoryCollection).get();

    final categories = snapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data(), doc.id))
        .where((cat) => cat.order > deletedOrder && cat.order != 9999)
        .toList();

    categories.sort((a, b) => a.order.compareTo(b.order));

    int currentExpectedOrder = deletedOrder + 1;
    for (var cat in categories) {
      if (cat.order == currentExpectedOrder) {
        batch.update(_firestore.collection(_categoryCollection).doc(cat.id), {
          'order': cat.order - 1,
        });
        currentExpectedOrder++;
      } else if (cat.order > currentExpectedOrder) {
        break;
      }
    }
  }

  Future<String?> deleteCategory(String categoryId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_categoryCollection)
          .doc(categoryId)
          .get();
      if (!docSnapshot.exists) return null;

      final category = CategoryModel.fromJson(
        docSnapshot.data()!,
        docSnapshot.id,
      );

      final batch = _firestore.batch();

      await _shiftOrdersDownIfNeeded(category.order, batch);

      batch.delete(docSnapshot.reference);

      await batch.commit().timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Delete Category): $e');
      return e.toString();
    }
  }

  Future<String?> addProduct(ProductModel product) async {
    try {
      await _firestore
          .collection(_collectionName)
          .add(product.toMap())
          .timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Add Product): $e');
      return e.toString();
    }
  }

  Future<String?> updateProduct(ProductModel product) async {
    try {
      final updateData = {
        'name': product.name,
        'name_lower': product.name.toLowerCase(),
        'description': product.description,
        'price': product.price,
        'oldPrice': product.oldPrice,
        'category': product.category,
        'images': product.images,
        'colors': product.colors,
        'sizes': product.sizes,
        // We do not update createdAt
      };
      await _firestore
          .collection(_collectionName)
          .doc(product.id)
          .update(updateData)
          .timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Update Product): $e');
      return e.toString();
    }
  }

  Future<String?> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(productId)
          .delete()
          .timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Delete Product): $e');
      return e.toString();
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .get()
          .timeout(const Duration(seconds: 10));

      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort locally to avoid needing a Firestore Composite Index
      products.sort((a, b) {
        final dateA = a.createdAt ?? DateTime(2000);
        final dateB = b.createdAt ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      return products;
    } catch (e) {
      debugPrint('Firebase Fetch Error: $e');
      return [];
    }
  }

  Future<PaginatedProductsResult> getPaginatedProductsByCategory(
    String category, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .limit(
            limit + 1,
          ); // Request limit + 1 to check if there is a next page

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get().timeout(const Duration(seconds: 10));

      final docs = snapshot.docs;
      final bool hasMore = docs.length > limit;

      final productsToReturn = hasMore ? docs.sublist(0, limit) : docs;

      final products = productsToReturn
          .map(
            (doc) => ProductModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      final lastDocument = productsToReturn.isNotEmpty
          ? productsToReturn.last
          : null;

      return PaginatedProductsResult(
        products: products,
        lastDocument: lastDocument,
        hasMore: hasMore,
      );
    } catch (e) {
      debugPrint('Firebase Fetch Paginated Error: $e');
      return PaginatedProductsResult(
        products: [],
        lastDocument: null,
        hasMore: false,
      );
    }
  }

  Future<PaginatedProductsResult> searchGlobalProducts(
    String query, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      Query q = _firestore
          .collection(_collectionName)
          .where('name_lower', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('name_lower', isLessThan: lowercaseQuery + '\uf8ff')
          .orderBy('name_lower')
          .limit(limit + 1);

      if (startAfter != null) {
        q = q.startAfterDocument(startAfter);
      }

      final snapshot = await q.get().timeout(const Duration(seconds: 10));
      final docs = snapshot.docs;
      final bool hasMore = docs.length > limit;
      final productsToReturn = hasMore ? docs.sublist(0, limit) : docs;

      final products = productsToReturn
          .map(
            (doc) => ProductModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      return PaginatedProductsResult(
        products: products,
        lastDocument: productsToReturn.isNotEmpty
            ? productsToReturn.last
            : null,
        hasMore: hasMore,
      );
    } catch (e) {
      debugPrint('Firebase Search Global Error: $e');
      return PaginatedProductsResult(
        products: [],
        lastDocument: null,
        hasMore: false,
      );
    }
  }

  Future<PaginatedProductsResult> searchProductsInCategory(
    String category,
    String query, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      Query q = _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .where('name_lower', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('name_lower', isLessThan: lowercaseQuery + '\uf8ff')
          .orderBy('name_lower')
          .limit(limit + 1);

      if (startAfter != null) {
        q = q.startAfterDocument(startAfter);
      }

      final snapshot = await q.get().timeout(const Duration(seconds: 10));
      final docs = snapshot.docs;
      final bool hasMore = docs.length > limit;
      final productsToReturn = hasMore ? docs.sublist(0, limit) : docs;

      final products = productsToReturn
          .map(
            (doc) => ProductModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      return PaginatedProductsResult(
        products: products,
        lastDocument: productsToReturn.isNotEmpty
            ? productsToReturn.last
            : null,
        hasMore: hasMore,
      );
    } catch (e) {
      debugPrint('Firebase Search Category Error: $e');
      return PaginatedProductsResult(
        products: [],
        lastDocument: null,
        hasMore: false,
      );
    }
  }

  @Deprecated('Do not fetch all products. Use paginated methods instead.')
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // --- Orders ---
  final String _ordersCollection = 'orders';

  Future<String?> createOrder(OrderModel order) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .add(order.toMap())
          .timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Create Order): $e');
      return e.toString();
    }
  }

  Stream<List<OrderModel>> getOrders() {
    return _firestore
        .collection(_ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<String?> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .update({'status': newStatus})
          .timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Update Order Status): $e');
      return e.toString();
    }
  }

  Future<String?> deleteOrder(String orderId) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .delete()
          .timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Delete Order): $e');
      return e.toString();
    }
  }

  Future<String?> deleteOrders(List<String> orderIds) async {
    try {
      final batch = _firestore.batch();
      for (final id in orderIds) {
        batch.delete(_firestore.collection(_ordersCollection).doc(id));
      }
      await batch.commit().timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Delete Orders): $e');
      return e.toString();
    }
  }
}
