import 'product.dart';

class OrderModel {
  final int id;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String? paymentStatus;
  final String shippingAddress;
  final String? createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.paymentStatus,
    required this.shippingAddress,
    this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentStatus: json['payment_status'] as String?,
      shippingAddress: json['shipping_address'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      items: itemsJson
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderItemModel {
  final int id;
  final int quantity;
  final double price;
  final Product? product;

  OrderItemModel({
    required this.id,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }
}
