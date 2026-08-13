import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop/core/routes/route_paths.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/widgets/custom_text.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/firebase_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/features/admin/presentation/manager/admin_cubit.dart';
import 'package:shop/core/di/services_locator.dart';
import 'package:shop/core/utils/easy_loading.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _firebaseService = sl<FirebaseService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F6FA,
      ), // Light modern dashboard background
      appBar: AppBar(
        title: AppText(
          'لوحة التحكم',
          style: font18w700.copyWith(color: Colors.black87),
          alignment: AlignmentDirectional.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              // Sign out and go home
              context.go(Routes.homeScreen);
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading || state is AdminInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminError) {
            return Center(
              child: AppText(
                'حدث خطأ في جلب البيانات: ${state.message}',
                style: font16w700.copyWith(color: Colors.red),
              ),
            );
          }

          if (state is! AdminDashboardLoaded) {
            return const SizedBox.shrink();
          }

          final products = state.products;
          final categories = state.categories;
          final orderCount = state.ordersCount;
          final visitCount = state.totalVisits;
          final uniqueCount = state.uniqueDevices;

          return CustomScrollView(
            slivers: [
              // Dashboard Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'المنتجات',
                          count: products.length,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          onTap: null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'التصنيفات',
                          count: categories.length,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF7DEB1), Color(0xFFE5B05C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          textColor: Colors.black87,
                          onTap: () {
                            context.push(Routes.adminCategoriesListScreen);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Orders and Visits Stat Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'الطلبات',
                          count: orderCount,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5C2428), Color(0xFFD65E68)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          textColor: Colors.white,
                          onTap: () {
                            context.push(Routes.adminOrdersScreen);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'الزيارات',
                          count: visitCount,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4CA1AF),
                              Color(0xFFC4E0E5),
                            ], // Modern blue gradient
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          textColor: Colors.black87,
                          onTap: null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Unique Visits Stat Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'الزوار الفريدين',
                          count: uniqueCount,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF8E2DE2),
                              Color(0xFF4A00E0),
                            ], // Purple gradient
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          textColor: Colors.white,
                          onTap: null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: AppText(
                    'أحدث المنتجات',
                    style: font18w700.copyWith(color: Colors.black87),
                  ),
                ),
              ),

              // Products List
              if (products.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          AppText(
                            'لا توجد منتجات حالياً',
                            style: font16w700.copyWith(color: Colors.grey),
                            alignment: AlignmentDirectional.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = products[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                              image: product.images.isNotEmpty
                                  ? DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        product.images.first,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: product.images.isEmpty
                                ? const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          title: AppText(
                            product.name,
                            style: font16w700.copyWith(color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                children: [
                                AppText(
                                  '${product.price.toInt()} EGP',
                                  style: font14w500.copyWith(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                if (product.oldPrice != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '${product.oldPrice!.toInt()} EGP',
                                    style: font14w500.copyWith(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () {
                                  context.push(
                                    Routes.adminAddProductScreen,
                                    extra: product,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () =>
                                    _showDeleteDialog(context, product),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: products.length),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addProductBtn',
        onPressed: () {
          context.push(Routes.adminAddProductScreen);
        },
        backgroundColor: const Color(0xFF2E3192),
        icon: const Icon(Icons.add, color: Colors.white),
        label: AppText(
          'إضافة منتج',
          style: font14w500.copyWith(color: Colors.white),
        ),
      ),
    );
  } // End of build method

  Widget _buildStatCard({
    required String title,
    required int count,
    required Gradient gradient,
    VoidCallback? onTap,
    Color textColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'إجمالي $title',
              style: font14w500.copyWith(
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              '$count',
              style: font24w700.copyWith(color: textColor, fontSize: 36),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف المنتج',
          style: font18w700.copyWith(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من رغبتك في حذف المنتج:\n"${product.name}"\nنهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
              style: font14w500.copyWith(color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: font14w700.copyWith(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await _firebaseService.deleteProduct(product.id!);
              if (!context.mounted) return;
              if (error == null) {
                showSuccess('تم حذف المنتج بنجاح');
              } else {
                showError('حدث خطأ أثناء الحذف: $error');
              }
            },
            child: Text(
              'تأكيد الحذف',
              style: font14w700.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
