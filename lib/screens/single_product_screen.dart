import 'package:appium_test_app/models/api_response.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class SingleProductScreen extends StatefulWidget {
  final String productId;

  const SingleProductScreen({super.key, required this.productId});

  @override
  State<SingleProductScreen> createState() => _SingleProductScreenState();
}

class _SingleProductScreenState extends State<SingleProductScreen> {
  final ApiService apiService = ApiService();
  late Future<ApiResponse<Product>> productFuture;

  @override
  void initState() {
    super.initState();
    productFuture = apiService.getProductDetail(widget.productId);
  }

  Future<void> _addToCart() async {
    try {
      final token = await apiService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add items to cart')),
        );
        Navigator.pushNamed(context, '/login');
        return;
      }
      await apiService.addToCart(widget.productId, 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Thêm vào giỏ hàng thất bại: ${e.toString().replaceFirst('Exception: ', '')}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<ApiResponse<Product>>(
        future: productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.success) {
            return Center(
              child: Text(
                'Lỗi khi tải sản phẩm: ${snapshot.data?.error ?? snapshot.error?.toString().replaceFirst('Exception: ', '') ?? 'Không xác định'}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final product = snapshot.data!.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  product.image ?? '',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[300],
                    child: Center(child: Text('Image failed to load')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${product.price.toStringAsFixed(2)} \$',
                        style:
                        const TextStyle(fontSize: 20, color: Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addToCart,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          'Thêm vào giỏ hàng',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}