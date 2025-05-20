import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/Products.dart';
import 'editproduct_screen.dart';
import 'config.dart';

class MyProductsScreen extends StatefulWidget {
  final int userId;

  const MyProductsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Product> _products = [];
  Set<int> _selectedProductIds = {};

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await http
        .get(Uri.parse('${AppConfig.baseUrl}/api/products/${widget.userId}'));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      // If the response is a single product, wrap it in a list
      final List<dynamic> data =
          body is Map && body['data'] != null ? body['data'] : [body];
      setState(() {
        _products = data.map((item) => Product.fromJson(item)).toList();
      });
    } else {
      // Handle error
    }
  }

  Future<void> _deleteProduct(int id) async {
    final response =
        await http.delete(Uri.parse('${AppConfig.baseUrl}/api/products/$id'));
    if (response.statusCode == 200) {
      setState(() {
        _products.removeWhere((product) => product.id == id);
        _selectedProductIds.remove(id);
      });
    } else {
      // Handle error
    }
  }

  Future<void> _deleteSelectedProducts() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Selected Products'),
        content: Text('Are you sure you want to delete the selected products?'),
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
      for (var id in _selectedProductIds) {
        await _deleteProduct(id);
      }
    }
  }

  void _editSelectedProduct() {
    if (_selectedProductIds.length == 1) {
      final productId = _selectedProductIds.first;
      final product = _products.firstWhere((p) => p.id == productId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProductScreen(product: product),
        ),
      ).then((_) => _fetchProducts());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Products'),
        actions: [
          if (_selectedProductIds.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedProducts,
            ),
          if (_selectedProductIds.length == 1)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _editSelectedProduct,
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final isSelected = _selectedProductIds.contains(product.id);
          return ListTile(
            onLongPress: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Product'),
                  content: Text(
                      'Are you sure you want to delete "${product.name}"?'),
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
            title: Text(product.name),
            subtitle: Text(product.description),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductScreen(product: product),
                  ),
                ).then((_) => _fetchProducts());
              },
            ),
          );
        },
      ),
    );
  }
}
