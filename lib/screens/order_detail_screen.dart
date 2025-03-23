import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/order.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Order> _orderFuture;

  @override
  void initState() {
    super.initState();
    _orderFuture = _apiService.getOrderDetail(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Detail')),
      body: FutureBuilder<Order>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Order not found'));
          }

          final order = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Status: ${order.status}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Total: \$${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.green)),
                const SizedBox(height: 16),
                Text('Products:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...order.products.map((item) => ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('Quantity: ${item.quantity} - Price: \$${item.product.price.toStringAsFixed(2)}'),
                )),
                const SizedBox(height: 16),
                Text('Shipping Info:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Name: ${order.shippingInfo['firstname']} ${order.shippingInfo['lastname']}'),
                Text('Phone: ${order.shippingInfo['phone']}'),
                Text('Email: ${order.shippingInfo['email']}'),
                Text('Address: ${order.shippingInfo['streetaddress']}, ${order.shippingInfo['towncity']}, ${order.shippingInfo['country']}'),
                const SizedBox(height: 16),
                Text('Payment Method: ${order.paymentMethod}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Created At: ${order.createdAt.toLocal().toString()}', style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}