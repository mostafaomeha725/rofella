import 'package:flutter/material.dart';

import 'package:shop/core/widgets/home_app_bar.dart';
import 'package:shop/core/widgets/app_drawer.dart';
import 'package:shop/core/widgets/footer_section.dart';

import 'widgets/product_image_carousel.dart';
import 'widgets/product_info_section.dart';
import 'widgets/product_description_section.dart';
import 'widgets/add_to_cart_bottom_bar.dart';
import 'package:shop/features/admin/data/models/product_model.dart';

import 'package:shop/core/widgets/favorite_button.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // If no images provided, use a placeholder
    final List<String> images = product.images.isNotEmpty
        ? product.images
        : ['https://via.placeholder.com/400'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HomeAppBar(),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Stack(
              children: [
                ProductImageCarousel(imageUrls: images),
                Positioned(
                  right: 16,
                  top: 16,
                  child: FavoriteButton(product: product),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
            ProductInfoSection(
              subtitle: product.category,
              title: product.name,
              price: 'LE ${product.price.toStringAsFixed(2)}',
            ),
            ProductDescriptionSection(description: product.description),
            const SizedBox(height: 16),
            const FooterSection(),
          ],
        ),
      ),
      bottomNavigationBar: AddToCartBottomBar(product: product),
    );
  }
}
