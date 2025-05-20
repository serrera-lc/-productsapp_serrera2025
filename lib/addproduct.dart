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

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductScreenState createState() => _AddProductScreenState();
}

class AddProductService {
  static Future<bool> addProduct({
    required String name,
    required String description,
    required String price,
    required int categoryId,
    required int userId,
    File? image, // 👈 optional image file
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/products');
    var request = http.MultipartRequest('POST', url);
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price;
    request.fields['category_id'] = categoryId.toString();
    request.fields['user_id'] = userId.toString();

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
    }

    final response = await request.send();
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
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List<Map<String, dynamic>> categories = [];
  bool isLoadingCategories = true;

  int mapCategoryToId(String categoryName) {
    switch (categoryName) {
      case "Mobile and Gadgets":
        return 1;
      case "Wearables":
        return 2;
      case "Accessories":
        return 3;
      default:
        return 1; // Default fallback
    }
  }

  File? _image;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

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
  Widget build(BuildContext context) {
    final isFilipino = Provider.of<LanguageModel>(context).isFilipino();
    final backgroundModel = Provider.of<Backgroundmodel>(context);

    return Scaffold(
      backgroundColor: Colors.white, // Always white
      appBar: AppBar(
        backgroundColor: backgroundModel.appBar,
        title: Text(
          isFilipino ? "Magdagdag ng Bagong Produkto" : 'Add New Product',
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFilipino
                  ? "Magdagdag ng mga larawan ng produkto"
                  : "Add product images",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              isFilipino
                  ? "Magdagdag ng hanggang 5 larawan. Ang unang larawan ang ipapakita."
                  : "Add up to 5 images. First image will be highlighted.",
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
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
                  : Image.file(_image!,
                      height: 80, width: 80, fit: BoxFit.cover),
            ),
            SizedBox(height: 20),
            Text(
              isFilipino ? "Mga detalye ng produkto" : "Product details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
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
            TextField(
              controller: productNameController,
              decoration: InputDecoration(
                labelText: isFilipino ? "Pangalan ng produkto" : "Product name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: productDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: isFilipino
                    ? "Deskripsyon ng produkto"
                    : "Product description",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isFilipino ? "Presyo" : "Price",
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundModel.secondBtn,
                      foregroundColor:
                          Colors.white, // explicitly set text color
                    ),
                    child: Text(isFilipino ? "Kanselahin" : "Cancel"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (productNameController.text.isEmpty ||
                          productDescriptionController.text.isEmpty ||
                          priceController.text.isEmpty ||
                          selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(isFilipino
                                  ? "Pakitapos ang lahat ng fields."
                                  : "Please complete all fields.")),
                        );
                        return;
                      }
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt('user_id');
                      if (userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("User not logged in.")),
                        );
                        return;
                      }

                      try {
                        await AddProductService.addProduct(
                          name: productNameController.text,
                          description: productDescriptionController.text,
                          price: priceController.text,
                          categoryId: int.parse(selectedCategory!),
                          userId: userId,
                          image: _image, //  pass to service
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(isFilipino
                                  ? "Matagumpay na naidagdag ang produkto!"
                                  : "Product added successfully!")),
                        );

                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(isFilipino
                                  ? "Nabigo ang pagdaragdag ng produkto."
                                  : "Failed to add product.")),
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
