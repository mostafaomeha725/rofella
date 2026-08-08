import 'package:flutter/material.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/utils/wishlist_state.dart';
import 'package:shop/core/widgets/product_card.dart';
import 'package:shop/features/admin/data/models/product_model.dart';
import 'package:shop/core/widgets/home_app_bar.dart';
import 'package:shop/core/widgets/app_drawer.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeAppBar(),
      drawer: const AppDrawer(),
      body: ValueListenableBuilder<List<ProductModel>>(
        valueListenable: WishlistState.wishlistItemsNotifier,
        builder: (context, wishlist, child) {
          if (wishlist.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'المفضلة فارغة!',
                    style: font24w800.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'أضف بعض المنتجات إلى المفضلة لتجدها هنا',
                    style: font14w400.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المفضلة (${wishlist.length})',
                  style: font24w800.copyWith(color: Colors.black87),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 800
                        ? 4
                        : constraints.maxWidth > 500
                        ? 3
                        : 2;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: wishlist.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        return ProductCard(product: wishlist[index]);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
