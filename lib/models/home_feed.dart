import 'product.dart';

class HomeFeed {
  final List<Product> flashSales;
  final List<Product> recommended;
  final List<String> categories;
  final Map<String, List<Product>> categoryProducts;

  HomeFeed({
    required this.flashSales,
    required this.recommended,
    required this.categories,
    required this.categoryProducts,
  });

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    List<Product> parseList(String key) {
      final list = json[key] as List<dynamic>? ?? [];
      return list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final catJson = json['category_products'] as Map<String, dynamic>? ?? {};
    final categoryProducts = <String, List<Product>>{};
    catJson.forEach((key, value) {
      final list = value as List<dynamic>? ?? [];
      categoryProducts[key] = list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    return HomeFeed(
      flashSales: parseList('flash_sales'),
      recommended: parseList('recommended'),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      categoryProducts: categoryProducts,
    );
  }
}
