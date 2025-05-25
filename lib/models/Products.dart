/// A model class representing a product in the system.
class Product {
  final int id; // Unique identifier for the product
  final String name; // Name/title of the product
  final String description; // Description/details about the product
  final double price; // Price of the product
  final int categoryId; // ID of the category the product belongs to
  final int userId; // ID of the user who created or owns the product
  final String? imagePath; // Optional image path for the product

  /// Constructor for creating a Product instance.
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.userId,
    this.imagePath,
  });

  /// Factory constructor for creating a Product instance from JSON.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'], // Convert JSON id field to int
      name: json['name'], // Convert JSON name field to String
      description: json['description'], // Convert JSON description field to String
      price: double.parse(json['price'].toString()), // Parse price to double (handles both string and number)
      categoryId: json['category_id'], // Category ID from JSON
      userId: json['user_id'], // User ID from JSON
      imagePath: json['image_path'], // Image path may be null
    );
  }
}
