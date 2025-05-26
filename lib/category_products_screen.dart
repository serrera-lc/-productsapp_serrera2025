import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'productinfo.dart';
import 'package:provider/provider.dart';
import 'models/language_model.dart';

// Stateful widget to display products filtered by category
class CategoryProductsScreen extends StatefulWidget {
  final int initialCategoryId; // Initial category to display
  final String
      initialCategoryName; // Initial category name to display in app bar

  const CategoryProductsScreen({
    super.key,
    required this.initialCategoryId,
    required this.initialCategoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Map<String, dynamic>> categories =
      []; // List to hold categories from API
  List<Map<String, dynamic>> products =
      []; // List to hold products of selected category
  int? selectedCategoryId; // Currently selected category id
  String? selectedCategoryName; // Currently selected category name
  bool isLoading = true; // Loading state to show progress indicator

  @override
  void initState() {
    super.initState();
    // Initialize selected category from widget properties
    selectedCategoryId = widget.initialCategoryId;
    selectedCategoryName = widget.initialCategoryName;
    // Load categories and products initially
    loadCategoriesAndProducts();
  }

  // Load categories and products for the initially selected category
  Future<void> loadCategoriesAndProducts() async {
    setState(() => isLoading = true); // Show loading spinner
    await loadCategories(); // Load categories from API
    await loadProductsForCategory(
        selectedCategoryId!); // Load products for selected category
    setState(() => isLoading = false); // Hide loading spinner
  }

  // Fetch categories from backend API
  Future<void> loadCategories() async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/api/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        // Map the response into list of categories with id and name
        categories = data
            .map<Map<String, dynamic>>((item) => {
                  'id': item['id'],
                  'name': item['name'],
                })
            .toList();
      });
    }
  }

  // Fetch products belonging to a specific category from backend API
  Future<void> loadProductsForCategory(int categoryId) async {
    setState(
        () => isLoading = true); // Show loading spinner when loading products
    final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/categories/$categoryId/products'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      // Some APIs return data under a "data" key, so fallback if not present
      final List<dynamic> raw = jsonData['data'] ?? jsonData;
      setState(() {
        // Update products list with new data
        products = List<Map<String, dynamic>>.from(raw);
        selectedCategoryId = categoryId;
        // Update selected category name by finding it in categories list
        selectedCategoryName =
            categories.firstWhere((c) => c['id'] == categoryId)['name'];
        isLoading = false; // Hide loading spinner
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFilipino = Provider.of<LanguageModel>(context).isFilipino();
    return Scaffold(
      appBar: AppBar(
        // Show selected category name in the app bar
        title: Text(
            selectedCategoryName ?? (isFilipino ? "Kategorya" : "Category")),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Decorative wave/gradient background
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.withOpacity(0.7),
                          Colors.blue.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(150),
                    ),
                  ),
                ),
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.withOpacity(0.7),
                          Colors.blue.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(150),
                    ),
                  ),
                ),
                // Main content wrapped in a glassmorphism Card
                Center(
                  child: SingleChildScrollView(
                    child: Card(
                      margin: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Section: Category Selector
                            Text(
                              isFilipino
                                  ? "Pumili ng Kategorya"
                                  : "Select Category",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            ),
                            SizedBox(height: 8),
                            // Dropdown for selecting category
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButton<int>(
                                value: selectedCategoryId,
                                // Create dropdown menu items from categories list
                                items: categories
                                    .map((cat) => DropdownMenuItem<int>(
                                          value: cat['id'],
                                          child: Text(cat['name']),
                                        ))
                                    .toList(),
                                // When category is changed, load products for new category
                                onChanged: (value) {
                                  if (value != null) {
                                    loadProductsForCategory(value);
                                  }
                                },
                                isExpanded: true,
                                underline: SizedBox(),
                              ),
                            ),
                            SizedBox(height: 16),
                            // Section: Product List
                            Text(
                              isFilipino ? "Mga Produkto" : "Products",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            ),
                            SizedBox(height: 8),
                            // Expanded widget to fill remaining space with product grid/list
                            products.isEmpty
                                // If no products found, show message
                                ? Center(
                                    child: Text(isFilipino
                                        ? "Walang nahanap na produkto."
                                        : "No products found."))
                                // Display products in a grid layout
                                : GridView.builder(
                                    padding: EdgeInsets.all(8),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, // 2 products per row
                                      mainAxisSpacing: 8,
                                      crossAxisSpacing: 8,
                                      childAspectRatio:
                                          0.7, // Height to width ratio of each product card
                                    ),
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      final product = products[index];
                                      // Check if product has an image path
                                      final hasImage =
                                          product['image_path'] != null &&
                                              product['image_path']
                                                  .toString()
                                                  .isNotEmpty;
                                      // Use network image if available, else fallback to placeholder asset
                                      final imageWidget = hasImage
                                          ? Image.network(
                                              '${AppConfig.baseUrl}/storage/${product['image_path']}',
                                              height: 120,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              // Handle image loading errors by showing placeholder image
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                      'assets/product_placeholder.png',
                                                      height: 120,
                                                      fit: BoxFit.cover),
                                            )
                                          : Image.asset(
                                              'assets/product_placeholder.png',
                                              height: 120,
                                              fit: BoxFit.cover);
                                      return Container(
                                        margin: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 8,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: InkWell(
                                          // Navigate to product details page when tapped
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    ProductDetailsScreen(
                                                        product: product),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                                child:
                                                    imageWidget, // Show product image
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  product['name'] ?? '',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  product['description'] ?? '',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '₱${product['price']?.toString() ?? ''}',
                                                  style: TextStyle(
                                                      color: Colors.teal,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
