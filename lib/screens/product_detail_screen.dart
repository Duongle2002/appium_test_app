import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context)!.settings.arguments as Product;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(product.image, height: 300, width: double.infinity, fit: BoxFit.cover),
            ),
            SizedBox(height: 16),
            Container(
              height: 80,
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
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: Theme.of(context).textTheme.headlineLarge),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 20),
                        SizedBox(width: 4),
                        Text('4.9', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: 16),
                    Text('\$${product.price}', style: Theme.of(context).textTheme.headlineLarge),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        await ApiService.addToCart(product.id, 1);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to cart')));
                      },
                      child: Text('Add to cart'),
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