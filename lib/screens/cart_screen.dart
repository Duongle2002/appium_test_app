import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<CartItem>> futureCart;

  @override
  void initState() {
    super.initState();
    _refreshCart();
  }

  void _refreshCart() {
    setState(() {
      futureCart = ApiService.getCart();
    });
  }

  Future<bool> _confirmDelete(BuildContext context, String productName) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa "$productName" khỏi giỏ hàng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Không xóa
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Xóa
            child: Text('Xóa'),
          ),
        ],
      ),
    ) ?? false; // Mặc định là false nếu người dùng thoát dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My cart'),
        actions: [IconButton(icon: Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: FutureBuilder<List<CartItem>>(
        future: futureCart,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final cartItems = snapshot.data!;
            final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            item.product.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                          ),
                        ),
                        title: Text(item.product.name, style: TextStyle(fontFamily: 'Roboto')),
                        subtitle: Text('White\n\$${item.product.price}', style: TextStyle(fontFamily: 'Roboto')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () async {
                                if (item.quantity > 1) {
                                  try {
                                    await ApiService.updateCartQuantity(item.product.id, item.quantity - 1);
                                    _refreshCart();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Quantity updated')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                } else {
                                  // Số lượng = 1, giảm tiếp sẽ = 0 -> Hỏi xóa
                                  final confirm = await _confirmDelete(context, item.product.name);
                                  if (confirm) {
                                    try {
                                      await ApiService.removeFromCart(item.product.id);
                                      _refreshCart();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Item removed')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () async {
                                try {
                                  await ApiService.updateCartQuantity(item.product.id, item.quantity + 1);
                                  _refreshCart();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Quantity updated')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () async {
                                final confirm = await _confirmDelete(context, item.product.name);
                                if (confirm) {
                                  try {
                                    await ApiService.removeFromCart(item.product.id);
                                    _refreshCart();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Item removed')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('NEW2025', style: TextStyle(fontFamily: 'Roboto')),
                          Text('Promocode applied', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: TextStyle(fontFamily: 'Roboto')),
                          Text('\$${subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Delivery Fee', style: TextStyle(fontFamily: 'Roboto')),
                          Text('\$5.00'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Checkout', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                          Text('\$${(subtotal + 5).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/checkout'),
                        child: Text('Checkout for \$${(subtotal + 5).toStringAsFixed(2)}'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}