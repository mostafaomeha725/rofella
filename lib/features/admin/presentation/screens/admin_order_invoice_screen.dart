import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gal/gal.dart';
import 'package:shop/core/utils/download_helper.dart' as web_downloader;
import 'package:url_launcher/url_launcher.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/features/cart/data/models/order_model.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';

class AdminOrderInvoiceScreen extends StatefulWidget {
  final OrderModel order;
  const AdminOrderInvoiceScreen({super.key, required this.order});

  @override
  State<AdminOrderInvoiceScreen> createState() =>
      _AdminOrderInvoiceScreenState();
}

class _AdminOrderInvoiceScreenState extends State<AdminOrderInvoiceScreen> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSaving = false;
  bool _isUpdating = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
  }

  final Color _primaryDark = const Color(0xFF0F3E45);
  final Color _borderColor = const Color(0xFFE5E7EB);
  final Color _lightGray = const Color(0xFFF9FAFB);

  Future<void> _captureAndSaveInvoice() async {
    try {
      setState(() {
        _isSaving = true;
      });

      // Wait a frame for UI to settle
      await Future.delayed(const Duration(milliseconds: 100));

      final RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        await web_downloader.downloadImage(pngBytes, 'invoice_${widget.order.id}.png');
      } else {
        await Gal.putImageBytes(pngBytes, name: 'invoice_${widget.order.id}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الفاتورة في المعرض بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ الفاتورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _sendViaWhatsApp() async {
    String phone = widget.order.phone.trim();
    if (phone.startsWith('0')) {
      phone = '2$phone';
    } else if (!phone.startsWith('20') && !phone.startsWith('+')) {
      phone = '20$phone';
    }

    const String rlm = '\u200F';
    String message = 
        '$rlmمرحباً *${widget.order.customerName}*،\n\n'
        '$rlmمرفق لك تفاصيل فاتورة طلبك رقم #${widget.order.id.substring(0, 6)}.\n\n'
        '$rlmشكراً لتسوقك معنا! ✨';

    final Uri url = Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح واتساب، يرجى التأكد من تثبيت التطبيق.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    final String day = date.day.toString().padLeft(2, '0');
    final String month = months[date.month - 1];
    final String year = date.year.toString();
    return '$day $month $year';
  }

  String _formatTime(DateTime date) {
    final String hour = (date.hour % 12 == 0 ? 12 : date.hour % 12).toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    final String amPm = date.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: AppText('تفاصيل الفاتورة', style: font18w700.copyWith(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: _captureAndSaveInvoice,
              tooltip: 'حفظ الفاتورة كصورة',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              RepaintBoundary(
                key: _globalKey,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // Watermark
                          Positioned.fill(
                            child: Center(
                              child: Opacity(
                                opacity: 0.03,
                                child: Icon(
                                  Icons.shopping_bag_rounded,
                                  size: 300,
                                  color: _primaryDark,
                                ),
                              ),
                            ),
                          ),
                          // Content
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildInvoiceHeader(),
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTopSection(),
                                    const SizedBox(height: 32),
                                    _buildItemsTable(),
                                    const SizedBox(height: 32),
                                    _buildTotalsSection(),
                                  ],
                                ),
                              ),
                              _buildFooter(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildStatusUpdater(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sendViaWhatsApp,
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: const Text(
                    'إرسال الفاتورة عبر واتساب',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusUpdater() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            'تحديث حالة الطلب:',
            style: font14w700.copyWith(color: Colors.black87),
          ),
          const SizedBox(width: 16),
          if (_isUpdating)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text('قيد الانتظار'),
                      ),
                  DropdownMenuItem(
                    value: 'OnTheWay',
                    child: Text('في الطريق'),
                  ),
                  DropdownMenuItem(
                    value: 'Delivered',
                    child: Text('تم التسليم'),
                  ),
                ],
                onChanged: (newStatus) async {
                  if (newStatus != null && newStatus != _currentStatus) {
                    setState(() {
                      _isUpdating = true;
                    });
                    
                    await FirebaseService().updateOrderStatus(
                      widget.order.id,
                      newStatus,
                    );

                    // Send WhatsApp Notification logic
                    String message = '';
                    
                    if (newStatus == 'OnTheWay') {
                      message =
                          'مرحباً *${widget.order.customerName}*،\n\n'
                          'يسعدنا إخبارك أن طلبك أصبح الآن في الطريق إليك!\n\n'
                          'سيقوم المندوب بالتواصل معك قريباً لتسليم الطلب على عنوانك.\n\n'
                          'شكراً لثقتك في متجر Beauty & Skin';
                    } else if (newStatus == 'Delivered') {
                      message =
                          'مرحباً *${widget.order.customerName}*،\n\n'
                          'تم تسليم طلبك بنجاح!\n\n'
                          'نتمنى أن تنال منتجاتنا إعجابك وتكون تجربتك مميزة.\n\n'
                          'شكراً لاختيارك متجر Beauty & Skin';
                    }

                    if (message.isNotEmpty) {
                      String phone = widget.order.phone.trim();
                      if (phone.startsWith('0')) {
                        phone = '2$phone';
                      } else if (!phone.startsWith('20') &&
                          !phone.startsWith('+')) {
                        phone = '20$phone';
                      }

                      final Uri url = Uri.parse(
                        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }

                    if (mounted) {
                      setState(() {
                        _currentStatus = newStatus;
                        _isUpdating = false;
                      });
                    }
                  }
                },
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.black87, size: 20),
                  const SizedBox(width: 6),
                  Text('طلب جديد', style: font16w700.copyWith(color: Colors.black)),
                ],
              ),
              Text(
                'تم إنشاء الطلب بنجاح',
                style: font12w400.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Beauty & Skin',
                    style: font18w700.copyWith(color: Colors.black),
                  ),
                  Text(
                    'تسوق أفضل، جودة مضمونة',
                    style: font12w400.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Icon(Icons.shopping_bag_outlined, size: 36, color: _primaryDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Info Box (Right side in RTL)
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _lightGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryDark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person_outline, size: 20, color: _primaryDark),
                    ),
                    const SizedBox(width: 12),
                    Text('بيانات العميل', style: font16w700.copyWith(color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('الاسم:', widget.order.customerName, Icons.badge_outlined),
                _buildInfoRow('رقم الهاتف:', widget.order.phone, Icons.phone_outlined),
                _buildInfoRow('المحافظة:', widget.order.governorate, Icons.location_city_outlined),
                _buildInfoRow('العنوان:', widget.order.address, Icons.home_outlined),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Order Info Box (Left side in RTL)
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryDark,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _primaryDark.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'رقم الطلب',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '#${widget.order.id.length > 5 ? widget.order.id.substring(0, 5) : widget.order.id}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(widget.order.createdAt),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time_rounded, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(widget.order.createdAt),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(label, style: font14w400.copyWith(color: Colors.grey[700])),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: font14w700.copyWith(color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.shopping_cart_outlined, size: 20, color: _primaryDark),
            ),
            const SizedBox(width: 12),
            Text('تفاصيل الطلب', style: font16w700.copyWith(color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: _borderColor),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                // Header (RTL order)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _primaryDark,
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 40, child: _buildTableHeader('م')),
                      Expanded(flex: 4, child: _buildTableHeader('المنتج', isRight: true)),
                      Expanded(flex: 1, child: _buildTableHeader('الكمية')),
                      Expanded(flex: 2, child: _buildTableHeader('السعر')),
                      Expanded(flex: 2, child: _buildTableHeader('الإجمالي')),
                    ],
                  ),
                ),
                // Items
                ...widget.order.items.asMap().entries.map((entry) {
                  int idx = entry.key + 1;
                  var item = entry.value;
                  bool isLast = idx == widget.order.items.length;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: idx % 2 == 0 ? _lightGray : Colors.white,
                      border: isLast ? null : Border(bottom: BorderSide(color: _borderColor)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '$idx',
                                  style: TextStyle(color: Colors.grey[800], fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            item.productName,
                            style: font14w700.copyWith(color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: _buildTableCell('${item.quantity}', isBold: true),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTableCell('${item.price} ج.م'),
                        ),
                        Expanded(
                          flex: 2,
                          child: _buildTableCell('${item.totalPrice} ج.م', isBold: true, color: _primaryDark),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text, {bool isRight = false}) {
    return Text(
      text,
      textAlign: isRight ? TextAlign.right : TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isBold = false, Color? color}) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        color: color ?? Colors.black87,
      ),
    );
  }

  Widget _buildTotalsSection() {
    double subTotal = widget.order.items.fold(0.0, (sum, item) => sum + item.totalPrice);
    double shippingCost = widget.order.totalAmount - subTotal;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Totals Box
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTotalRow('إجمالي المنتجات', '${subTotal.toInt()} ج.م'),
                const SizedBox(height: 12),
                _buildTotalRow('تكلفة الشحن', '${shippingCost.toInt()} ج.م'),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildTotalRow(
                  'الإجمالي النهائي',
                  '${widget.order.totalAmount} ج.م',
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Payment Method Box
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryDark, _primaryDark.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _primaryDark.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                const Text(
                  'طريقة الدفع',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  'الدفع عند الاستلام',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _primaryDark,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const Text(
            'شكراً لثقتك بنا',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'نحن هنا لخدمتك دائماً',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.favorite_border, color: Colors.white70, size: 16),
            ],
          )
        ],
      ),
    );
  }
}
