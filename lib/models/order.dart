import 'package:appium_test_app/models/product.dart';

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product.fromJson(json['productId']),
      quantity: json['quantity'],
    );
  }
}

class Order {
  final String id;
  final List<OrderItem> products;
  final double totalPrice;
  final String status;
  final Map<String, dynamic> shippingInfo;
  final String paymentMethod;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.products,
    required this.totalPrice,
    required this.status,
    required this.shippingInfo,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      products: (json['products'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'],
      shippingInfo: json['shippingInfo'],
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class OrderHistoryResponse {
  final List<Order> orders;
  final int currentPage;
  final int totalPages;

  OrderHistoryResponse({
    required this.orders,
    required this.currentPage,
    required this.totalPages,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OrderHistoryResponse(
      orders: (json['orders'] as List)
          .map((item) => Order.fromJson(item))
          .toList(),
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
    );
  }
}