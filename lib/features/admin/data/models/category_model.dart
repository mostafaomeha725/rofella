import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final DateTime createdAt;
  final int order;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.createdAt,
    this.order = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, String id) {
    return CategoryModel(
      id: id,
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      order: json['order'] ?? 9999,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'order': order,
    };
  }
}
