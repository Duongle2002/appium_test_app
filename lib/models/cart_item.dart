import 'package:appium_test_app/models/product.dart';

class CartItem {
  final String? id; // Có thể không cần nếu backend không trả về
  final Product product;
  int quantity;

  CartItem({
    this.id,
    required this.product,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      product: Product.fromJson(json['productId']), // Backend populate 'productId'
      quantity: json['quantity'],
    );
  }
}