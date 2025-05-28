import 'package:flutter/material.dart';
import 'models/language_model.dart';
import 'models/background_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'category_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'config.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class AddProductService {
  static Future<bool> addProduct({
    required String name,
    required String description,
    required String price,
    required int categoryId,
    required int userId,
    File? image,
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
  File? _image;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  void loadCategories() async {
    try {
      categories = await CategoryService.getCategories();
    } catch (e) {
    } finally {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final isFilipino = Provider.of<LanguageModel>(context).isFilipino();
    final backgroundModel = Provider.of<Backgroundmodel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: backgroundModel.appBar,
        elevation: 0,
        title: Text(
          isFilipino ? "Magdagdag ng Bagong Produkto" : 'Add New Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Decorative top background
          Positioned(
            top: -size.height * 0.18,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 1.4,
              height: size.height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [backgroundModel.button, backgroundModel.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(200),
                  bottomRight: Radius.circular(200),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: _image == null
                              ? Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color:
                                        backgroundModel.accent.withOpacity(0.1),
                                    border: Border.all(
                                        color: backgroundModel.button,
                                        width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(Icons.add_a_photo,
                                      size: 40, color: backgroundModel.button),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(_image!,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          isFilipino
                              ? "Magdagdag ng larawan ng produkto"
                              : "Add product image",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionLabel(isFilipino
                          ? "Mga detalye ng produkto"
                          : "Product details"),
                      const SizedBox(height: 12),
                      isLoadingCategories
                          ? Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: isFilipino
                                    ? "Pumili ng kategorya ng produkto"
                                    : "Select product category",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
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
                      const SizedBox(height: 14),
                      _inputField(
                        controller: productNameController,
                        label: isFilipino
                            ? "Pangalan ng produkto"
                            : "Product name",
                        icon: Icons.label,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: productDescriptionController,
                        label: isFilipino
                            ? "Deskripsyon ng produkto"
                            : "Product description",
                        icon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: priceController,
                        label: isFilipino ? "Presyo" : "Price",
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: backgroundModel.secondBtn,
                                side: BorderSide(
                                    color: backgroundModel.secondBtn, width: 2),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(isFilipino ? "Kanselahin" : "Cancel"),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
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
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final userId = prefs.getInt('user_id');
                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("User not logged in.")),
                                  );
                                  return;
                                }
                                try {
                                  await AddProductService.addProduct(
                                    name: productNameController.text,
                                    description:
                                        productDescriptionController.text,
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
                                  Navigator.pop(context);
                                } catch (e) {
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
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child:
                                  Text(isFilipino ? "Idagdag" : "Add product"),
                            ),
                          ),
                        ],
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

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
