import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'models/language_model.dart';
import 'models/background_model.dart';
import 'package:provider/provider.dart';
import 'btn_productinfo.dart';
import 'config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'category_products_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? categoryName;
  List<Map<String, dynamic>> relevantProducts = [];
  bool loadingRelevant = true;

  @override
  void initState() {
    super.initState();
    fetchCategoryAndRelevant();
  }

  Future<void> fetchCategoryAndRelevant() async {
    final catId = widget.product['category_id'];
    if (catId != null) {
      // Fetch category name
      final catRes =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/categories'));
      if (catRes.statusCode == 200) {
        final cats = jsonDecode(catRes.body) as List;
        final cat = cats.firstWhere(
            (c) => c['id'].toString() == catId.toString(),
            orElse: () => null);
        setState(() {
          categoryName = cat != null ? cat['name'] : null;
        });
      }
      // Fetch relevant products
      final relRes = await http.get(Uri.parse(
          '${AppConfig.baseUrl}/api/categories/$catId/products?all=1'));
      if (relRes.statusCode == 200) {
        final relJson = jsonDecode(relRes.body);
        final List<dynamic> relRaw = relJson['data'] ?? relJson;
        setState(() {
          relevantProducts = List<Map<String, dynamic>>.from(relRaw)
              .where((p) => p['id'] != widget.product['id'])
              .toList();
          loadingRelevant = false;
        });
      } else {
        setState(() {
          loadingRelevant = false;
        });
      }
    } else {
      setState(() {
        loadingRelevant = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFilipino = Provider.of<LanguageModel>(context).isFilipino();
    final backgroundModel = Provider.of<Backgroundmodel>(context);
    String imagePath;
    if (widget.product["image_path"] != null) {
      imagePath =
          '${AppConfig.baseUrl}/storage/${widget.product["image_path"]}';
    } else if (widget.product["image"] != null) {
      imagePath = widget.product["image"].toString();
    } else {
      imagePath = 'https://via.placeholder.com/130';
    }
    Widget imageWidget = Image.network(
      imagePath,
      height: 350,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey,
        child: Icon(Icons.broken_image, size: 50),
      ),
    );
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: backgroundModel.appBar,
          elevation: 0,
          title: Text(isFilipino ? "Pangalan ng produkto" : "Product Name",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Icon(Icons.chat_bubble_outline, color: Colors.black),
            SizedBox(width: 15),
            Icon(Icons.shopping_cart_outlined, color: Colors.black),
            SizedBox(width: 15),
            CircleAvatar(
              backgroundImage: AssetImage("assets/profile.jpg"),
              radius: 15,
            ),
            SizedBox(width: 15),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageWidget,
              SizedBox(height: 10),
              Text(widget.product["name"].toString(),
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      widget.product["price"] != null
                          ? widget.product["price"].toString()
                          : '',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 18),
                      Text(" 4.5 "),
                      Text(isFilipino ? "(99 pagsusuri)" : "(99 reviews)",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(isFilipino ? "Paglalarawan" : "Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 5),
              Text(
                  widget.product["description"] != null
                      ? widget.product["description"].toString()
                      : '',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.grey)),
              SizedBox(height: 15),
              Text(isFilipino ? "Kategorya" : "Category",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 5),
              categoryName != null
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryProductsScreen(
                              initialCategoryId: widget.product['category_id'],
                              initialCategoryName: categoryName!,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        categoryName!,
                        style: TextStyle(
                          color: const Color.fromRGBO(0, 150, 136, 1),
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox(height: 16, child: LinearProgressIndicator()),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isFilipino ? "Mga Komento" : "Reviews",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(isFilipino ? "Ipakita lahal >" : "See all >",
                      style: TextStyle(color: Colors.blue, fontSize: 14)),
                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("4.5/5",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(isFilipino ? "(99 pagsusuri)" : "(99 reviews)",
                        style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 5),
                    Row(
                      children: List.generate(
                          5,
                          (index) => Icon(
                              index < 4 ? Icons.star : Icons.star_half,
                              color: const Color.fromRGBO(255, 152, 0, 1))),
                    ),
                    SizedBox(height: 10),
                    ...List.generate(5, (index) {
                      return Row(
                        children: [
                          Text("${5 - index}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(width: 5),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (80 - (index * 20)) / 100,
                              backgroundColor: Colors.grey[300],
                              color: backgroundModel.ratingColor,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text("${(80 - (index * 20)) ~/ 20}",
                              style: TextStyle(color: Colors.grey))
                        ],
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  CircleAvatar(backgroundImage: AssetImage("assets/user1.jpg")),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Jerome M.",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Ang ganda!",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(backgroundImage: AssetImage("assets/user2.jpg")),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nica A.",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Wow",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      isFilipino
                          ? "Mga kaugnay na produkto"
                          : "Relevant products",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(isFilipino ? "Ipakita lahal" : "See all >",
                      style: TextStyle(color: Colors.blue, fontSize: 14)),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 240,
                child: loadingRelevant
                    ? Center(child: CircularProgressIndicator())
                    : relevantProducts.isEmpty
                        ? Center(
                            child: Text(isFilipino
                                ? "Walang kaugnay na produkto"
                                : "No relevant products"))
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: relevantProducts.length,
                            separatorBuilder: (_, __) => SizedBox(width: 10),
                            itemBuilder: (context, idx) {
                              final prod = relevantProducts[idx];
                              final hasImage = prod['image_path'] != null &&
                                  prod['image_path'].toString().isNotEmpty;
                              final img = hasImage
                                  ? Image.network(
                                      '${AppConfig.baseUrl}/storage/${prod['image_path']}',
                                      height: 180,
                                      width: 140,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Image.asset(
                                              'assets/product_placeholder.png',
                                              height: 180,
                                              width: 140,
                                              fit: BoxFit.cover),
                                    )
                                  : Image.asset(
                                      'assets/product_placeholder.png',
                                      height: 180,
                                      width: 140,
                                      fit: BoxFit.cover);
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ProductDetailsScreen(product: prod),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 150,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: img,
                                      ),
                                      SizedBox(height: 8),
                                      Text(prod['name'] ?? '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Text(
                                        prod['price'] != null
                                            ? '₱${prod['price']}'
                                            : '',
                                        style: TextStyle(
                                            color: Colors.teal,
                                            fontWeight: FontWeight.bold),
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
        ),
        //product info buttons
        bottomNavigationBar: BottomActionButtons());
  }
}
