import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/routes/route_paths.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/features/admin/data/models/category_model.dart';
import 'package:shop/core/utils/easy_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/features/admin/presentation/manager/admin_cubit.dart';

import 'package:shop/core/di/services_locator.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';

class AdminCategoriesListScreen extends StatelessWidget {
  const AdminCategoriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = sl<FirebaseService>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: AppText(
          'جميع التصنيفات',
          style: font18w700.copyWith(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<AdminCubit, AdminState>(
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

            List<CategoryModel> categories = [];
            if (state is AdminCategoriesLoaded) {
              categories = state.categories;
            } else if (state is AdminDashboardLoaded) {
              categories = state.categories;
            }

            if (categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    AppText(
                      'لا توجد تصنيفات حالياً',
                      style: font16w700.copyWith(color: Colors.grey),
                      alignment: AlignmentDirectional.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(category.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: AppText(
                      category.name,
                      style: font16w700.copyWith(color: Colors.black87),
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
                              Routes.adminAddCategoryScreen,
                              extra: category,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: Text(
                                  'هل أنت متأكد من حذف تصنيف "${category.name}"؟',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('إلغاء'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      final error = await firebaseService
                                          .deleteCategory(category.id);
                                      if (error != null && context.mounted) {
                                        showError('خطأ في الحذف: $error');
                                      }
                                    },
                                    child: const Text(
                                      'حذف',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addCategoryBtn',
        onPressed: () {
          context.push(Routes.adminAddCategoryScreen);
        },
        backgroundColor: const Color(0xFF1BFFFF).withValues(alpha: 0.9),
        icon: const Icon(Icons.category_outlined, color: Colors.black87),
        label: AppText(
          'إضافة تصنيف',
          style: font14w500.copyWith(color: Colors.black87),
        ),
      ),
    );
  }
}
