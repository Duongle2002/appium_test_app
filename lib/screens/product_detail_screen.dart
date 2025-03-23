import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'), // Chuyển sang CartScreen
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {}, // Giữ nguyên chức năng chia sẻ (có thể thêm logic sau)
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              child: Image.network(product.image, fit: BoxFit.cover),
            ),
            Container(
              height: 80,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(4, (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(product.image, width: 80, fit: BoxFit.cover),
                  ),
                )),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: TextStyle(fontSize: 24, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 20),
                      SizedBox(width: 4),
                      Text('4.9', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    product.description, // Sử dụng description từ dữ liệu
                    style: TextStyle(fontSize: 14, fontFamily: 'Roboto', color: Colors.black54),
                  ),
                  SizedBox(height: 16),
                  Text('\$${product.price}', style: TextStyle(fontSize: 20, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await ApiService.addToCart(product.id, 1);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to cart')));
                    },
                    child: Text('Add to cart'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}