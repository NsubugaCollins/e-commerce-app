import 'product.dart';

class CartItemModel {
  final int id;
  final int productId;
  final int quantity;
  final double lineTotal;
  final Product product;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.lineTotal,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      lineTotal: (json['line_total'] as num).toDouble(),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );
  }
}

class CartResponse {
  final List<CartItemModel> items;
  final double total;
  final int itemCount;

  CartResponse({
    required this.items,
    required this.total,
    required this.itemCount,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return CartResponse(
      items: itemsJson
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
    );
  }
}
