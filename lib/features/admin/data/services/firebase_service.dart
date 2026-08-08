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

  Future<String?> addCategory(CategoryModel category) async {
    try {
      await _firestore.collection(_categoryCollection).add(category.toJson()).timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Add Category): $e');
      return e.toString();
    }
  }

  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection(_categoryCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  Future<String?> updateCategory(CategoryModel category) async {
    try {
      final updateData = {
        'name': category.name,
        'imageUrl': category.imageUrl,
        // We do not update createdAt
      };
      await _firestore.collection(_categoryCollection).doc(category.id).update(updateData).timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Update Category): $e');
      return e.toString();
    }
  }

  Future<String?> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(_categoryCollection).doc(categoryId).delete().timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Delete Category): $e');
      return e.toString();
    }
  }

  Future<String?> addProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collectionName).add(product.toMap()).timeout(const Duration(seconds: 10));
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
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'images': product.images,
        // We do not update createdAt
      };
      await _firestore.collection(_collectionName).doc(product.id).update(updateData).timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Update Product): $e');
      return e.toString();
    }
  }

  Future<String?> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collectionName).doc(productId).delete().timeout(const Duration(seconds: 10));
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

      final products = snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
      
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
          .limit(limit + 1); // Request limit + 1 to check if there is a next page

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get().timeout(const Duration(seconds: 10));

      final docs = snapshot.docs;
      final bool hasMore = docs.length > limit;
      
      final productsToReturn = hasMore ? docs.sublist(0, limit) : docs;

      final products = productsToReturn
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final lastDocument = productsToReturn.isNotEmpty ? productsToReturn.last : null;

      return PaginatedProductsResult(
        products: products, 
        lastDocument: lastDocument,
        hasMore: hasMore,
      );
    } catch (e) {
      debugPrint('Firebase Fetch Paginated Error: $e');
      return PaginatedProductsResult(products: [], lastDocument: null, hasMore: false);
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
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return PaginatedProductsResult(
        products: products,
        lastDocument: productsToReturn.isNotEmpty ? productsToReturn.last : null,
        hasMore: hasMore,
      );
    } catch (e) {
      debugPrint('Firebase Search Global Error: $e');
      return PaginatedProductsResult(products: [], lastDocument: null, hasMore: false);
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
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return PaginatedProductsResult(
        products: products,
        lastDocument: productsToReturn.isNotEmpty ? productsToReturn.last : null,
        hasMore: hasMore,
      );
    } catch (e) {
      debugPrint('Firebase Search Category Error: $e');
      return PaginatedProductsResult(products: [], lastDocument: null, hasMore: false);
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
      await _firestore.collection(_ordersCollection).add(order.toMap()).timeout(const Duration(seconds: 10));
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
          .update({'status': newStatus}).timeout(const Duration(seconds: 10));
      return null;
    } catch (e) {
      debugPrint('Firebase Error (Update Order Status): $e');
      return e.toString();
    }
  }

  // --- Visitors Stats ---
  
  Future<void> incrementVisit() async {
    try {
      final docRef = _firestore.collection('stats').doc('visits');
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          transaction.set(docRef, {'count': 1});
        } else {
          int newCount = (snapshot.data()?['count'] ?? 0) + 1;
          transaction.update(docRef, {'count': newCount});
        }
      });
    } catch (e) {
      debugPrint('Firebase Error (Increment Visit): $e');
    }
  }

  Stream<int> getVisitCount() {
    return _firestore.collection('stats').doc('visits').snapshots().map((snapshot) {
      if (!snapshot.exists) return 0;
      return snapshot.data()?['count'] ?? 0;
    });
  }

  Future<void> incrementUniqueVisit() async {
    try {
      final docRef = _firestore.collection('stats').doc('unique_visits');
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          transaction.set(docRef, {'count': 1});
        } else {
          int newCount = (snapshot.data()?['count'] ?? 0) + 1;
          transaction.update(docRef, {'count': newCount});
        }
      });
    } catch (e) {
      debugPrint('Firebase Error (Increment Unique Visit): $e');
    }
  }

  Stream<int> getUniqueVisitCount() {
    return _firestore.collection('stats').doc('unique_visits').snapshots().map((snapshot) {
      if (!snapshot.exists) return 0;
      return snapshot.data()?['count'] ?? 0;
    });
  }
}
