import 'dart:convert';
import 'package:appium_test_app/models/blog.dart';
import 'package:appium_test_app/models/cart_item.dart';
import 'package:appium_test_app/models/checkout.dart';
import 'package:appium_test_app/models/order.dart';
import 'package:appium_test_app/models/product.dart';
import 'package:appium_test_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://nodejs-ck-x8q8.onrender.com/api';

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

  // Lấy thông tin người dùng
  static Future<User> getUserProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return User.fromJson(jsonData['user']);
    } else {
      throw Exception('Failed to load user profile: ${response.body}');
    }
  }

  // Cập nhật thông tin người dùng
  static Future<void> updateUserProfile(String name, String email) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/users/me'), // Giả định endpoint, thay đổi nếu cần
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
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

  // Thêm sản phẩm vào giỏ hàng
  static Future<void> addToCart(String productId, int quantity) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'), // POST /api/cart
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi khi thêm vào giỏ hàng: ${response.body}');
    }
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
      final List<dynamic> itemsJson = data['cart']['items'];
      return itemsJson.map((json) => CartItem.fromJson(json)).toList();
    }
    throw Exception('Lỗi khi lấy giỏ hàng: ${response.body}');
  }

  // Cập nhật số lượng
  static Future<void> updateCartQuantity(String productId, int quantity) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/cart/update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi khi cập nhật số lượng: ${response.body}');
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  static Future<void> removeFromCart(String productId) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/remove'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'productId': productId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi khi xóa sản phẩm: ${response.body}');
    }
  }


  // Thanh toán
  static Future<Checkout> checkout(Map<String, dynamic> checkoutData) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/checkout'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode(checkoutData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Checkout.fromJson(data['checkout']);
    }
    throw Exception('Checkout failed: ${response.body}');
  }

  // Lấy lịch sử đơn hàng
  // Chỉ hiển thị phần thay đổi
  static Future<List<Order>> getOrderHistory() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/history'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['orders'] as List<dynamic>).map((orderJson) => Order.fromJson(orderJson)).toList();
    }
    throw Exception('Failed to load order history: ${response.body}');
  }

  // Lấy danh sách blog
  static Future<List<Blog>> getBlogs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/blogs'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          return (jsonData['data'] as List).map((blogJson) => Blog.fromJson(blogJson)).toList();
        } else {
          throw Exception('Failed to load blogs: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load blogs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching blogs: $e');
    }
  }

  // Lấy chi tiết blog theo ID
  static Future<Blog> getBlogById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/blogs/$id'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          return Blog.fromJson(jsonData['data']);
        } else {
          throw Exception('Failed to load blog: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load blog: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching blog: $e');
    }
  }
}