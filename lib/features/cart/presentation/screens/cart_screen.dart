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

import 'package:shop/features/cart/data/models/order_model.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';
import 'package:shop/core/utils/url_launcher_util.dart';
import 'package:shop/features/cart/domain/services/shipping_calculator.dart';

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
    String productsDetails = '';

    List<OrderItemModel> orderItems = [];

    for (var item in cartItems) {
      subTotal += item.totalPrice;
      orderItems.add(
        OrderItemModel(
          productId: item.product.id ?? '',
          productName: item.product.name,
          quantity: item.quantity,
          price: item.product.price,
          totalPrice: item.totalPrice,
        ),
      );

      productsDetails += '\u200F- ${item.product.name} × ${item.quantity} — ${item.totalPrice.toInt().toString()} EGP\n';
    }

    double shippingFee =
        ShippingCalculator.calculateShippingFee(_selectedGovernorate) ??
        ShippingCalculator.defaultFee;
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

    // Format WhatsApp message with Right-To-Left Mark (RLM)
    final String rlm = '\u200F';
    final String message =
        '''
$rlm🛒 *طلب جديد*

$rlm📅 التاريخ: $formattedDate
$rlm🕐 الوقت: $formattedTime

$rlm👤 *بيانات العميل*
$rlm- الاسم: ${_nameCtrl.text}
$rlm- الهاتف: ${_phoneCtrl.text}
$rlm- المحافظة: ${_selectedGovernorate ?? 'غير محدد'}
$rlm- العنوان: ${_addressCtrl.text}

$rlm📦 *المنتجات المطلوبة*
$productsDetails
$rlm💰 *الحساب*
$rlmالمجموع الفرعي: ${subTotal.toInt().toString()} EGP
$rlmمصاريف الشحن: ${shippingFee.toInt().toString()} EGP
$rlm*الإجمالي الكلي: ${totalAmount.toInt().toString()} EGP*
''';

    debugPrint('--- Final WhatsApp Message (Before URI Encoding) ---');
    debugPrint(message);
    debugPrint('----------------------------------------------------');

    final String phone = '201005797956';

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

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF25D366),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'تم الطلب بنجاح!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'تم تسجيل طلبك لدينا بنجاح.\nبرجاء تأكيد الطلب عبر واتساب لضمان سرعة التوصيل.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      UrlLauncherUtil.launchWhatsApp(
                        phone: phone,
                        message: message,
                      ).catchError((_) {});
                      Navigator.pop(ctx);
                      context.go('/home');
                    },
                    icon: const Icon(Icons.chat, color: Colors.white, size: 24),
                    label: const Text(
                      'تأكيد الطلب الآن',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
              final double? shippingFee =
                  ShippingCalculator.calculateShippingFee(_selectedGovernorate);
              final double totalAmount = subTotal + (shippingFee ?? 0.0);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final bool isDesktop = constraints.maxWidth > 900;
                  
                  if (isDesktop) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          children: [
                            _buildHeader(context),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left side (Cart Items)
                                  Expanded(
                                    flex: 3,
                                    child: cartItems.isEmpty
                                        ? _buildEmptyState(context)
                                        : SingleChildScrollView(
                                            controller: _scrollCtrl,
                                            padding: const EdgeInsets.all(24),
                                            child: Column(
                                              children: cartItems
                                                  .map((item) =>
                                                      CartItemCard(cartItem: item))
                                                  .toList(),
                                            ),
                                          ),
                                  ),
                                  // Right side (Checkout Summary and Form)
                                  if (cartItems.isNotEmpty)
                                    Container(
                                      width: 400,
                                      padding: const EdgeInsets.only(
                                          top: 24, bottom: 24, left: 24),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            _buildBottomBar(
                                              context,
                                              subTotal,
                                              shippingFee,
                                              totalAmount,
                                              isDesktop: true,
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
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Mobile / Tablet layout
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'تكلفة الشحن تُحسب تلقائيًا حسب المحافظة.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
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
    double? shippingFee,
    double totalAmount, {
    bool isDesktop = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isDesktop
            ? BorderRadius.circular(20)
            : const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: isDesktop ? const Offset(0, 5) : const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...[
              Text(
                'ملخص الطلب',
                style: font18w700.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المجموع',
                  style: font14w500.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  '${subTotal.toInt().toString()} EGP',
                  style: font14w700.copyWith(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مصاريف الشحن',
                  style: font14w500.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    shippingFee != null
                        ? '${shippingFee.toInt().toString()} EGP'
                        : 'اختر المحافظة لمعرفة الشحن',
                    textAlign: TextAlign.end,
                    style: font14w700.copyWith(
                      color: shippingFee != null ? Colors.black87 : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  'الاجمالي الكلي',
                  style: font16w600.copyWith(color: Colors.grey[800]),
                ),
                AppText(
                  '${totalAmount.toInt().toString()} EGP',
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
