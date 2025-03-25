import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/cart_item.dart';
import '../models/checkout.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Future<List<CartItem>> futureCart;
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _townCityController = TextEditingController();
  final _countryController = TextEditingController();
  final _promoCodeController = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';
  double _discount = 0.0;
  List<Map<String, String>> _savedAddresses = [];
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    futureCart = ApiService.getCart() as Future<List<CartItem>>;
    _loadSavedAddresses();
  }

  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final addressesJson = prefs.getString('saved_addresses') ?? '[]';
    final List<dynamic> addressesList = jsonDecode(addressesJson);
    setState(() {
      _savedAddresses = addressesList.map((addr) => Map<String, String>.from(addr)).toList();
      if (_savedAddresses.isNotEmpty) {
        _fillFormWithAddress(_savedAddresses.first);
        _selectedAddress = _savedAddresses.first['streetaddress'];
      }
    });
  }

  Future<void> _saveShippingInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final shippingInfo = {
      'firstname': _firstnameController.text,
      'lastname': _lastnameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'streetaddress': _streetAddressController.text,
      'apartment': _apartmentController.text,
      'towncity': _townCityController.text,
      'country': _countryController.text,
    };

    // Loại bỏ địa chỉ trùng lặp và thêm địa chỉ mới
    _savedAddresses.removeWhere((addr) => addr['streetaddress'] == shippingInfo['streetaddress']);
    _savedAddresses.insert(0, shippingInfo);
    await prefs.setString('saved_addresses', jsonEncode(_savedAddresses));
  }

  void _fillFormWithAddress(Map<String, String> address) {
    _firstnameController.text = address['firstname'] ?? '';
    _lastnameController.text = address['lastname'] ?? '';
    _phoneController.text = address['phone'] ?? '';
    _emailController.text = address['email'] ?? '';
    _streetAddressController.text = address['streetaddress'] ?? '';
    _apartmentController.text = address['apartment'] ?? '';
    _townCityController.text = address['towncity'] ?? '';
    _countryController.text = address['country'] ?? '';
  }

  Future<void> _applyPromoCode(String code) async {
    if (code == 'NEW2025') {
      setState(() {
        _discount = 10.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Promo code applied: -\$10')));
    } else {
      setState(() {
        _discount = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid promo code')));
    }
  }

  Future<bool> _confirmCheckout(double total) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text('Confirm Checkout', style: Theme.of(context).textTheme.headlineLarge),
        content: Text(
          'Total: \$${total.toStringAsFixed(2)}\nAre you sure you want to proceed?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green)),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _createCheckout(List<CartItem> cartItems) async {
    if (!_formKey.currentState!.validate()) return;

    final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
    final total = subtotal + 5 - _discount;

    final confirm = await _confirmCheckout(total);
    if (!confirm) return;

    final shippingInfo = {
      'firstname': _firstnameController.text,
      'lastname': _lastnameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'streetaddress': _streetAddressController.text,
      'apartment': _apartmentController.text,
      'towncity': _townCityController.text,
      'country': _countryController.text,
    };

    final checkoutData = {
      'products': cartItems.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
      }).toList(),
      'totalPrice': total,
      'shippingInfo': shippingInfo,
      'paymentMethod': _paymentMethod,
    };

    try {
      final checkout = await ApiService.checkout(checkoutData);
      await _saveShippingInfo();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout successful')),
      );
      Navigator.pushNamed(context, '/history');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Checkout', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: FutureBuilder<List<CartItem>>(
            future: futureCart,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final cartItems = snapshot.data!;
                final subtotal = cartItems.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
                final total = subtotal + 5 - _discount;

                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: Theme.of(context).cardTheme.shape,
                        elevation: Theme.of(context).cardTheme.elevation,
                        color: Theme.of(context).cardTheme.color,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order Summary', style: Theme.of(context).textTheme.bodyLarge),
                              SizedBox(height: 8),
                              ...cartItems.map((item) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
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
                              if (_discount > 0) ...[
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Discount', style: Theme.of(context).textTheme.bodyMedium),
                                    Text(
                                      '-\$${_discount.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green),
                                    ),
                                  ],
                                ),
                              ],
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Total', style: Theme.of(context).textTheme.headlineLarge),
                                  Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineLarge),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        shape: Theme.of(context).cardTheme.shape,
                        elevation: Theme.of(context).cardTheme.elevation,
                        color: Theme.of(context).cardTheme.color,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Promo Code', style: Theme.of(context).textTheme.bodyLarge),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _promoCodeController,
                                      decoration: InputDecoration(
                                        labelText: 'Enter promo code',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _applyPromoCode(_promoCodeController.text),
                                    child: Text('Apply'),
                                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                      minimumSize: MaterialStateProperty.all(Size(100, 48)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        shape: Theme.of(context).cardTheme.shape,
                        elevation: Theme.of(context).cardTheme.elevation,
                        color: Theme.of(context).cardTheme.color,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Shipping Information', style: Theme.of(context).textTheme.bodyLarge),
                              SizedBox(height: 8),
                              if (_savedAddresses.isNotEmpty) ...[
                                DropdownButtonFormField<String>(
                                  value: _selectedAddress,
                                  decoration: InputDecoration(
                                    labelText: 'Saved Addresses',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  items: _savedAddresses
                                      .map((addr) => DropdownMenuItem(
                                    value: addr['streetaddress'],
                                    child: Text('${addr['streetaddress']}, ${addr['towncity']}'),
                                  ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedAddress = value;
                                      final selected = _savedAddresses.firstWhere((addr) => addr['streetaddress'] == value);
                                      _fillFormWithAddress(selected);
                                    });
                                  },
                                ),
                                SizedBox(height: 8),
                              ],
                              TextFormField(
                                controller: _firstnameController,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _lastnameController,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter your last name' : null,
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Please enter a valid email' : null,
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _streetAddressController,
                                decoration: InputDecoration(
                                  labelText: 'Street Address',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter your street address' : null,
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _apartmentController,
                                decoration: InputDecoration(
                                  labelText: 'Apartment (Optional)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _townCityController,
                                decoration: InputDecoration(
                                  labelText: 'Town/City',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter your town/city' : null,
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _countryController,
                                decoration: InputDecoration(
                                  labelText: 'Country',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (value) => value!.isEmpty ? 'Please enter your country' : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        shape: Theme.of(context).cardTheme.shape,
                        elevation: Theme.of(context).cardTheme.elevation,
                        color: Theme.of(context).cardTheme.color,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Payment Method', style: Theme.of(context).textTheme.bodyLarge),
                              SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _paymentMethod,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: ['Cash on Delivery', 'Credit Card', 'PayPal']
                                    .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _paymentMethod = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _createCheckout(cartItems),
                        child: Text('Confirm Checkout (\$${total.toStringAsFixed(2)})'),
                        style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                          minimumSize: MaterialStateProperty.all(Size(double.infinity, 48)),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyLarge),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _streetAddressController.dispose();
    _apartmentController.dispose();
    _townCityController.dispose();
    _countryController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }
}