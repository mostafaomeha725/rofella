import 'package:flutter/material.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/widgets/home_app_bar.dart';
import 'package:shop/core/widgets/governorate_dropdown.dart';
import 'package:shop/core/widgets/app_form_field.dart';
import '../widgets/cart_item_card.dart';
import 'package:shop/core/utils/cart_state.dart';
import 'package:shop/features/cart/data/models/cart_item_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const HomeSliverAppBar(),
          ];
        },
        body: ValueListenableBuilder<List<CartItemModel>>(
          valueListenable: CartState.cartItemsNotifier,
          builder: (context, cartItems, child) {
            final double totalAmount = cartItems.fold(
              0, (sum, item) => sum + item.totalPrice);
            
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Title
                AppText(
                  'ملخص الطلب',
                  style: font18w700.copyWith(color: Colors.black87),
                ),
                const SizedBox(height: 16),

                // Cart Items List
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: cartItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CartItemCard(cartItem: item),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Subtotals
                _buildCostRow('اجمالي المنتجات', '${totalAmount.toInt().toString()} EGP'),
                const SizedBox(height: 16),
                _buildCostRow('تكلفة الشحن', 'يرجى اختيار المدينة', isHighlight: true),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEEEEE), thickness: 1),
            const SizedBox(height: 16),

            // Coupon
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText(
                  'هل لديك كوبون خصم؟',
                  style: font14w400.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppFormField(
                    controller: _couponController,
                    hintText: '',
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: AppText(
                    'أدخل الكوبون',
                    style: font14w700.copyWith(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFEEEEEE), thickness: 1),
            const SizedBox(height: 16),

            // Total
            _buildCostRow('الاجمالي', '1000 EGP', isBold: true),
            const SizedBox(height: 32),

            // User Information Form
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: AppText(
                      'يرجى ادخال معلوماتك لإكمال الطلب',
                      style: font16w600.copyWith(color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppFormField(
                    controller: _nameController,
                    hintText: 'اسمك بالكامل',
                    suffixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  AppFormField(
                    controller: _phoneController,
                    hintText: 'رقم الهاتف',
                    keyboardType: TextInputType.phone,
                    suffixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const GovernorateDropdown(
                    hintText: 'المحافظة',
                  ),
                  const SizedBox(height: 16),
                  AppFormField(
                    controller: _addressController,
                    hintText: 'العنوان بالتفصيل',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    },
  ),
  ),
  bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // Submit order logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: AppText(
                'إتمام الطلب',
                style: font18w700.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(String title, String value, {bool isHighlight = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          value,
          style: (isBold ? font16w700 : font14w700).copyWith(
            color: isHighlight ? Colors.black : Colors.black87,
          ),
        ),
        AppText(
          title,
          style: (isBold ? font16w700 : font14w400).copyWith(
            color: isBold ? Colors.black87 : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
