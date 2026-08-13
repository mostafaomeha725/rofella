import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shop/core/utils/cart_state.dart';
import 'package:shop/core/routes/route_paths.dart';
import 'package:shop/features/admin/data/models/category_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/features/home/presentation/manager/home_cubit.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:shop/core/utils/cart_animation_service.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? categoryName;
  const HomeAppBar({super.key, this.categoryName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF9E6566), // Elegant Maroon/Rose
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown-like icon
          SizedBox(height: 8),
          const Text(
            'Beauty & Skin',
            style: TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 20,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '— Shine with Elegance —',
            style: TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 24),
          onPressed: () {
            context.push(Routes.searchScreen, extra: categoryName);
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            AddToCartIcon(
              key: ModalRoute.of(context)?.isCurrent == true
                  ? CartAnimationService.cartKey
                  : GlobalKey<CartIconKey>(),
              badgeOptions: const BadgeOptions(active: false),
              icon: IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => context.push(Routes.cartScreen),
              ),
            ),
            Positioned(
              right: 6,
              top: 8,
              child: IgnorePointer(
                child: ValueListenableBuilder<int>(
                  valueListenable: CartState.cartCountNotifier,
                  builder: (context, count, child) {
                    if (count == 0) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Pill shape for large numbers
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 99
                            ? '99+'
                            : '$count', // Cap at 99+ for clean UI
                        style: const TextStyle(
                          color: Color(0xFF9E6566),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(85);
}

class HomeSliverAppBar extends StatelessWidget {
  final String? categoryName;
  const HomeSliverAppBar({super.key, this.categoryName});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 1024;

    final Widget logoWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Beauty & Skin',
          style: TextStyle(
            fontFamily: 'serif',
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '— Shine with Elegance —',
          style: TextStyle(
            fontFamily: 'serif',
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );

    return SliverAppBar(
      backgroundColor: const Color(0xFF9E6566), // Elegant Maroon/Rose
      elevation: 0,
      centerTitle: !isDesktop,
      floating: true,
      snap: true,
      pinned: false,
      toolbarHeight: 85,
      automaticallyImplyLeading: !isDesktop,
      leading: isDesktop
          ? null
          : Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            ),
      title: isDesktop
          ? Row(
              children: [
                logoWidget,
                const SizedBox(width: 32),
                const Expanded(child: Center(child: DesktopCategoriesRow())),
              ],
            )
          : logoWidget,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 24),
          onPressed: () {
            context.push(Routes.searchScreen, extra: categoryName);
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            AddToCartIcon(
              key: ModalRoute.of(context)?.isCurrent == true
                  ? CartAnimationService.cartKey
                  : GlobalKey<CartIconKey>(),
              badgeOptions: const BadgeOptions(active: false),
              icon: IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => context.push(Routes.cartScreen),
              ),
            ),
            Positioned(
              right: 6,
              top: 8,
              child: IgnorePointer(
                child: ValueListenableBuilder<int>(
                  valueListenable: CartState.cartCountNotifier,
                  builder: (context, count, child) {
                    if (count == 0) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Color(0xFF9E6566),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class DesktopCategoriesRow extends StatelessWidget {
  const DesktopCategoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).uri.toString();
    final Object? extra = GoRouterState.of(context).extra;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        }
        
        List<CategoryModel> categories = [];
        if (state is HomeLoaded) {
          categories = state.categories;
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavBarItem(
                title: 'Home',
                isSelected:
                    (currentRoute == Routes.homeScreen ||
                        currentRoute == '/') &&
                    extra == null,
                onTap: () {
                  if (currentRoute != Routes.homeScreen)
                    context.go(Routes.homeScreen);
                },
              ),
              ...categories.map((category) {
                return _NavBarItem(
                  title: category.name,
                  isSelected: extra == category.name,
                  onTap: () {
                    context.push(Routes.categoryScreen, extra: category.name);
                  },
                );
              }),
              _NavBarItem(
                title: 'Wishlist',
                isSelected: currentRoute == Routes.wishlistScreen,
                onTap: () {
                  if (currentRoute != Routes.wishlistScreen)
                    context.push(Routes.wishlistScreen);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                color: Colors.white,
              )
            else
              const SizedBox(
                height: 6,
              ), // Keep space equivalent to line + margin
          ],
        ),
      ),
    );
  }
}
