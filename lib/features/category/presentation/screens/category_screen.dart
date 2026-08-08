import 'package:flutter/material.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/utils/spacing.dart';
import 'package:shop/core/widgets/app_drawer.dart';
import 'package:shop/core/widgets/footer_section.dart';
import 'package:shop/core/widgets/home_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/widgets/whatsapp_floating_button.dart';
import 'package:shop/features/home/presentation/screens/widgets/firebase_category_section.dart';


class CategoryScreen extends StatefulWidget {
  final String categoryName;

  const CategoryScreen({super.key, required this.categoryName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: 36,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFF7DEB1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.category_outlined,
              size: 60,
              color: Color(0xFF5C2428),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'لا توجد منتجات!',
            style: font24w700.copyWith(
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'عفواً، لا توجد منتجات في هذا التصنيف حالياً.',
            style: font14w400.copyWith(
              color: Colors.grey[500],
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF5C2428,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                'العودة للرئيسية',
                style: font16w700.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: HomeAppBar(categoryName: widget.categoryName),
      floatingActionButton: const WhatsappFloatingButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      verticalSpacing(16),

                      Text(
                        widget.categoryName,
                        style: font24w800.copyWith(color: Colors.black),
                      ),

                      verticalSpacing(32),

                      FirebaseCategorySection(
                        categoryTitle: widget.categoryName,
                        showTitle: false,
                        emptyStateWidget: _buildEmptyState(),
                      ),

                      verticalSpacing(48),
                    ],
                  ),
                ),
              ),
            ),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}
