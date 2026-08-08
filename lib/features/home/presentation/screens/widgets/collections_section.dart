import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/routes/route_paths.dart';
import 'package:shop/features/admin/data/models/category_model.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';

import 'package:shop/core/widgets/section_title.dart';
import 'package:shop/core/widgets/collection_card.dart';

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(title: 'Collections'),
        StreamBuilder<List<CategoryModel>>(
          stream: FirebaseService().getCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final categories = snapshot.data ?? [];

            if (categories.isEmpty) {
              return Padding(
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
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.75, // Fixed aspect ratio
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
              ),
            );
          },
        ),
      ],
    );
  }
}
