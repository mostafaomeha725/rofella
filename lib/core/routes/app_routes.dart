import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shop/features/splash/presentation/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/features/home/presentation/screens/home_screen.dart';
import 'package:shop/features/cart/presentation/screens/checkout_screen.dart';
import 'package:shop/features/search/presentation/screens/search_screen.dart';
import 'package:shop/features/cart/presentation/screens/cart_screen.dart';
import 'package:shop/features/category/presentation/screens/category_screen.dart';
import 'package:shop/features/product_details/presentation/screens/product_details_screen.dart';
import 'package:shop/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:shop/features/admin/presentation/screens/admin_login_screen.dart';
import 'package:shop/features/admin/presentation/screens/add_product_screen.dart';
import 'package:shop/features/admin/presentation/screens/add_category_screen.dart';
import 'package:shop/features/admin/presentation/screens/admin_categories_list_screen.dart';
import 'package:shop/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:shop/features/admin/presentation/screens/admin_orders_screen.dart';
import '/core/env.dart';
import 'route_observer.dart';
import 'package:shop/features/admin/data/models/product_model.dart';
import 'package:shop/features/admin/data/models/category_model.dart';
import 'route_paths.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final CustomGoRouterObserver customGoRouterObserver = CustomGoRouterObserver();

GoRouter createRouter() {
  return GoRouter(
    initialLocation: Routes.homeScreen,
    navigatorKey: navigatorKey,
    debugLogDiagnostics: true,
    observers: [
      if (isDevEnviroment()) ChuckerFlutter.navigatorObserver,
      // customGoRouterObserver,
    ],
    routes: [
      GoRoute(
        path: Routes.splashScreen,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.homeScreen,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.searchScreen,
        builder: (context, state) {
          final categoryName = state.extra as String?;
          return SearchScreen(categoryName: categoryName);
        },
      ),
      GoRoute(
        path: Routes.wishlistScreen,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: Routes.categoryScreen,
        builder: (context, state) {
          final categoryName = state.extra as String? ?? 'Category';
          return CategoryScreen(categoryName: categoryName);
        },
      ),
      GoRoute(
        path: Routes.productDetailsScreen,
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailsScreen(product: product);
        },
      ),
      GoRoute(
        path: Routes.checkoutScreen,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: Routes.cartScreen,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: Routes.adminLoginScreen,
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: Routes.adminDashboardScreen,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: Routes.adminAddProductScreen,
        builder: (context, state) {
          final productToEdit = state.extra as ProductModel?;
          return AdminAddProductScreen(productToEdit: productToEdit);
        },
      ),
      GoRoute(
        path: Routes.adminAddCategoryScreen,
        builder: (context, state) {
          final categoryToEdit = state.extra as CategoryModel?;
          return AdminAddCategoryScreen(categoryToEdit: categoryToEdit);
        },
      ),
      GoRoute(
        path: Routes.adminCategoriesListScreen,
        builder: (context, state) => const AdminCategoriesListScreen(),
      ),
      GoRoute(
        path: Routes.adminOrdersScreen,
        builder: (context, state) => const AdminOrdersScreen(),
      ),
    ],
  );
}
