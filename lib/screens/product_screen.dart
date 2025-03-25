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
    _tabController = TabController(length: 4, vsync: this); // Đảm bảo length là 4
    futureProducts = ApiService.getProducts() as Future<List<Product>>;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final selectedCategory = arguments?['category'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory ?? 'Products', style: TextStyle(fontFamily: 'Poppins')),
        bottom: selectedCategory == null
            ? TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).textTheme.bodyLarge!.color,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'Sale'),
            Tab(text: 'New Arrival'),
            Tab(text: 'Best Seller'),
            Tab(text: 'All'),
          ],
        )
            : null,
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var allProducts = snapshot.data!;
            if (selectedCategory != null) {
              allProducts = allProducts.where((p) => p.category == selectedCategory).toList();
              return allProducts.isEmpty
                  ? Center(child: Text('No products available in this category', style: Theme.of(context).textTheme.bodyMedium))
                  : _buildProductGrid(allProducts);
            } else {
              return TabBarView(
                controller: _tabController,
                children: [
                  allProducts.where((p) => p.sale).isEmpty
                      ? Center(child: Text('No sale products available', style: Theme.of(context).textTheme.bodyMedium))
                      : _buildProductGrid(allProducts.where((p) => p.sale).toList()),
                  allProducts.where((p) => p.newArrival).isEmpty
                      ? Center(child: Text('No new arrival products available', style: Theme.of(context).textTheme.bodyMedium))
                      : _buildProductGrid(allProducts.where((p) => p.newArrival).toList()),
                  allProducts.where((p) => p.bestSeller).isEmpty
                      ? Center(child: Text('No best seller products available', style: Theme.of(context).textTheme.bodyMedium))
                      : _buildProductGrid(allProducts.where((p) => p.bestSeller).toList()),
                  allProducts.isEmpty
                      ? Center(child: Text('No products available', style: Theme.of(context).textTheme.bodyMedium))
                      : _buildProductGrid(allProducts),
                ],
              );
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
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