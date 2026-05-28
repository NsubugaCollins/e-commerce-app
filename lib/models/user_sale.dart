class UserSaleModel {
  final int id;
  final int userId;
  final String? userName;
  final String productName;
  final String category;
  final String condition;
  final String description;
  final double expectedPrice;
  final double? offeredPrice;
  final String status;
  final String? adminNotes;
  final List<SaleImage> images;
  final String? createdAt;

  UserSaleModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.productName,
    required this.category,
    required this.condition,
    required this.description,
    required this.expectedPrice,
    this.offeredPrice,
    required this.status,
    this.adminNotes,
    this.images = const [],
    this.createdAt,
  });

  factory UserSaleModel.fromJson(Map<String, dynamic> json) {
    final imgs = json['images'] as List<dynamic>? ?? [];
    return UserSaleModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String?,
      productName: json['product_name'] as String,
      category: json['category'] as String,
      condition: json['condition'] as String,
      description: json['description'] as String,
      expectedPrice: (json['expected_price'] as num).toDouble(),
      offeredPrice: json['offered_price'] != null
          ? (json['offered_price'] as num).toDouble()
          : null,
      status: json['status'] as String,
      adminNotes: json['admin_notes'] as String?,
      images: imgs
          .map((e) => SaleImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
    );
  }
}

class SaleImage {
  final int id;
  final String url;
  SaleImage({required this.id, required this.url});
  factory SaleImage.fromJson(Map<String, dynamic> json) {
    return SaleImage(id: json['id'] as int, url: json['url'] as String? ?? '');
  }
}
