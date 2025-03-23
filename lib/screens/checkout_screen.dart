import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatelessWidget {
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thanh Toán')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _firstnameController, decoration: InputDecoration(labelText: 'Họ')),
            TextField(controller: _lastnameController, decoration: InputDecoration(labelText: 'Tên')),
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Số điện thoại')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _addressController, decoration: InputDecoration(labelText: 'Địa chỉ')),
            TextField(controller: _cityController, decoration: InputDecoration(labelText: 'Thành phố')),
            TextField(controller: _countryController, decoration: InputDecoration(labelText: 'Quốc gia')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final shippingInfo = {
                    'firstname': _firstnameController.text,
                    'lastname': _lastnameController.text,
                    'phone': _phoneController.text,
                    'email': _emailController.text,
                    'streetaddress': _addressController.text,
                    'towncity': _cityController.text,
                    'country': _countryController.text,
                    'payment': 'COD', // Giả định phương thức thanh toán
                  };
                  await ApiService.checkout(shippingInfo);
                  Navigator.pushReplacementNamed(context, '/history');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: Text('Xác Nhận Thanh Toán'),
            ),
          ],
        ),
      ),
    );
  }
}