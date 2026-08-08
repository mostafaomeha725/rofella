import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price; // unit price
  final double totalPrice;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
    );
  }
}

class OrderModel {
  final String id;
  final String customerName;
  final String phone;
  final String governorate;
  final String address;
  final List<OrderItemModel> items;
  final double totalAmount;
  final DateTime createdAt;
  final String status;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.governorate,
    required this.address,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'phone': phone,
      'governorate': governorate,
      'address': address,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      governorate: map['governorate'] ?? '',
      address: map['address'] ?? '',
      items: List<OrderItemModel>.from(
        (map['items'] as List<dynamic>? ?? []).map(
          (x) => OrderItemModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'Pending',
    );
  }
}
