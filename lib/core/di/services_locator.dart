import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/core/cache/preferences_storage.dart';
import 'package:shop/core/network/network_service.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';
import 'package:shop/features/admin/data/services/image_compression_service.dart';
import 'package:shop/features/admin/data/services/analytics_service.dart';
import 'package:shop/features/admin/data/services/cloudinary_service.dart';
import 'package:shop/features/home/data/services/category_cache_service.dart';
import 'package:shop/features/home/presentation/manager/home_cubit.dart';
import 'package:shop/features/search/presentation/manager/search_cubit.dart';
import 'package:shop/features/admin/presentation/manager/admin_cubit.dart';

final sl = GetIt.instance;

class ServiceLocator {
  Future<void> initDependencies() async {
    await _initCore();
    _initAuth();
  }

  Future<void> _initCore() async {
    await _initStorage();
    _initDio();
    _initFirebase();
  }

  void _initFirebase() {
    sl.registerLazySingleton(() => FirebaseService());
    sl.registerLazySingleton(() => CategoryCacheService());
    sl.registerLazySingleton(() => ImageCompressionService());
    sl.registerLazySingleton(() => AnalyticsService());
    sl.registerLazySingleton(() => CloudinaryService());
    sl.registerLazySingleton(() => HomeCubit(
          firebaseService: sl(),
          cacheService: sl(),
        ));
    sl.registerFactory(() => AdminCubit(sl()));
    sl.registerFactoryParam<SearchCubit, String?, dynamic>(
      (categoryName, _) => SearchCubit(
        cacheService: sl(),
        categoryName: categoryName,
      ),
    );
  }

  /// =============================
  /// STORAGE & SERVICES
  /// =============================
  Future<void> _initStorage() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton(() => sharedPreferences);
    sl.registerLazySingleton(() => PreferencesStorage(sl()));
    // sl.registerLazySingleton(() => UserRoleService(sl()));
    // sl.registerLazySingleton(() => NotificationService());
    // sl.registerLazySingleton(() => SignalRService(sl()));
    // sl.registerLazySingleton(() => StripeService());
  }

  /// =============================
  /// NETWORK
  /// =============================
  void _initDio() {
    sl.registerLazySingleton(() => Dio());
    sl.registerLazySingleton(() => NetworkService(sl()));
  }

  /// =============================
  /// AUTH FEATURE
  /// =============================
  void _initAuth() {
    // DataSource
    // if (!sl.isRegistered<AuthRemoteDataSource>()) {
    //   sl.registerLazySingleton<AuthRemoteDataSource>(
    //     () => AuthRemoteDataSourceImpl(sl()),
    //   );
    // }

    // Repository

    // Use Cases
  }
}
