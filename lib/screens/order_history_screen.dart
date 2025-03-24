import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<dynamic>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = _fetchOrderHistory();
  }

  Future<List<dynamic>> _fetchOrderHistory() async {
    final token = await ApiService.getToken();
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/history'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['orders'] ?? [];
    }
    throw Exception('Lỗi khi lấy lịch sử đơn hàng: ${response.body}');
  }

  Future<void> _cancelOrder(String orderId) async {
    final token = await ApiService.getToken();
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/history/$orderId/cancel'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order cancelled')));
      setState(() {
        futureOrders = _fetchOrderHistory();
      });
    } else {
      throw Exception('Cancel failed: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order History', style: Theme.of(context).textTheme.headlineLarge),
          SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futureOrders,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final orders = snapshot.data!;
                  if (orders.isEmpty) {
                    return Center(child: Text('No orders yet', style: Theme.of(context).textTheme.bodyMedium));
                  }
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final items = order['items'] as List<dynamic>;
                      final total = order['total']?.toDouble() ?? 0.0;
                      final status = order['status'] ?? 'Pending';
                      final orderId = order['_id'] ?? '';

                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Order #$orderId', style: Theme.of(context).textTheme.bodyLarge),
                                  Text(status, style: TextStyle(color: status == 'Pending' ? Colors.orange : Colors.green)),
                                ],
                              ),
                              SizedBox(height: 8),
                              ...items.map((item) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${item['productId']['name']} x${item['quantity']}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '\$${(item['productId']['price'] * item['quantity']).toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              )),
                              SizedBox(height: 8),
                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total', style: Theme.of(context).textTheme.bodyLarge),
                                  Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                              if (status == 'Pending') ...[
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => _cancelOrder(orderId),
                                  child: Text('Cancel Order'),
                                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}