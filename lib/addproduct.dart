import 'package:flutter/material.dart';
import 'models/language_model.dart';
import 'models/background_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'category_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'config.dart';

/// Stateful widget for the screen where users can add a new product.
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

/// Service class to handle adding a product via API call.
class AddProductService {
  /// Sends a multipart POST request to add a product to the backend.
  static Future<bool> addProduct({
    required String name,
    required String description,
    required String price,
    required int categoryId,
    required int userId,
    File? image, // Optional image file
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/products');
    var request = http.MultipartRequest('POST', url);

    // Attach product fields
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price;
    request.fields['category_id'] = categoryId.toString();
    request.fields['user_id'] = userId.toString();

    // Attach image if provided
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    // Send request
    final response = await request.send();

    // Check if response is successful
    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to add product');
    }
  }
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? selectedCategory;
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productDescriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;

  File? _image; // Holds the selected product image

  /// Opens image picker to select an image from the gallery
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  /// Load category data from the API
  void loadCategories() async {
    try {
      categories = await CategoryService.getCategories();
    } catch (e) {
      // Handle error if needed
    } finally {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadCategories(); // Load categories on screen load
  }

  @override
  Widget build(BuildContext context) {
    final isFilipino = Provider.of<LanguageModel>(context).isFilipino(); // For language switching
    final backgroundModel = Provider.of<Backgroundmodel>(context); // Theme colors

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: backgroundModel.appBar,
        title: Text(
          isFilipino ? "Magdagdag ng Bagong Produkto" : 'Add New Product',
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back to previous screen
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Text(
              isFilipino ? "Magdagdag ng mga larawan ng produkto" : "Add product images",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              isFilipino
                  ? "Magdagdag ng hanggang 5 larawan. Ang unang larawan ang ipapakita."
                  : "Add up to 5 images. First image will be highlighted.",
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage, // Trigger image picker
              child: _image == null
                  ? Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, size: 40, color: Colors.grey),
                    )
                  : Image.file(_image!, height: 80, width: 80, fit: BoxFit.cover),
            ),
            SizedBox(height: 20),

            // Product detail fields
            Text(
              isFilipino ? "Mga detalye ng produkto" : "Product details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Category dropdown
            isLoadingCategories
                ? CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: isFilipino
                          ? "Pumili ng kategorya ng produkto"
                          : "Select product category",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category['id'].toString(),
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
            SizedBox(height: 10),

            // Product name input
            TextField(
              controller: productNameController,
              decoration: InputDecoration(
                labelText: isFilipino ? "Pangalan ng produkto" : "Product name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Product description input
            TextField(
              controller: productDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: isFilipino ? "Deskripsyon ng produkto" : "Product description",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Price input
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isFilipino ? "Presyo" : "Price",
                border: OutlineInputBorder(),
              ),
            ),

            Spacer(),

            // Action buttons (Cancel & Add Product)
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cancel action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundModel.secondBtn,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isFilipino ? "Kanselahin" : "Cancel"),
                  ),
                ),
                SizedBox(width: 10),

                // Add Product Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate input fields
                      if (productNameController.text.isEmpty ||
                          productDescriptionController.text.isEmpty ||
                          priceController.text.isEmpty ||
                          selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFilipino
                                  ? "Pakitapos ang lahat ng fields."
                                  : "Please complete all fields.",
                            ),
                          ),
                        );
                        return;
                      }

                      // Get user ID from shared preferences
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt('user_id');
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("User not logged in.")),
                        );
                        return;
                      }

                      // Attempt to add the product using the service
                      try {
                        await AddProductService.addProduct(
                          name: productNameController.text,
                          description: productDescriptionController.text,
                          price: priceController.text,
                          categoryId: int.parse(selectedCategory!),
                          userId: userId,
                          image: _image,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFilipino
                                  ? "Matagumpay na naidagdag ang produkto!"
                                  : "Product added successfully!",
                            ),
                          ),
                        );

                        Navigator.pop(context); // Go back after success
                      } catch (e) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFilipino
                                  ? "Nabigo ang pagdaragdag ng produkto."
                                  : "Failed to add product.",
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundModel.button,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isFilipino ? "Idagdag" : "Add product"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
