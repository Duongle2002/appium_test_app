import 'package:appium_test_app/models/product.dart';

class Order {
  final String id;
  final ShippingInfo shippingInfo;
  final String userId;
  final List<OrderItem> products; // Thay items thành products
  final double totalPrice; // Thay total thành totalPrice
  final String status;
  final List<StatusHistory> statusHistory;
  final String paymentMethod;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.shippingInfo,
    required this.userId,
    required this.products,
    required this.totalPrice,
    required this.status,
    required this.statusHistory,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      shippingInfo: ShippingInfo.fromJson(json['shippingInfo'] ?? {}),
      userId: json['userId'] ?? '',
      products: (json['products'] as List<dynamic>? ?? []).map((item) => OrderItem.fromJson(item)).toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Pending',
      statusHistory: (json['statusHistory'] as List<dynamic>? ?? []).map((status) => StatusHistory.fromJson(status)).toList(),
      paymentMethod: json['paymentMethod'] ?? 'Unknown',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ShippingInfo {
  final String firstname;
  final String lastname;
  final String phone;
  final String email;
  final String streetaddress;
  final String towncity;
  final String country;

  ShippingInfo({
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.email,
    required this.streetaddress,
    required this.towncity,
    required this.country,
  });

  factory ShippingInfo.fromJson(Map<String, dynamic> json) {
    return ShippingInfo(
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      streetaddress: json['streetaddress'] ?? '',
      towncity: json['towncity'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class OrderItem {
  final Product product;
  final int quantity;
  final String id;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.id,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product.fromJson(json['productId'] ?? {}),
      quantity: json['quantity'] ?? 0,
      id: json['_id'] ?? '',
    );
  }
}

class StatusHistory {
  final String status;
  final String id;
  final DateTime timestamp;

  StatusHistory({
    required this.status,
    required this.id,
    required this.timestamp,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      status: json['status'] ?? 'Pending',
      id: json['_id'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}