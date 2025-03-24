import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    futureProducts = ApiService.getProducts() as Future<List<Product>>;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).textTheme.bodyLarge!.color,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Sale'),
            Tab(text: 'New Arrival'),
            Tab(text: 'Best Seller'),
          ],
        ),
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: futureProducts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final allProducts = snapshot.data!;
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductGrid(allProducts.where((p) => p.sale).toList()),
                    _buildProductGrid(allProducts.where((p) => p.newArrival).toList()),
                    _buildProductGrid(allProducts.where((p) => p.bestSeller).toList()),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/product_detail', arguments: product),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    product.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 120),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text('\$${product.price}', style: Theme.of(context).textTheme.bodyMedium),
                          if (product.sale && product.originalPrice != null) ...[
                            SizedBox(width: 4),
                            Text(
                              '\$${product.originalPrice}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}