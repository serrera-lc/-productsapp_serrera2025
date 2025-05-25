import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'models/Products.dart';
import 'category_service.dart';
import 'config.dart';

// Screen widget to edit an existing product
class EditProductScreen extends StatefulWidget {
  final Product product; // The product to edit

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // Controllers for text input fields, initialized with product data
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  String? _selectedCategoryId; // Currently selected category ID as String
  List<Map<String, dynamic>> _categories = []; // List of available categories
  bool _isLoadingCategories = true; // Flag to show loading state for categories

  File? _pickedImage; // The new image picked by the user (if any)
  String? _currentImagePath; // Existing image path from the product
  bool _isPickingImage = false; // Flag to prevent multiple image pick requests

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the existing product data
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());

    // Store the existing product image path
    _currentImagePath = widget.product.imagePath ?? '';

    // Load category options from the API
    _loadCategories();
  }

  // Fetch categories asynchronously using the CategoryService
  void _loadCategories() async {
    try {
      _categories = await CategoryService.getCategories();
      // Set the initially selected category based on the product's category
      _selectedCategoryId = widget.product.categoryId.toString();
    } catch (e) {
      // Error handling can be added here if needed
    } finally {
      // Update UI to hide loading spinner for categories
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  // Open image picker to select a new product image from gallery
  Future<void> _pickImage() async {
    if (_isPickingImage) return; // Prevent multiple taps

    setState(() {
      _isPickingImage = true;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Update the picked image file and UI
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  // Send updated product data to the backend API
  Future<void> _updateProduct() async {
    if (_pickedImage != null) {
      // If a new image was picked, send a multipart/form-data request

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${AppConfig.baseUrl}/api/products/${widget.product.id}?_method=PUT'),
      );

      // Add form fields to the request
      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['price'] = _priceController.text;
      request.fields['category_id'] = _selectedCategoryId!;

      // Attach the picked image file
      request.files
          .add(await http.MultipartFile.fromPath('image', _pickedImage!.path));

      // Send the request and wait for the response
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // On success, pop the screen to go back
      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        // Handle error response if needed
      }
    } else {
      // If no new image, send JSON PUT request with updated data only

      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/api/products/${widget.product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'price': double.parse(_priceController.text),
          'category_id': int.parse(_selectedCategoryId!),
        }),
      );

      // On success, pop the screen
      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        // Handle error response if needed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image display & picker: shows picked image or existing image or placeholder
            GestureDetector(
              onTap: _pickImage,
              child: _pickedImage != null
                  ? Image.file(_pickedImage!,
                      height: 120, width: 120, fit: BoxFit.cover)
                  : (_currentImagePath != null && _currentImagePath!.isNotEmpty)
                      ? Image.network(
                          'http://192.168.145.203:8000/storage/$_currentImagePath',
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover)
                      : Image.asset('assets/product_placeholder.png',
                          height: 120, width: 120, fit: BoxFit.cover),
            ),

            // Button to change image explicitly
            TextButton(
              onPressed: _pickImage,
              child: Text('Change Image'),
            ),

            // Text input fields for product name, description, and price
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name')),
            TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description')),
            TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number),

            SizedBox(height: 10),

            // Dropdown for selecting product category, shows loading spinner while fetching categories
            _isLoadingCategories
                ? CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategoryId,
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'].toString(),
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),

            SizedBox(height: 20),

            // Button to submit and update the product
            ElevatedButton(
              onPressed: _updateProduct,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
