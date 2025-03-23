class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice;
  final String image;
  final bool sale;
  final bool newArrival;
  final bool bestSeller;
  final String description;
  final String content;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.image,
    required this.sale,
    required this.newArrival,
    required this.bestSeller,
    required this.description,
    required this.content,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] is String ? json['_id'] : json['_id']['\$oid'], // Xử lý cả String và Map
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      image: json['image'],
      sale: json['sale'] ?? false,
      newArrival: json['newArrival'] ?? false,
      bestSeller: json['bestSeller'] ?? false,
      description: json['description'],
      content: json['content'],
    );
  }
}