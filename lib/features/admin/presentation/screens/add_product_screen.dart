import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/core/widgets/app_form_field.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/cloudinary_service.dart';
import '../../data/services/firebase_service.dart';

class AdminAddProductScreen extends StatefulWidget {
  final ProductModel? productToEdit;
  const AdminAddProductScreen({super.key, this.productToEdit});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  final List<XFile> _selectedImages = [];
  List<String> _existingImages = [];
  final ImagePicker _picker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!.name;
      _descController.text = widget.productToEdit!.description;
      _priceController.text = widget.productToEdit!.price.toString();
      _categoryController.text = widget.productToEdit!.category;
      _existingImages = List.from(widget.productToEdit!.images);
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty && _existingImages.isEmpty) {
      EasyLoading.showError('الرجاء اختيار صورة واحدة على الأقل للمنتج');
      return;
    }

    FocusScope.of(context).unfocus();
    EasyLoading.show(
      status: widget.productToEdit != null
          ? 'جاري تحديث المنتج...'
          : 'جاري رفع الصور والمنتج...',
    );

    try {
      List<String> imageUrls = List.from(_existingImages);
      for (var image in _selectedImages) {
        final url = await CloudinaryService.uploadImage(image);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      if (imageUrls.isEmpty) {
        EasyLoading.dismiss();
        if (mounted) {
          EasyLoading.showError('فشل في رفع الصور، يرجى التحقق من الإعدادات');
        }
        return;
      }

      final isEditing = widget.productToEdit != null;
      final product = ProductModel(
        id: isEditing ? widget.productToEdit!.id : null,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        category: _categoryController.text.trim(),
        images: imageUrls,
        createdAt: isEditing ? widget.productToEdit!.createdAt : DateTime.now(),
      );

      final errorMessage = isEditing
          ? await _firebaseService.updateProduct(product)
          : await _firebaseService.addProduct(product);

      EasyLoading.dismiss();
      if (!mounted) return;
      if (errorMessage == null) {
        EasyLoading.showSuccess(
          isEditing ? 'تم تحديث المنتج بنجاح!' : 'تم إضافة المنتج بنجاح!',
        );
        if (!isEditing) {
          _clearForm();
        } else {
          Navigator.pop(context); // Go back after editing
        }
      } else {
        EasyLoading.showError('خطأ Firebase: $errorMessage');
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) {
        EasyLoading.showError('حدث خطأ غير متوقع: $e');
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _categoryController.clear();
    setState(() {
      _selectedImages.clear();
    });
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('اختر التصنيف', style: font16w700),
              ),
              const Divider(height: 1),
              StreamBuilder<List<CategoryModel>>(
                stream: _firebaseService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final categories = snapshot.data ?? [];

                  if (categories.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'لا توجد تصنيفات، يرجى إضافة تصنيف أولاً من الداشبورد',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index].name;
                        return ListTile(
                          title: Text(cat, style: font14w500),
                          trailing: _categoryController.text == cat
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            setState(() {
                              _categoryController.text = cat;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: AppText(
          isEditing ? 'تعديل المنتج' : 'إضافة منتج جديد',
          style: font18w700,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Images Section
            AppText(
              'صور المنتج',
              style: font16w700.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            if (_existingImages.isNotEmpty || _selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._existingImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final url = entry.value;
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(url),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _existingImages.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    ..._selectedImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: kIsWeb
                                    ? NetworkImage(file.path) as ImageProvider
                                    : FileImage(File(file.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('اختيار صور للمنتج'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[700],
                elevation: 0,
                side: BorderSide(color: Colors.blue[700]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 24),

            // Product Details Section
            AppText(
              'تفاصيل المنتج',
              style: font16w700.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 16),

            AppFormField(
              controller: _nameController,
              hintText: 'اسم المنتج',
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            AppFormField(
              controller: _priceController,
              hintText: 'السعر (مثال: 150.5)',
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            AppFormField(
              controller: _categoryController,
              hintText: 'التصنيف',
              readOnly: true,
              onTap: _showCategoryPicker,
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 16),

            AppFormField(
              controller: _descController,
              hintText: 'وصف المنتج',
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submitProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: AppText(
                  isEditing ? 'حفظ التعديلات' : 'حفظ ونشر المنتج',
                  style: font16w700.copyWith(color: Colors.white),
                  alignment: AlignmentDirectional.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
