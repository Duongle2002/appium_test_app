import 'package:appium_test_app/models/cart_item.dart';

class Checkout {
  final String id;
  final List<CartItem> products;
  final double totalPrice;
  final String status;

  Checkout({required this.id, required this.products, required this.totalPrice, required this.status});

  factory Checkout.fromJson(Map<String, dynamic> json) {
    return Checkout(
      id: json['_id'],
      products: (json['products'] as List).map((item) => CartItem.fromJson(item)).toList(),
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'],
    );
  }
}