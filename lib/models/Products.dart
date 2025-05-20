class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final int userId;
  final String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.userId,
    this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      categoryId: json['category_id'],
      userId: json['user_id'],
      imagePath: json['image_path'],
    );
  }
}
