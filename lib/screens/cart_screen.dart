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
      futureCart = ApiService.getCart() as Future<List<CartItem>>;
    });
  }

  Future<bool> _confirmDelete(BuildContext context, String productName) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận', style: Theme.of(context).textTheme.headlineLarge),
        content: Text('Bạn có chắc muốn xóa "$productName" khỏi giỏ hàng không?', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: FutureBuilder<List<CartItem>>(
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
                      return Card(
                        child: ListTile(
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
                          title: Text(item.product.name, style: Theme.of(context).textTheme.bodyLarge),
                          subtitle: Text('\$${item.product.price}', style: Theme.of(context).textTheme.bodyMedium),
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
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quantity updated')));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                    }
                                  } else {
                                    final confirm = await _confirmDelete(context, item.product.name);
                                    if (confirm) {
                                      try {
                                        await ApiService.removeFromCart(item.product.id);
                                        _refreshCart();
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item removed')));
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                      }
                                    }
                                  }
                                },
                              ),
                              Text('${item.quantity}', style: Theme.of(context).textTheme.bodyMedium),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () async {
                                  try {
                                    await ApiService.updateCartQuantity(item.product.id, item.quantity + 1);
                                    _refreshCart();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quantity updated')));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Item removed')));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('NEW2025', style: Theme.of(context).textTheme.bodyMedium),
                            Text('Promocode applied', style: TextStyle(color: Colors.green)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium),
                            Text('\$${subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Delivery Fee', style: Theme.of(context).textTheme.bodyMedium),
                            Text('\$5.00', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Checkout', style: Theme.of(context).textTheme.headlineLarge),
                            Text('\$${(subtotal + 5).toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineLarge),
                          ],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/checkout'),
                          child: Text('Checkout for \$${(subtotal + 5).toStringAsFixed(2)}'),
                          style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                        ),
                      ],
                    ),
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