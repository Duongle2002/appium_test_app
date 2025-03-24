import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/cart_item.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Future<List<CartItem>> futureCart;
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureCart = ApiService.getCart() as Future<List<CartItem>>;
  }

  Future<void> _createCheckout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/checkout'),
        headers: {
          'Authorization': 'Bearer ${await ApiService.getToken()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'address': _addressController.text}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Checkout successful')));
        Navigator.pushNamed(context, '/history');
      } else {
        throw Exception('Checkout failed: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Checkout', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Summary', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 8),
                    FutureBuilder<List<CartItem>>(
                      future: futureCart,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final cartItems = snapshot.data!;
                          final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
                          return Column(
                            children: [
                              ...cartItems.map((item) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${item.product.name} x${item.quantity}', style: Theme.of(context).textTheme.bodyMedium),
                                    Text('\$${(item.product.price * item.quantity).toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              )).toList(),
                              SizedBox(height: 8),
                              Divider(),
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
                                  Text('Total', style: Theme.of(context).textTheme.headlineLarge),
                                  Text('\$${(subtotal + 5).toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineLarge),
                                ],
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text('Lỗi: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium);
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivery Address', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Enter your address',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createCheckout,
              child: Text('Confirm Checkout'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
            ),
          ],
        ),
      ),
    );
  }
}