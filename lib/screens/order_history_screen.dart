import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/checkout.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Checkout>> futureOrders;

  @override
  void initState() {
    super.initState();
    futureOrders = ApiService.getOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch Sử Đơn Hàng')),
      body: FutureBuilder<List<Checkout>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text('Đơn hàng #${order.id}'),
                  subtitle: Text('Tổng: ${order.totalPrice} VND - Trạng thái: ${order.status}'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // Có thể thêm màn hình chi tiết đơn hàng ở đây
                  },
                );
              },
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