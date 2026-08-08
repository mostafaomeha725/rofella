import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/core/widgets/app_form_field.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/widgets/app_image.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../data/models/category_model.dart';
import '../../data/services/cloudinary_service.dart';
import '../../data/services/firebase_service.dart';

class AdminAddCategoryScreen extends StatefulWidget {
  final CategoryModel? categoryToEdit;

  const AdminAddCategoryScreen({super.key, this.categoryToEdit});

  @override
  State<AdminAddCategoryScreen> createState() => _AdminAddCategoryScreenState();
}

class _AdminAddCategoryScreenState extends State<AdminAddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  XFile? _selectedImage;
  String? _existingImageUrl; // For when editing and no new image is selected

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name;
      _existingImageUrl = widget.categoryToEdit!.imageUrl;
    }
  }

  final ImagePicker _picker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _submitCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final isEditing = widget.categoryToEdit != null;

    if (_selectedImage == null && !isEditing) {
      EasyLoading.showError('الرجاء اختيار صورة للتصنيف');
      return;
    }

    FocusScope.of(context).unfocus();
    EasyLoading.show(
      status: isEditing ? 'جاري تحديث التصنيف...' : 'جاري رفع التصنيف...',
    );

    try {
      String? imageUrl = _existingImageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        final url = await CloudinaryService.uploadImage(_selectedImage!);
        if (url == null) {
          EasyLoading.dismiss();
          if (mounted) {
            EasyLoading.showError('فشل في رفع الصورة، يرجى التحقق من الإعدادات');
          }
          return;
        }
        imageUrl = url;
      }

      final category = CategoryModel(
        id: isEditing ? widget.categoryToEdit!.id : '', // Maintain existing ID
        name: _nameController.text.trim(),
        imageUrl: imageUrl ?? '',
        createdAt: isEditing
            ? widget.categoryToEdit!.createdAt
            : DateTime.now(),
      );

      final errorMessage = isEditing
          ? await _firebaseService.updateCategory(category)
          : await _firebaseService.addCategory(category);

      EasyLoading.dismiss();
      if (!mounted) return;
      if (errorMessage == null) {
        EasyLoading.showSuccess(isEditing ? 'تم تحديث التصنيف بنجاح!' : 'تم إضافة التصنيف بنجاح!');
        if (isEditing) {
          Navigator.pop(context); // Go back after editing
        } else {
          _clearForm();
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
    _formKey.currentState?.reset();
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: AppText(
          widget.categoryToEdit != null ? 'تحديث التصنيف' : 'إضافة تصنيف',
          style: font18w700.copyWith(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('بيانات التصنيف'),
                    const SizedBox(height: 16),
                    AppFormField(
                      controller: _nameController,
                      hintText: 'اسم التصنيف',
                      autovalidateMode: AutovalidateMode.disabled,
                      prefixIcon: const Icon(
                        Icons.category_outlined,
                        color: Colors.grey,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'يرجى إدخال اسم التصنيف';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
                    _buildSectionTitle('صورة التصنيف'),
                    const SizedBox(height: 16),
                    _buildImagePicker(),

                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submitCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E3192),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: const Color(
                            0xFF2E3192,
                          ).withValues(alpha: 0.4),
                        ),
                        child: AppText(
                          widget.categoryToEdit != null
                              ? 'تحديث التصنيف'
                              : 'إضافة التصنيف',
                          style: font18w700.copyWith(color: Colors.white),
                          alignment: AlignmentDirectional.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return AppText(title, style: font16w700.copyWith(color: Colors.black87));
  }

  Widget _buildImagePicker() {
    return _selectedImage == null && _existingImageUrl == null
        ? GestureDetector(
            onTap: _pickImage,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(height: 12),
                    AppText(
                      'اختر صورة التصنيف',
                      style: font14w500.copyWith(color: Colors.grey[600]),
                      alignment: AlignmentDirectional.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        : _buildSelectedImage();
  }

  Widget _buildSelectedImage() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _selectedImage != null
                  ? (kIsWeb
                        ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                        : Image.file(
                            File(_selectedImage!.path),
                            fit: BoxFit.cover,
                          ))
                  : AppImage(imageUrl: _existingImageUrl!, fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _removeImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
