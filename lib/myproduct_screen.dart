import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP requests
import 'dart:convert'; // JSON decoding
import 'models/Products.dart'; // Product model
import 'editproduct_screen.dart'; // Screen for editing a product
import 'config.dart'; // App config including base URL

class MyProductsScreen extends StatefulWidget {
  final int userId; // User ID whose products will be fetched

  const MyProductsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Product> _products = []; // List of products loaded
  Set<int> _selectedProductIds = {}; // Set of selected product IDs for bulk actions

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products when screen loads
  }

  // Fetch products for the current user from API
  Future<void> _fetchProducts() async {
    final response = await http
        .get(Uri.parse('${AppConfig.baseUrl}/api/products/${widget.userId}'));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      // If API returns a Map with 'data' field, use it; else wrap single product in list
      final List<dynamic> data =
          body is Map && body['data'] != null ? body['data'] : [body];
      setState(() {
        // Parse JSON into list of Product objects
        _products = data.map((item) => Product.fromJson(item)).toList();
      });
    } else {
      // TODO: Handle error fetching products (e.g., show a message)
    }
  }

  // Delete a product by ID from the API
  Future<void> _deleteProduct(int id) async {
    final response =
        await http.delete(Uri.parse('${AppConfig.baseUrl}/api/products/$id'));
    if (response.statusCode == 200) {
      setState(() {
        // Remove deleted product locally and deselect it
        _products.removeWhere((product) => product.id == id);
        _selectedProductIds.remove(id);
      });
    } else {
      // TODO: Handle error deleting product
    }
  }

  // Delete all selected products after confirmation dialog
  Future<void> _deleteSelectedProducts() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected Products'),
        content: Text('Are you sure you want to delete the selected products?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      ),
    );

    if (confirm == true) {
      // Delete products one by one
      for (var id in _selectedProductIds) {
        await _deleteProduct(id);
      }
    }
  }

  // Edit product if exactly one product is selected
  void _editSelectedProduct() {
    if (_selectedProductIds.length == 1) {
      final productId = _selectedProductIds.first;
      final product = _products.firstWhere((p) => p.id == productId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProductScreen(product: product),
        ),
      ).then((_) => _fetchProducts()); // Refresh products after editing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Products'), // Screen title
        actions: [
          // Show delete icon if any product is selected
          if (_selectedProductIds.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedProducts,
            ),
          // Show edit icon if exactly one product is selected
          if (_selectedProductIds.length == 1)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _editSelectedProduct,
            ),
        ],
      ),
      // ListView to display products
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final isSelected = _selectedProductIds.contains(product.id);
          return ListTile(
            // Long press triggers delete confirmation for this product
            onLongPress: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Product'),
                  content:
                      Text('Are you sure you want to delete "${product.name}"?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('No')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Yes')),
                  ],
                ),
              );
              if (confirm == true) {
                await _deleteProduct(product.id);
              }
            },
            // Checkbox to select/unselect product for bulk actions
            leading: Checkbox(
              value: isSelected,
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _selectedProductIds.add(product.id);
                  } else {
                    _selectedProductIds.remove(product.id);
                  }
                });
              },
            ),
            title: Text(product.name), // Product name
            subtitle: Text(product.description), // Product description
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit screen on edit button tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductScreen(product: product),
                  ),
                ).then((_) => _fetchProducts()); // Refresh after editing
              },
            ),
          );
        },
      ),
    );
  }
}
