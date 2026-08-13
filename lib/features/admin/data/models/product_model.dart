class ProductModel {
  final String? id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final DateTime? createdAt;
  final List<String>? colors;
  final List<String>? sizes;
  final double? oldPrice;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    this.createdAt,
    this.colors,
    this.sizes,
    this.oldPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'name_lower': name.toLowerCase(),
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'colors': colors,
      'sizes': sizes,
      'oldPrice': oldPrice,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      colors: map['colors'] != null ? List<String>.from(map['colors']) : null,
      sizes: map['sizes'] != null ? List<String>.from(map['sizes']) : null,
      oldPrice: map['oldPrice'] != null ? (map['oldPrice'] as num).toDouble() : null,
    );
  }
}
