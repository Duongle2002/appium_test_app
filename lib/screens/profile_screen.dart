import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> futureUser;
  late Future<List<Order>> futureOrders;
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    futureUser = ApiService.getUserProfile() as Future<User>;
    futureOrders = ApiService.getOrderHistory() as Future<List<Order>>;
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    try {
      await ApiService.updateUserProfile(_nameController.text, _emailController.text);
      setState(() {
        _isEditing = false;
        futureUser = ApiService.getUserProfile() as Future<User>; // Refresh dữ liệu
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Canh giữa)
            Center(
              child: FutureBuilder<User>(
                future: futureUser,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    if (!_isEditing) {
                      _nameController.text = user.name;
                      _emailController.text = user.email;
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFFF8E1E9),
                          child: Text(
                            user.name[0].toUpperCase(),
                            style: TextStyle(fontSize: 32, color: Colors.black),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(user.name, style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
                        SizedBox(height: 4),
                        Text(user.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center);
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
            SizedBox(height: 24),

            // Phần chỉnh sửa (Chỉ hiện khi _isEditing = true)
            if (_isEditing)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Edit Personal Information', style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _updateProfile,
                            child: Text('Save'),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _isEditing = false),
                            child: Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (_isEditing) SizedBox(height: 24),

            // Lịch sử đơn hàng
            Text('Order History', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 16),
            FutureBuilder<List<Order>>(
              future: futureOrders,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final orders = snapshot.data!;
                  if (orders.isEmpty) {
                    return Text('No orders yet', style: Theme.of(context).textTheme.bodyMedium);
                  }
                  return Column(
                    children: orders.map((order) {
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
                                  Flexible(
                                    child: Text(
                                      'Order #${order.id}',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    order.status,
                                    style: TextStyle(color: order.status == 'Pending' ? Colors.orange : Colors.green),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ...order.products.map((item) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${item.product.name} x${item.quantity}',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
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
                                  Text('\$${order.totalPrice.toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text('Payment: ${order.paymentMethod}', style: Theme.of(context).textTheme.bodyMedium),
                              Text('Created: ${order.createdAt.toString().split('.')[0]}', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium);
                }
                return CircularProgressIndicator();
              },
            ),
            SizedBox(height: 24),

            // Tùy chọn
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _isEditing = true),
                      child: Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => themeProvider.toggleTheme(),
                      child: Text(isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text('Logout'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}