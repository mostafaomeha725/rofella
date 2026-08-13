import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/features/admin/data/models/product_model.dart';
import 'package:shop/features/admin/data/models/category_model.dart';
import 'package:shop/features/cart/data/models/order_model.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final int ordersCount;
  final int totalVisits;
  final int uniqueDevices;

  AdminDashboardLoaded({
    required this.products, 
    required this.categories,
    required this.ordersCount,
    required this.totalVisits,
    required this.uniqueDevices,
  });
}

class AdminCategoriesLoaded extends AdminState {
  final List<CategoryModel> categories;
  AdminCategoriesLoaded(this.categories);
}

class AdminOrdersLoaded extends AdminState {
  final List<OrderModel> orders;
  AdminOrdersLoaded(this.orders);
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

class AdminCubit extends Cubit<AdminState> {
  final FirebaseService _firebaseService;
  StreamSubscription? _productsSub;
  StreamSubscription? _categoriesSub;
  StreamSubscription? _ordersSub;

  StreamSubscription? _analyticsSub;

  AdminCubit(this._firebaseService) : super(AdminInitial());

  void initDashboard() {
    _categoriesSub?.cancel();
    _productsSub?.cancel();
    _ordersSub?.cancel();
    _analyticsSub?.cancel();
    
    emit(AdminLoading());

    List<CategoryModel> currentCategories = [];
    List<ProductModel> currentProducts = [];
    int currentOrdersCount = 0;
    int currentVisits = 0;
    int currentUnique = 0;
    
    void updateState() {
      if (!isClosed) {
        emit(AdminDashboardLoaded(
          products: currentProducts, 
          categories: currentCategories,
          ordersCount: currentOrdersCount,
          totalVisits: currentVisits,
          uniqueDevices: currentUnique,
        ));
      }
    }

    _categoriesSub = _firebaseService.getCategories().listen((categories) {
      currentCategories = categories;
      updateState();
    }, onError: (e) {
      if (!isClosed) emit(AdminError(e.toString()));
    });

    _productsSub = _firebaseService.getProducts().listen((products) {
      currentProducts = products;
      updateState();
    }, onError: (e) {
      if (!isClosed) emit(AdminError(e.toString()));
    });
    
    _ordersSub = _firebaseService.getOrders().listen((orders) {
      currentOrdersCount = orders.length;
      updateState();
    }, onError: (e) {
      if (!isClosed) emit(AdminError(e.toString()));
    });

    _analyticsSub = FirebaseFirestore.instance
        .collection('analytics')
        .doc('stats')
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      currentVisits = (data?['totalVisits'] as int?) ?? 0;
      currentUnique = (data?['uniqueDevices'] as int?) ?? 0;
      updateState();
    }, onError: (e) {
      if (!isClosed) emit(AdminError(e.toString()));
    });
  }

  void initCategories() {
    _categoriesSub?.cancel();
    emit(AdminLoading());
    _categoriesSub = _firebaseService.getCategories().listen((categories) {
      if (!isClosed) emit(AdminCategoriesLoaded(categories));
    }, onError: (e) {
      if (!isClosed) emit(AdminError(e.toString()));
    });
  }

  void initOrders() {
    _ordersSub?.cancel();
    emit(AdminLoading());
    _ordersSub = _firebaseService.getOrders().listen((orders) {
      if (!isClosed) emit(AdminOrdersLoaded(orders));
    }, onError: (e) {
      if (!isClosed) emit(AdminError(e.toString()));
    });
  }

  @override
  Future<void> close() {
    _productsSub?.cancel();
    _categoriesSub?.cancel();
    _ordersSub?.cancel();
    _analyticsSub?.cancel();
    return super.close();
  }
}
