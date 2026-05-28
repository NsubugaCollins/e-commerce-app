class Product {
  final int id;
  final String productId;
  final String name;
  final String? description;
  final String category;
  final double price;
  final String imageUrl;
  final List<ProductImage> images;

  Product({
    required this.id,
    required this.productId,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List<dynamic>? ?? [];
    return Product(
      id: json['id'] as int,
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      images: imagesJson
          .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductImage {
  final int id;
  final String url;

  ProductImage({required this.id, required this.url});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as int,
      url: json['url'] as String? ?? '',
    );
  }
}
