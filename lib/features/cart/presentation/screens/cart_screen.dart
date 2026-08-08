import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/core/utils/easy_loading.dart';
import 'package:shop/core/widgets/app_form_field.dart';
import 'package:shop/core/widgets/governorate_dropdown.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/utils/cart_state.dart';
import 'package:shop/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shop/features/cart/data/models/order_model.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';

const _maroon = Color(0xFF5C2428);
const _cream = Color(0xFFF7DEB1);
const _bg = Color(0xFFF6F7FA);
const _cardBg = Colors.white;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  int quantity = 2;
  bool _showCheckoutForm = false;
  String? _selectedGovernorate;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _formAnimCtrl;
  late Animation<double> _formAnim;

  double get unitPrice => 500.0;
  double get totalPrice => unitPrice * quantity;

  @override
  void initState() {
    super.initState();
    _formAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _formAnim = CurvedAnimation(parent: _formAnimCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _scrollCtrl.dispose();
    _formAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCheckout() async {
    setState(() => _showCheckoutForm = true);
    _formAnimCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get cart items and calculate total
    final cartItems = CartState.cartItemsNotifier.value;
    double subTotal = 0;
    int totalItems = 0;
    String productsDetails = '';

    List<OrderItemModel> orderItems = [];

    for (var item in cartItems) {
      subTotal += item.totalPrice;
      totalItems += item.quantity;
      orderItems.add(
        OrderItemModel(
          productId: item.product.id ?? '',
          productName: item.product.name,
          quantity: item.quantity,
          price: item.product.price,
          totalPrice: item.totalPrice,
        ),
      );

      productsDetails += '▪ ${item.product.name}\n';
      productsDetails +=
          '  العدد: ${item.quantity}  |  السعر: ${item.totalPrice.toStringAsFixed(2)} ج.م\n';
      if (item != cartItems.last) {
        productsDetails += '  ---------------------------\n';
      }
    }

    double shippingFee = 50.0;
    double totalAmount = subTotal + shippingFee;

    // Format date and time manually to avoid intl dependency issues
    final now = DateTime.now();
    final String formattedDate =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
    final String amPm = now.hour >= 12 ? 'م' : 'ص';
    int hour12 = now.hour % 12;
    if (hour12 == 0) hour12 = 12;
    final String formattedTime =
        '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $amPm';

    // Format WhatsApp message
    final String message =
        '''
=========================
       *طلب جديد*
=========================

*[+]* تفاصيل الطلب:
-------------------------
التاريخ : $formattedDate
الوقت   : $formattedTime

*[+]* بيانات العميل:
-------------------------
الاسم     : ${_nameCtrl.text}
رقم الهاتف: ${_phoneCtrl.text}
المحافظة  : ${_selectedGovernorate ?? 'غير محدد'}
العنوان   : ${_addressCtrl.text}

*[+]* المنتجات المطلوبة:
-------------------------
$productsDetails
-------------------------
المجموع الفرعي : ${subTotal.toStringAsFixed(2)} ج.م
مصاريف الشحن : ${shippingFee.toStringAsFixed(2)} ج.م
=========================
*الإجمالي الكلي: ${totalAmount.toStringAsFixed(2)} ج.م*
=========================

_شكراً لاختياركم متجرنا._
''';

    final String phone = '201005797956';
    final Uri url = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    // Save order to Firebase
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final order = OrderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: _nameCtrl.text,
        phone: _phoneCtrl.text,
        governorate: _selectedGovernorate ?? 'غير محدد',
        address: _addressCtrl.text,
        items: orderItems,
        totalAmount: totalAmount,
        createdAt: now,
      );

      await FirebaseService().createOrder(order);

      if (mounted) Navigator.pop(context); // close loading

      // Clear the cart on success
      CartState.clear();
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showError('حدث خطأ أثناء الحفظ: $e');
      }
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);

      if (mounted) {
        showSuccess('تم إرسال طلبك بنجاح!');
      }
    } else {
      if (mounted) {
        showError('تعذر فتح واتساب، يرجى التأكد من تثبيت التطبيق');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ValueListenableBuilder(
            valueListenable: CartState.cartItemsNotifier,
            builder: (context, cartItems, child) {
              final double subTotal = cartItems.fold(
                0,
                (sum, item) => sum + item.totalPrice,
              );
              final int totalItems = cartItems.fold(
                0,
                (sum, item) => sum + item.quantity,
              );
              final double shippingFee = 50.0;
              final double totalAmount = subTotal + shippingFee;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: cartItems.isEmpty
                            ? _buildEmptyState(context)
                            : SingleChildScrollView(
                                controller: _scrollCtrl,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  20,
                                  16,
                                  0,
                                ),
                                child: Column(
                                  children: [
                                    // Build list of CartItemCards
                                    Column(
                                      children: cartItems
                                          .map(
                                            (item) =>
                                                CartItemCard(cartItem: item),
                                          )
                                          .toList(),
                                    ),

                                    if (_showCheckoutForm) ...[
                                      const SizedBox(height: 20),
                                      FadeTransition(
                                        opacity: _formAnim,
                                        child: SizeTransition(
                                          sizeFactor: _formAnim,
                                          child: _buildCheckoutForm(),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                      ),
                      if (cartItems.isNotEmpty)
                        _buildBottomBar(
                          context,
                          subTotal,
                          shippingFee,
                          totalAmount,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.black54,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: AppText(
                'سلة التسوق',
                style: font20w700.copyWith(color: Colors.black87),
                alignment: AlignmentDirectional.center,
              ),
            ),
          ),
          // Badge
          ValueListenableBuilder<int>(
            valueListenable: CartState.cartCountNotifier,
            builder: (context, count, child) => count > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _maroon,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText(
                      '$count',
                      style: font12w700.copyWith(color: Colors.white),
                      alignment: AlignmentDirectional.center,
                    ),
                  )
                : const SizedBox(width: 38),
          ),
        ],
      ),
    );
  }

  // ─── Checkout Form ────────────────────────────────────────────────────────

  // ─── Checkout Form ────────────────────────────────────────────────────────
  Widget _buildCheckoutForm() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF9F3E5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppText(
                  'بيانات التوصيل',
                  style: font16w700.copyWith(color: _maroon),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.local_shipping_outlined,
                  color: _maroon,
                  size: 20,
                ),
              ],
            ),
          ),
          // Fields
          Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AppText(
                    'يرجى ادخال معلوماتك لإكمال الطلب',
                    style: font14w500.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  AppFormField(
                    controller: _nameCtrl,
                    hintText: 'اسمك بالكامل',
                    suffixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'يرجى إدخال الاسم'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppFormField(
                    controller: _phoneCtrl,
                    hintText: 'رقم الهاتف',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Colors.grey,
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'يرجى إدخال رقم الهاتف'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  GovernorateDropdown(
                    hintText: 'المحافظة',
                    onChanged: (val) {
                      setState(() {
                        _selectedGovernorate = val;
                      });
                    },
                    validator: (val) => val == null || val.isEmpty
                        ? 'يرجى اختيار المحافظة'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppFormField(
                    controller: _addressCtrl,
                    hintText: 'العنوان بالتفصيل',
                    maxLines: 3,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'يرجى إدخال العنوان'
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────
  Widget _buildBottomBar(
    BuildContext context,
    double subTotal,
    double shippingFee,
    double totalAmount,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'المجموع',
                  style: font14w500.copyWith(color: Colors.grey[600]),
                ),
                AppText(
                  '${subTotal.toStringAsFixed(2)} ج.م',
                  style: font14w700.copyWith(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'مصاريف الشحن',
                  style: font14w500.copyWith(color: Colors.grey[600]),
                ),
                AppText(
                  '${shippingFee.toStringAsFixed(2)} ج.م',
                  style: font14w700.copyWith(color: Colors.black87),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'الاجمالي الكلي',
                  style: font16w600.copyWith(color: Colors.grey[800]),
                ),
                AppText(
                  '${totalAmount.toStringAsFixed(2)} ج.م',
                  style: font22w700.copyWith(color: _maroon),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // CTA Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _showCheckoutForm ? _onSubmit : _onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showCheckoutForm
                      ? _maroon
                      : Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showCheckoutForm
                          ? Icons.check_circle_outline
                          : Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      _showCheckoutForm ? 'تأكيد وإرسال الطلب' : 'إتمام الطلب',
                      style: font18w700.copyWith(color: Colors.white),
                      alignment: AlignmentDirectional.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.pop(),
              child: AppText(
                'أو متابعة التسوق ←',
                style: font14w700.copyWith(color: Colors.blue[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: _cream,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: _maroon,
              ),
            ),
            const SizedBox(height: 28),
            AppText(
              'سلتك فارغة!',
              style: font24w700.copyWith(color: Colors.black87),
              alignment: AlignmentDirectional.center,
            ),
            const SizedBox(height: 10),
            AppText(
              'أضف منتجات لسلتك وابدأ تجربة تسوق رائعة',
              style: font14w400.copyWith(color: Colors.grey[500], height: 1.7),
              textAlign: TextAlign.center,
              alignment: AlignmentDirectional.center,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _maroon,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: AppText(
                  'تسوق الآن',
                  style: font16w700.copyWith(color: Colors.white),
                  alignment: AlignmentDirectional.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
