import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shop/core/utils/cart_state.dart';
import 'package:shop/core/routes/route_paths.dart';
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
            'ROFELLA',
            style: TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 24,
              letterSpacing: 4.0,
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
