import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'productinfo.dart';

class CategoryProductsScreen extends StatefulWidget {
  final int initialCategoryId;
  final String initialCategoryName;

  const CategoryProductsScreen({
    super.key,
    required this.initialCategoryId,
    required this.initialCategoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> products = [];
  int? selectedCategoryId;
  String? selectedCategoryName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.initialCategoryId;
    selectedCategoryName = widget.initialCategoryName;
    loadCategoriesAndProducts();
  }

  Future<void> loadCategoriesAndProducts() async {
    setState(() => isLoading = true);
    await loadCategories();
    await loadProductsForCategory(selectedCategoryId!);
    setState(() => isLoading = false);
  }

  Future<void> loadCategories() async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/api/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        categories = data
            .map<Map<String, dynamic>>((item) => {
                  'id': item['id'],
                  'name': item['name'],
                })
            .toList();
      });
    }
  }

  Future<void> loadProductsForCategory(int categoryId) async {
    setState(() => isLoading = true);
    final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/categories/$categoryId/products'));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> raw = jsonData['data'] ?? jsonData;
      setState(() {
        products = List<Map<String, dynamic>>.from(raw);
        selectedCategoryId = categoryId;
        selectedCategoryName =
            categories.firstWhere((c) => c['id'] == categoryId)['name'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategoryName ?? "Category"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Category selector
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<int>(
                    value: selectedCategoryId,
                    items: categories
                        .map((cat) => DropdownMenuItem<int>(
                              value: cat['id'],
                              child: Text(cat['name']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        loadProductsForCategory(value);
                      }
                    },
                  ),
                ),
                // Products grid/list
                Expanded(
                  child: products.isEmpty
                      ? Center(child: Text("No products found."))
                      : GridView.builder(
                          padding: EdgeInsets.all(8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            final hasImage = product['image_path'] != null &&
                                product['image_path'].toString().isNotEmpty;
                            final imageWidget = hasImage
                                ? Image.network(
                                    '${AppConfig.baseUrl}/storage/${product['image_path']}',
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        Image.asset(
                                            'assets/product_placeholder.png',
                                            height: 120,
                                            fit: BoxFit.cover),
                                  )
                                : Image.asset('assets/product_placeholder.png',
                                    height: 120, fit: BoxFit.cover);
                            return Card(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                          product: product),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    imageWidget,
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        product['name'] ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        product['description'] ?? '',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '₱${product['price']?.toString() ?? ''}',
                                        style: TextStyle(
                                            color: Colors.teal,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
