import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shop/core/routes/route_paths.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/widgets/app_image.dart';
import 'package:shop/core/widgets/custom_text.dart';

import 'package:shop/features/admin/data/models/product_model.dart';

import 'add_to_cart_button.dart';
import 'favorite_button.dart';
import 'price_widget.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  static const double _radius = 20;
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => context.push(Routes.productDetailsScreen, extra: widget.product),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: const Color(0xFFF1F1F1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    key: _imageKey,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(_radius),
                    ),
                    child: AppImage(
                      imageUrl: widget.product.images.isNotEmpty
                          ? widget.product.images.first
                          : 'https://via.placeholder.com/300',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: FavoriteButton(product: widget.product),
                  ),
                ],
              ),
            ),

            /// Content
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppText(
                    widget.product.name,
                    alignment: AlignmentDirectional.center,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: font14w700.copyWith(color: const Color(0xFF5C2428)),
                  ),
                  const SizedBox(height: 8),
                  PriceWidget(
                    currentPrice: 'EGP ${widget.product.price.toInt()}',
                    oldPrice: widget.product.oldPrice != null 
                        ? 'EGP ${widget.product.oldPrice!.toInt()}'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  AddToCartButton(product: widget.product, imageKey: _imageKey),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
