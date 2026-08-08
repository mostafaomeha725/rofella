import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/routes/route_paths.dart';
import 'package:shop/features/admin/data/models/category_model.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';

import 'custom_drawer_header.dart';
import 'drawer_item.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final String currentRoute = GoRouterState.of(context).uri.toString();
    final Object? extra = GoRouterState.of(context).extra;

    return Drawer(
      width: screenWidth < 600 ? screenWidth * 0.8 : 400,
      backgroundColor: const Color(0xFFFDF5EC), // Pale peach / cream
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          CustomDrawerHeader(
            onClose: () => Navigator.of(context).pop(), // Close drawer
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: [
                DrawerItem(
                  title: 'Home',
                  leadingIcon: Icons.home,
                  isSelected:
                      (currentRoute == Routes.homeScreen ||
                          currentRoute == '/') &&
                      extra == null,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != Routes.homeScreen) {
                      context.go(Routes.homeScreen);
                    }
                  },
                ),
                const SizedBox(height: 8),

                // Dynamic Categories
                StreamBuilder<List<CategoryModel>>(
                  stream: FirebaseService().getCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final categories = snapshot.data ?? [];

                    return Column(
                      children: categories.map((category) {
                        return Column(
                          children: [
                            DrawerItem(
                              title: category.name,
                              imageUrl: category.imageUrl, // Use image from DB
                              isSelected:
                                  extra ==
                                  category
                                      .name, // Category screen takes category name as extra
                              onTap: () {
                                Navigator.of(context).pop();
                                context.push(
                                  Routes.categoryScreen,
                                  extra: category.name,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),

                DrawerItem(
                  title: 'Wishlist',
                  leadingIcon: Icons.favorite_border,
                  isSelected: currentRoute == Routes.wishlistScreen,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (currentRoute != Routes.wishlistScreen) {
                      context.push(Routes.wishlistScreen);
                    }
                  },
                ),

                // Bottom decorative swirl can be added later or as a background image,
                // but the current implementation covers the list perfectly.
              ],
            ),
          ),
        ],
      ),
    );
  }
}
