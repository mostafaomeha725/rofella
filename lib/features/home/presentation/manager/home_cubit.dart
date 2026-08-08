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
  HomeCubit({
    required FirebaseService firebaseService,
    required CategoryCacheService cacheService,
  })  : _firebaseService = firebaseService,
        _cacheService = cacheService,
        super(HomeInitial());

  void init() {
    if (state is HomeLoading || state is HomeLoaded) return;
    
    emit(HomeLoading());
    
    // 1. Fetch instantly using Future for the first load
    _firebaseService.getCategoriesFuture().then((categories) {
      if (!isClosed && state is! HomeLoaded) {
        emit(HomeLoaded(categories));
      }
    });

    // 2. Listen to real-time updates silently
    _categoriesSub = _firebaseService.getCategories().listen(
      (categories) {
        if (!isClosed) {
          emit(HomeLoaded(categories));
        }
      },
      onError: (error) {
        if (!isClosed && state is! HomeLoaded) {
          emit(HomeError(error.toString()));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _categoriesSub?.cancel();
    return super.close();
  }
}
