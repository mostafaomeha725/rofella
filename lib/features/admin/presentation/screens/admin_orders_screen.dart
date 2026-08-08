import 'package:flutter/material.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/features/admin/data/services/firebase_service.dart';
import 'package:shop/features/cart/data/models/order_model.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderDateFilter { all, today, thisWeek, thisMonth, custom }

enum OrderStatusFilter { all, pending, onTheWay, delivered }

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  OrderDateFilter _currentDateFilter = OrderDateFilter.all;
  OrderStatusFilter _currentStatusFilter = OrderStatusFilter.all;
  DateTime? _selectedDate;

  bool _matchesFilter(OrderModel order) {
    // 1. Status Check
    if (_currentStatusFilter != OrderStatusFilter.all) {
      if (_currentStatusFilter == OrderStatusFilter.pending &&
          order.status != 'Pending')
        return false;
      if (_currentStatusFilter == OrderStatusFilter.onTheWay &&
          order.status != 'OnTheWay')
        return false;
      if (_currentStatusFilter == OrderStatusFilter.delivered &&
          order.status != 'Delivered')
        return false;
    }

    // 2. Date Check
    final date = order.createdAt;
    final now = DateTime.now();
    switch (_currentDateFilter) {
      case OrderDateFilter.all:
        return true;
      case OrderDateFilter.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case OrderDateFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return date.isAfter(startOfWeek.subtract(const Duration(days: 1)));
      case OrderDateFilter.thisMonth:
        return date.year == now.year && date.month == now.month;
      case OrderDateFilter.custom:
        if (_selectedDate == null) return true;
        return date.year == _selectedDate!.year &&
            date.month == _selectedDate!.month &&
            date.day == _selectedDate!.day;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5C2428), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _currentDateFilter = OrderDateFilter.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: AppText(
          'إدارة الطلبات',
          style: font18w700.copyWith(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filters
                  AppText(
                    'حالة الطلب:',
                    style: font14w700.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusChip('الكل', OrderStatusFilter.all),
                        const SizedBox(width: 8),
                        _buildStatusChip(
                          'قيد الانتظار',
                          OrderStatusFilter.pending,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(
                          'في الطريق',
                          OrderStatusFilter.onTheWay,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(
                          'تم التسليم',
                          OrderStatusFilter.delivered,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date Filters
                  AppText(
                    'التاريخ:',
                    style: font14w700.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDateChip('الكل', OrderDateFilter.all),
                        const SizedBox(width: 8),
                        _buildDateChip('اليوم', OrderDateFilter.today),
                        const SizedBox(width: 8),
                        _buildDateChip('هذا الأسبوع', OrderDateFilter.thisWeek),
                        const SizedBox(width: 8),
                        _buildDateChip('هذا الشهر', OrderDateFilter.thisMonth),
                        const SizedBox(width: 8),
                        _buildCustomDateChip(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Orders List
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _firebaseService.getOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: AppText(
                      'حدث خطأ في جلب الطلبات',
                      style: font16w700.copyWith(color: Colors.red),
                    ),
                  );
                }

                final allOrders = snapshot.data ?? [];
                final filteredOrders = allOrders
                    .where((o) => _matchesFilter(o))
                    .toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          'لا توجد طلبات',
                          style: font18w700.copyWith(color: Colors.grey[600]),
                          alignment: AlignmentDirectional.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _OrderCard(order: order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, OrderStatusFilter filter) {
    final isSelected = _currentStatusFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _currentStatusFilter = filter);
        }
      },
      selectedColor: const Color(0xFF5C2428),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildDateChip(String label, OrderDateFilter filter) {
    final isSelected = _currentDateFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _currentDateFilter = filter;
            if (filter != OrderDateFilter.custom) _selectedDate = null;
          });
        }
      },
      selectedColor: const Color(0xFF5C2428),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildCustomDateChip() {
    final isSelected = _currentDateFilter == OrderDateFilter.custom;
    final label = _selectedDate == null
        ? 'تاريخ محدد'
        : '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}';

    return ActionChip(
      label: Text(label),
      avatar: Icon(
        Icons.calendar_month,
        color: isSelected ? Colors.white : Colors.black87,
        size: 16,
      ),
      onPressed: _pickDate,
      backgroundColor: isSelected ? const Color(0xFF5C2428) : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _isExpanded = false;
  bool _isUpdating = false;

  Color _getStatusColor(String status) {
    if (status == 'OnTheWay') return Colors.blue;
    if (status == 'Delivered') return Colors.green;
    return Colors.orange; // Pending
  }

  String _getStatusLabel(String status) {
    if (status == 'OnTheWay') return 'في الطريق';
    if (status == 'Delivered') return 'تم التسليم';
    return 'قيد الانتظار';
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            onExpansionChanged: (expanded) {
              setState(() => _isExpanded = expanded);
            },
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        widget.order.customerName,
                        style: font16w700.copyWith(color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          AppText(
                            _formatDate(widget.order.createdAt),
                            style: font12w400.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                widget.order.status,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getStatusColor(
                                  widget.order.status,
                                ).withValues(alpha: 0.5),
                              ),
                            ),
                            child: AppText(
                              _getStatusLabel(widget.order.status),
                              style: font12w400.copyWith(
                                color: _getStatusColor(widget.order.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C2428).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppText(
                    '${widget.order.totalAmount.toStringAsFixed(2)} ج.م',
                    style: font14w700.copyWith(color: const Color(0xFF5C2428)),
                  ),
                ),
              ],
            ),
            children: [
              Container(
                color: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.phone, 'الهاتف:', widget.order.phone),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.location_on,
                      'المحافظة:',
                      widget.order.governorate,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.home, 'العنوان:', widget.order.address),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          'تحديث الحالة:',
                          style: font14w700.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 12),
                        if (_isUpdating)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: widget.order.status,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
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
                                if (newStatus != null &&
                                    newStatus != widget.order.status) {
                                  setState(() => _isUpdating = true);
                                  await FirebaseService().updateOrderStatus(
                                    widget.order.id,
                                    newStatus,
                                  );

                                  // Send WhatsApp Notification
                                  String message = '';
                                  if (newStatus == 'OnTheWay') {
                                    message =
                                        'مرحباً *${widget.order.customerName}* 👋\n\nيسعدنا إخبارك أن طلبك أصبح الآن 🚚 *في الطريق إليك*!\n\nسيتم التواصل معك قريباً عبر المندوب للتسليم على عنوانك.\n\nشكراً لاختيارك متجرنا! ✨';
                                  } else if (newStatus == 'Delivered') {
                                    message =
                                        'مرحباً *${widget.order.customerName}* 👋\n\nتم 📦 *تسليم* طلبك بنجاح!\n\nنتمنى أن تنال منتجاتنا إعجابك وأن تكون تجربتك معنا مميزة.\n\nنتطلع لرؤيتك مجدداً! ✨';
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

                                  if (mounted)
                                    setState(() => _isUpdating = false);
                                }
                              },
                            ),
                          ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    ),

                    AppText(
                      'المنتجات (${widget.order.items.length}):',
                      style: font14w700.copyWith(color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    ...widget.order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${item.quantity}x',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    item.productName,
                                    style: font14w400.copyWith(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  AppText(
                                    '${item.price.toStringAsFixed(2)} ج.م للقطعة',
                                    style: font12w400.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppText(
                              '${item.totalPrice.toStringAsFixed(2)} ج.م',
                              style: font14w700.copyWith(color: Colors.black87),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        AppText(label, style: font14w700.copyWith(color: Colors.grey[700])),
        const SizedBox(width: 8),
        Expanded(
          child: AppText(
            value,
            style: font14w400.copyWith(color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
