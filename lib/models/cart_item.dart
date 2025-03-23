import 'package:appium_test_app/models/product.dart';

class CartItem {
  final String productId;
  final int quantity;
  final Product product;

  CartItem({required this.productId, required this.quantity, required this.product});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId']['_id'],
      quantity: json['quantity'],
      product: Product.fromJson(json['productId']),
    );
  }
}