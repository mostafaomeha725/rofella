import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/features/admin/data/models/product_model.dart';
import 'package:shop/features/home/data/services/category_cache_service.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ProductModel> products;
  final bool hasSearchedNetwork;
  final bool hasMoreNetwork;
  final bool isNetworkLoadingMore;
  
  SearchLoaded({
    required this.products,
    this.hasSearchedNetwork = false,
    this.hasMoreNetwork = false,
    this.isNetworkLoadingMore = false,
  });

  SearchLoaded copyWith({
    List<ProductModel>? products,
    bool? hasSearchedNetwork,
    bool? hasMoreNetwork,
    bool? isNetworkLoadingMore,
  }) {
    return SearchLoaded(
      products: products ?? this.products,
      hasSearchedNetwork: hasSearchedNetwork ?? this.hasSearchedNetwork,
      hasMoreNetwork: hasMoreNetwork ?? this.hasMoreNetwork,
      isNetworkLoadingMore: isNetworkLoadingMore ?? this.isNetworkLoadingMore,
    );
  }
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchCubit extends Cubit<SearchState> {
  final CategoryCacheService _cacheService;
  final String? categoryName;
  
  DocumentSnapshot? _lastDocument;
  String _currentQuery = '';

  SearchCubit({
    required CategoryCacheService cacheService,
    this.categoryName,
  })  : _cacheService = cacheService,
        super(SearchInitial());

  void searchLocal(String query) {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    
    _currentQuery = query;
    _lastDocument = null;

    emit(SearchLoading());

    // Instant local search
    final localResults = _cacheService.searchLocalCache(query, categoryName: categoryName);
    
    emit(SearchLoaded(
      products: localResults,
      hasSearchedNetwork: false,
      hasMoreNetwork: true, // Allow user to request network search if local results are insufficient
    ));
  }

  Future<void> searchNetwork() async {
    if (_currentQuery.isEmpty) return;

    final currentState = state;
    List<ProductModel> existingProducts = [];
    
    if (currentState is SearchLoaded) {
      existingProducts = currentState.products;
      emit(currentState.copyWith(isNetworkLoadingMore: true));
    } else {
      emit(SearchLoading());
    }

    try {
      final result = await _cacheService.performSearch(
        _currentQuery,
        categoryName: categoryName,
        startAfter: _lastDocument,
        limit: 20,
      );

      _lastDocument = result.lastDocument;
      
      // Merge results to prevent duplicates between local cache hits and network hits
      final Set<String> existingIds = existingProducts.map((e) => e.id!).toSet();
      final newUniqueProducts = result.products.where((p) => p.id != null && !existingIds.contains(p.id)).toList();
      
      final combinedProducts = [...existingProducts, ...newUniqueProducts];

      emit(SearchLoaded(
        products: combinedProducts,
        hasSearchedNetwork: true,
        hasMoreNetwork: result.hasMore,
        isNetworkLoadingMore: false,
      ));
    } catch (e) {
      emit(SearchError('Failed to search server: $e'));
    }
  }
}
