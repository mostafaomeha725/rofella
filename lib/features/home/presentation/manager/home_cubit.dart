import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/features/admin/data/models/category_model.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';
import 'package:shop/features/home/data/services/category_cache_service.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final List<CategoryModel> categories;
  HomeLoaded(this.categories);
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  final FirebaseService _firebaseService;
  final CategoryCacheService _cacheService;
  StreamSubscription? _categoriesSub;
  bool _hasPrefetched = false;

  HomeCubit({
    required FirebaseService firebaseService,
    required CategoryCacheService cacheService,
  })  : _firebaseService = firebaseService,
        _cacheService = cacheService,
        super(HomeInitial());

  void init() {
    if (state is HomeLoading || state is HomeLoaded) return;
    
    emit(HomeLoading());
    
    _categoriesSub = _firebaseService.getCategories().listen(
      (categories) {
        if (!isClosed) {
          emit(HomeLoaded(categories));
          
          if (!_hasPrefetched) {
            _hasPrefetched = true;
            _prefetchTopCategories(categories);
          }
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(HomeError(error.toString()));
        }
      },
    );
  }

  void _prefetchTopCategories(List<CategoryModel> categories) {
    // Prefetch only the first 3 categories silently in the background
    final topCategories = categories.take(3).toList();
    for (final category in topCategories) {
      _cacheService.prefetch(category.name, limit: 8); // Same limit as UI requests
    }
  }

  @override
  Future<void> close() {
    _categoriesSub?.cancel();
    return super.close();
  }
}
