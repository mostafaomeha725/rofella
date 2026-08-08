import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/routes/app_routes.dart';
import 'package:shop/core/theme/light_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop/firebase_options.dart';
import 'package:shop/core/di/services_locator.dart';

import 'package:shop/features/admin/data/services/firebase_service.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:shop/core/utils/cart_animation_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator().initDependencies();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    final firebaseService = FirebaseService();
    // Track app visit (Total opens)
    firebaseService.incrementVisit();

    // Track unique app visit
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('visitor_uuid')) {
      final uuid = const Uuid().v4();
      await prefs.setString('visitor_uuid', uuid);
      await firebaseService.incrementUniqueVisit();
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = createRouter();

    return ScreenUtilInit(
      designSize: const Size(420, 910),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Shop App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: AppLightColors.defaultBackground,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppLightColors.primary,
            ),
          ),
          scrollBehavior: const RightScrollbarBehavior(),
          routerConfig: router,
          builder: (context, child) {
            final easyLoading = EasyLoading.init();
            child = easyLoading(context, child);
            return AddToCartAnimation(
              cartKey: CartAnimationService.cartKey,
              height: 30,
              width: 30,
              opacity: 0.85,
              dragAnimation: const DragToCartAnimationOptions(rotation: true),
              jumpAnimation: const JumpAnimationOptions(),
              createAddToCartAnimation: (runAddToCartAnimation) {
                CartAnimationService.runAddToCartAnimation =
                    runAddToCartAnimation;
              },
              child: child,
            );
          },
        );
      },
    );
  }
}

class RightScrollbarBehavior extends MaterialScrollBehavior {
  const RightScrollbarBehavior();

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return Scrollbar(
          controller: details.controller,
          scrollbarOrientation: ScrollbarOrientation.right,
          child: child,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
    }
  }
}
