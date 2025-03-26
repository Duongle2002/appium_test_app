import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../providers/theme_provider.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> futureProducts;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureProducts = ApiService.getProducts() as Future<List<Product>>;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  List<Map<String, dynamic>> _getCategories(List<Product> products) {
    final uniqueCategories = products.map((p) => p.category).toSet().toList();
    final categoryColors = [
      Color(0xFFF8E1E9),
      Color(0xFFE9E1F8),
      Color(0xFFF8E9E1),
      Color(0xFFE1F8E9),
    ];
    final categoryIcons = [
      Icons.local_florist,
      Icons.wine_bar,
      Icons.star,
      Icons.local_drink,
    ];

    return uniqueCategories.asMap().entries.map((entry) {
      int index = entry.key;
      String category = entry.value;
      return {
        'name': category,
        'icon': categoryIcons[index % categoryIcons.length],
        'color': categoryColors[index % categoryColors.length],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh tìm kiếm
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.6),
              ),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF8A4AF0)),
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),
          _buildBanner(),
          SizedBox(height: 24),
          _buildSectionTitle(context, 'Special Offers'),
          _buildSpecialOffers(),
          SizedBox(height: 24),
          _buildSectionTitle(context, 'Categories', seeAll: true, onSeeAll: () {
            Navigator.pushNamed(context, '/products');
          }),
          _buildCategories(),
          SizedBox(height: 24),
          _buildSectionTitle(context, 'New Arrivals', seeAll: true),
          _buildNewArrivals(),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1600585154340-be6161a56a0c'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WINE DAY\nWINE & CHEESE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == 0 ? Colors.white : Colors.white.withOpacity(0.5),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {bool seeAll = false, VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        if (seeAll)
          TextButton(
            onPressed: onSeeAll ?? () {},
            child: Text('See All', style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
          ),
      ],
    );
  }

  Widget _buildSpecialOffers() {
    return FutureBuilder<List<Product>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final offers = snapshot.data!
              .where((p) => p.sale)
              .where((p) => _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery))
              .toList();
          if (offers.isEmpty && _searchQuery.isNotEmpty) {
            return Center(child: Text('No special offers found', style: Theme.of(context).textTheme.bodyLarge));
          }
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/product_detail', arguments: offer),
                  child: _buildProductCard(offer),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyLarge));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCategories() {
    return FutureBuilder<List<Product>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final filteredProducts = snapshot.data!
              .where((p) => _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery))
              .toList();
          final categories = _getCategories(filteredProducts);
          return GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/products',
                    arguments: {'category': category['name']},
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: category['color'],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(category['icon'], size: 40, color: Colors.black54),
                      SizedBox(height: 8),
                      Text(category['name'], style: TextStyle(fontFamily: 'Poppins', color: Colors.black)),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyLarge));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildNewArrivals() {
    return FutureBuilder<List<Product>>(
      future: futureProducts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final newArrivals = snapshot.data!
              .where((p) => p.newArrival)
              .where((p) => _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery))
              .toList();
          if (newArrivals.isEmpty && _searchQuery.isNotEmpty) {
            return Center(child: Text('No new arrivals found', style: Theme.of(context).textTheme.bodyLarge));
          }
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: newArrivals.length,
              itemBuilder: (context, index) {
                final product = newArrivals[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/product_detail', arguments: product),
                  child: _buildProductCard(product),
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyLarge));
        }
        return Center(child: CircularProgressIndicator());
      },
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
                errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 120),
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}