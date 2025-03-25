import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<List<Product>> futureRelatedProducts;
  int quantity = 1; // Số lượng mặc định
  bool isFavorite = false; // Trạng thái yêu thích (giả định)

  @override
  void initState() {
    super.initState();
    futureRelatedProducts = ApiService.getProducts() as Future<List<Product>>;
  }

  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(product.name, style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.image,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.broken_image,
                    size: 300,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
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
                      child: Image.network(
                        product.image, // Nếu backend hỗ trợ nhiều ảnh, cần cập nhật logic
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                  )),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Theme.of(context).iconTheme.color,
                            ),
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                              });
                              // TODO: Gọi API để lưu trạng thái yêu thích
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(isFavorite ? 'Added to favorites' : 'Removed from favorites')),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 20),
                          SizedBox(width: 4),
                          Text('4.9', style: Theme.of(context).textTheme.bodyMedium), // Thay bằng product.rating nếu có
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 8),
                      if (product.content.isNotEmpty) ...[
                        Text(
                          'Details:',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: 4),
                        Text(
                          product.content,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '\$${product.price}',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          if (product.sale && product.originalPrice != null) ...[
                            SizedBox(width: 8),
                            Text(
                              '\$${product.originalPrice}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Quantity:', style: Theme.of(context).textTheme.bodyLarge),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: quantity > 1
                                ? () {
                              setState(() {
                                quantity--;
                              });
                            }
                                : null,
                          ),
                          Text('$quantity', style: Theme.of(context).textTheme.bodyLarge),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await ApiService.addToCart(product.id, quantity);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added $quantity item(s) to cart')),
                          );
                        },
                        child: Text('Add to cart'),
                        style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                          minimumSize: MaterialStateProperty.all(Size(double.infinity, 48)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text('Related Products', style: Theme.of(context).textTheme.headlineLarge),
              SizedBox(height: 16),
              FutureBuilder<List<Product>>(
                future: futureRelatedProducts,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final relatedProducts = snapshot.data!
                        .where((p) => p.id != product.id && p.category == product.category) // Lọc theo category
                        .toList()
                        .take(4) // Lấy tối đa 4 sản phẩm
                        .toList();
                    if (relatedProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No related products available',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedProducts.length,
                        itemBuilder: (context, index) {
                          final relatedProduct = relatedProducts[index];
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/product_detail', arguments: relatedProduct),
                            child: _buildProductCard(relatedProduct),
                          );
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        shape: Theme.of(context).cardTheme.shape,
        elevation: Theme.of(context).cardTheme.elevation,
        color: Theme.of(context).cardTheme.color,
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
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.broken_image,
                  size: 120,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product.price}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (product.sale && product.originalPrice != null) ...[
                        SizedBox(width: 4),
                        Text(
                          '\$${product.originalPrice}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
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
  }
}