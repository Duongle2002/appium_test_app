import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/checkout.dart';

class ApiService {
  static const String baseUrl = 'http://172.20.10.14:3000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  static Future<bool> verifyToken() async {
    final token = await getToken();
    if (token == null) return false;
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  // Đăng ký
  static Future<void> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode == 201) {
      return; // Đăng ký thành công
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Đăng ký thất bại');
    }
  }

  // Đăng nhập
  static Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print('Login response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Parsed data: $data'); // In dữ liệu đã parse để kiểm tra
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Không nhận được token từ server: $data');
      }
      await setToken(token);
      return token;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Đăng nhập thất bại');
    }
  }
  // Lấy danh sách sản phẩm
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products?page=1&limit=10'));
    print('Response: ${response.statusCode} - ${response.body}'); // Debug
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> productsJson = data['products']; // Đảm bảo key 'products' khớp với backend
      return productsJson.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Lỗi khi lấy sản phẩm: ${response.body}');
  }

  // Thêm vào giỏ hàng
  static Future<void> addToCart(String productId, int quantity) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );
    if (response.statusCode != 200) throw Exception('Lỗi khi thêm vào giỏ hàng');
  }

  // Lấy giỏ hàng
  static Future<List<CartItem>> getCart() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['cart']['items'] as List;
      return items.map((item) => CartItem.fromJson(item)).toList();
    }
    throw Exception('Lỗi khi lấy giỏ hàng');
  }

  // Thanh toán
  static Future<Checkout> checkout(Map<String, String> shippingInfo) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/checkout'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(shippingInfo),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Checkout.fromJson(data['checkout']);
    }
    throw Exception('Lỗi khi thanh toán: ${response.body}');
  }

  // Lấy lịch sử đơn hàng
  static Future<List<Checkout>> getOrderHistory() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final orders = data['orders'] as List;
      return orders.map((order) => Checkout.fromJson(order)).toList();
    }
    throw Exception('Lỗi khi lấy lịch sử đơn hàng');
  }
}