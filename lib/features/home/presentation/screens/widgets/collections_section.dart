import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/routes/route_paths.dart';
import 'package:shop/features/admin/data/models/category_model.dart';

import 'package:shop/core/widgets/section_title.dart';
import 'package:shop/core/widgets/collection_card.dart';

class CollectionsSection extends StatelessWidget {
  final List<CategoryModel> categories;

  const CollectionsSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(title: 'Collections'),
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 48.0,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF7DEB1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.category_outlined,
                      size: 50,
                      color: Color(0xFF5C2428),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'لا توجد تصنيفات!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قم بإضافة تصنيفات من لوحة التحكم لتظهر هنا.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                double childAspectRatio;
                if (constraints.maxWidth > 1024) {
                  crossAxisCount = 4;
                  childAspectRatio = 0.85;
                } else if (constraints.maxWidth > 768) {
                  crossAxisCount = 3;
                  childAspectRatio = 0.80;
                } else {
                  crossAxisCount = 2; // Force 2 items per row on mobile
                  childAspectRatio = 0.75;
                }

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  cacheExtent: 0,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  addSemanticIndexes: false,
                  itemCount: categories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 12.0, // Reduced spacing
                    mainAxisSpacing: 16.0,
                  ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return CollectionCard(
                  imageUrl: category.imageUrl,
                  overlayText: category.name.toUpperCase(),
                  subtitle: category.name,
                  onTap: () => context.push(
                    Routes.categoryScreen,
                    extra: category.name,
                  ),
                );
              },
            );
          },
        ),
      ),
      ],
    );
  }
}
