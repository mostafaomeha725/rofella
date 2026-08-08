import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/features/admin/data/models/product_model.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';

class CategorySectionData {
  List<ProductModel>? products;
  dynamic lastDocument; 
  bool hasMore = true;
  DateTime? lastFetch;

  CategorySectionData({
    this.products,
    this.lastDocument,
    this.hasMore = true,
    this.lastFetch,
  });
}

class CategoryCacheService {
  final int _cacheLimit = 10;
  final LinkedHashMap<String, CategorySectionData> _cache = LinkedHashMap();
  final Map<String, Future<PaginatedProductsResult>> _activeRequests = {};
  final Map<String, Future<PaginatedProductsResult>> _activeSearchRequests = {};
  
  final FirebaseService _firebaseService = FirebaseService(); 

  CategorySectionData? getCached(String category) {
    if (_cache.containsKey(category)) {
      final data = _cache.remove(category)!;
      _cache[category] = data; // LRU move to end
      return data;
    }
    return null;
  }

  Future<CategorySectionData> fetchCategory(String category, {DocumentSnapshot? startAfter, int limit = 8}) async {
    // Deduplication key based on pagination start point
    final reqKey = '${category}_${startAfter?.id ?? 'start'}';
    
    if (_activeRequests.containsKey(reqKey)) {
      final result = await _activeRequests[reqKey]!;
      return _updateCache(category, result, isLoadMore: startAfter != null);
    }

    final req = _firebaseService.getPaginatedProductsByCategory(
      category,
      startAfter: startAfter,
      limit: limit,
    );
    _activeRequests[reqKey] = req;

    try {
      final result = await req;
      return _updateCache(category, result, isLoadMore: startAfter != null);
    } finally {
      _activeRequests.remove(reqKey);
    }
  }

  CategorySectionData _updateCache(String category, PaginatedProductsResult result, {required bool isLoadMore}) {
    CategorySectionData data = getCached(category) ?? CategorySectionData();
    
    if (isLoadMore) {
      final existingProducts = data.products ?? [];
      // To prevent duplicate adds if deduplication fails for some reason
      final newProducts = result.products.where((p) => !existingProducts.any((ep) => ep.id == p.id)).toList();
      data.products = existingProducts..addAll(newProducts);
    } else {
      data.products = result.products;
    }
    data.lastDocument = result.lastDocument;
    data.hasMore = result.hasMore;
    data.lastFetch = DateTime.now();

    if (!_cache.containsKey(category)) {
      if (_cache.length >= _cacheLimit) {
        _cache.remove(_cache.keys.first);
      }
    }
    _cache[category] = data;
    return data;
  }

  Future<void> prefetch(String category, {int limit = 8}) async {
    if (_cache.containsKey(category)) return;
    await fetchCategory(category, limit: limit);
  }

  Future<bool> backgroundRefresh(String category, {int limit = 8}) async {
    // Returns true if data was updated (meaning UI might need to rebuild)
    final reqKey = '${category}_start';
    if (_activeRequests.containsKey(reqKey)) return false;

    final req = _firebaseService.getPaginatedProductsByCategory(
      category,
      limit: limit,
    );
    _activeRequests[reqKey] = req;

    try {
      final result = await req;
      final currentData = _cache[category];
      if (currentData != null && currentData.products != null) {
         final newIds = result.products.map((p) => p.id).join(',');
         final oldIds = currentData.products!.take(limit).map((p) => p.id).join(',');
         if (newIds != oldIds) {
            _updateCache(category, result, isLoadMore: false);
            return true;
         } else {
            currentData.lastFetch = DateTime.now();
            return false;
         }
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _activeRequests.remove(reqKey);
    }
  }

  void clear() {
    _cache.clear();
  }

  List<ProductModel> searchLocalCache(String query, {String? categoryName}) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    final Set<String> addedIds = {};
    final List<ProductModel> results = [];

    for (final entry in _cache.entries) {
      if (categoryName != null && entry.key != categoryName) continue;
      
      final products = entry.value.products ?? [];
      for (final p in products) {
        if (p.id != null && !addedIds.contains(p.id)) {
          final matches = p.name.toLowerCase().contains(lowerQuery) || 
                          p.description.toLowerCase().contains(lowerQuery);
          if (matches) {
            results.add(p);
            addedIds.add(p.id!);
          }
        }
      }
    }
    return results;
  }

  Future<PaginatedProductsResult> performSearch(
    String query, {
    String? categoryName,
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    final reqKey = 'search_${categoryName ?? 'global'}_${query}_${startAfter?.id ?? 'start'}';

    if (_activeSearchRequests.containsKey(reqKey)) {
      return await _activeSearchRequests[reqKey]!;
    }

    Future<PaginatedProductsResult> req;
    if (categoryName != null) {
      req = _firebaseService.searchProductsInCategory(categoryName, query, startAfter: startAfter, limit: limit);
    } else {
      req = _firebaseService.searchGlobalProducts(query, startAfter: startAfter, limit: limit);
    }

    _activeSearchRequests[reqKey] = req;

    try {
      return await req;
    } finally {
      _activeSearchRequests.remove(reqKey);
    }
  }
}
