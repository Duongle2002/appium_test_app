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
    futureCart = ApiService.getCart();
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
                          child: Image.network(item.product.image, width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        title: Text(item.product.name, style: TextStyle(fontFamily: 'Roboto')),
                        subtitle: Text('White\n\$${item.product.price}', style: TextStyle(fontFamily: 'Roboto')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: Icon(Icons.remove), onPressed: () {}),
                            Text('${item.quantity}'),
                            IconButton(icon: Icon(Icons.add), onPressed: () {}),
                            IconButton(icon: Icon(Icons.close), onPressed: () {}),
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