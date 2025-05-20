import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'addproduct.dart';
import 'models/background_model.dart';
import 'models/language_model.dart';
import 'login.dart';
import 'myproduct_screen.dart';
import 'productinfo.dart';
import 'settings.dart';
import 'package:provider/provider.dart';
import 'config.dart';
import 'category_products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadCategories();
    loadUserInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showWelcomeDialog();
    });
  }

  void showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Welcome!"),
        content: Text("You have successfully logged in."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> loadProducts() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/products?all=1'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final raw = jsonData['data'] ?? jsonData;
        List<Map<String, dynamic>> fetched =
            List<Map<String, dynamic>>.from(raw);
        fetched.shuffle(Random());

        setState(() {
          allProducts = fetched;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load products: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> loadCategories() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConfig.baseUrl}/api/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          categories = data
              .map<Map<String, dynamic>>((item) => {
                    'id': item['id'],
                    'name': item['name'],
                    'image_path': item['image_path'],
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User Name';
      userEmail = prefs.getString('user_email') ?? 'user@example.com';
    });
  }

  Widget productList(List<Map<String, dynamic>> items, {Set<int>? excludeIds}) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final product = items[index];
          if (excludeIds != null && excludeIds.contains(product['id'])) {
            return SizedBox.shrink(); // Skip duplicates
          }
          final hasImage = product['image_path'] != null &&
              product['image_path'].toString().isNotEmpty;
          final imageWidget = hasImage &&
                  !product['image_path']
                      .toString()
                      .toLowerCase()
                      .endsWith('.asset')
              ? Image.network(
                  '${AppConfig.baseUrl}/storage/${product['image_path']}',
                  height: 100,
                  width: 130,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/product_placeholder.png',
                      height: 100,
                      width: 130,
                      fit: BoxFit.cover),
                )
              : Image.asset('assets/product_placeholder.png',
                  height: 100, width: 130, fit: BoxFit.cover);
          return Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: product)),
              ),
              child: ProductItem(
                imageWidget: imageWidget,
                name: product['name']?.toString() ?? '',
                description: product['description']?.toString() ?? '',
                price: '₱${product['price']?.toString() ?? ''}',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget recommendedGrid(List<Map<String, dynamic>> items) {
    final random = Random();
    final recommended = List<Map<String, dynamic>>.from(items)..shuffle(random);
    final recs = recommended.take(4).toList();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: GestureDetector(
              onTap: () => _navigateToProductInfo(recs, 0),
              child: RecommendedProductItem(
                  imagePath: getProductImage(recs, 0),
                  price: getProductPrice(recs, 0),
                  name: getProductName(recs, 0),
                  description: getProductDesc(recs, 0)),
            )),
            SizedBox(width: 10),
            Expanded(
                child: GestureDetector(
              onTap: () => _navigateToProductInfo(recs, 1),
              child: RecommendedProductItem(
                  imagePath: getProductImage(recs, 1),
                  price: getProductPrice(recs, 1),
                  name: getProductName(recs, 1),
                  description: getProductDesc(recs, 1)),
            )),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: GestureDetector(
              onTap: () => _navigateToProductInfo(recs, 2),
              child: RecommendedProductItem(
                  imagePath: getProductImage(recs, 2),
                  price: getProductPrice(recs, 2),
                  name: getProductName(recs, 2),
                  description: getProductDesc(recs, 2)),
            )),
            SizedBox(width: 10),
            Expanded(
                child: GestureDetector(
              onTap: () => _navigateToProductInfo(recs, 3),
              child: RecommendedProductItem(
                  imagePath: getProductImage(recs, 3),
                  price: getProductPrice(recs, 3),
                  name: getProductName(recs, 3),
                  description: getProductDesc(recs, 3)),
            )),
          ],
        ),
      ],
    );
  }

  String getProductImage(List<Map<String, dynamic>> list, int idx) {
    if (idx >= list.length) return 'assets/product_placeholder.png';
    final p = list[idx];
    if (p['image_path'] != null && p['image_path'].toString().isNotEmpty) {
      return '${AppConfig.baseUrl}/storage/${p['image_path']}';
    }
    return 'assets/product_placeholder.png';
  }

  String getProductPrice(List<Map<String, dynamic>> list, int idx) {
    if (idx >= list.length) return '';
    return '₱${list[idx]['price']?.toString() ?? ''}';
  }

  String getProductName(List<Map<String, dynamic>> list, int idx) {
    if (idx >= list.length) return '';
    return list[idx]['name']?.toString() ?? '';
  }

  String getProductDesc(List<Map<String, dynamic>> list, int idx) {
    if (idx >= list.length) return '';
    return list[idx]['description']?.toString() ?? '';
  }

  void _navigateToProductInfo(List<Map<String, dynamic>> list, int idx) {
    if (idx >= list.length) return;
    final product = list[idx];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  Widget trendingProductsSection(List<Map<String, dynamic>> items) {
    final random = Random();
    final trending = List<Map<String, dynamic>>.from(items)..shuffle(random);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Trending Products'),
        productList(trending.take(8).toList()),
      ],
    );
  }

  Widget hotDealsSection(List<Map<String, dynamic>> items) {
    final random = Random();
    final hotDeals = List<Map<String, dynamic>>.from(items)..shuffle(random);
    final recs = hotDeals.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Hot Deals'),
        recommendedGrid(recs),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFilipino = Provider.of<LanguageModel>(context).isFilipino();
    final backgroundModel = Provider.of<Backgroundmodel>(context);
    int split = (allProducts.length / 2).ceil();
    final productsSection = allProducts.take(split).toList();
    final bestSellersSection = allProducts.skip(split).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: backgroundModel.appBar,
        elevation: 0,
        actions: [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 15),
          CircleAvatar(backgroundImage: AssetImage("assets/profile.jpg")),
          SizedBox(width: 15),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: backgroundModel.appBar),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                      backgroundImage: AssetImage("assets/profile.jpg"),
                      radius: 30),
                  SizedBox(height: 10),
                  Text(userName ?? "User Name",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text(userEmail ?? "user@example.com",
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.add_box),
              title: Text(isFilipino ? "Magdagdag ng Produkto" : 'Add Product'),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AddProductScreen())),
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text(isFilipino ? "Iyong Mga Produkto" : 'My Products'),
              onTap: () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getInt('user_id');
                if (userId != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MyProductsScreen(userId: userId)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isFilipino
                          ? "Walang naka-log in na user."
                          : "No user logged in.")));
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SettingsScreen())),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(isFilipino ? "Mag-Logout" : 'Logout'),
              onTap: () => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginScreen())),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await loadProducts();
                await loadCategories();
                await loadUserInfo();
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Image.asset("assets/banner.jpg",
                        height: 300, width: double.infinity, fit: BoxFit.cover),
                    SizedBox(height: 20),
                    sectionTitle(isFilipino ? "Mga Produkto" : "Products"),
                    productList(productsSection),
                    sectionTitleWithAction(
                      isFilipino ? "Pinakamabenta" : "Best Seller",
                      isFilipino ? "Ipakita lahat >" : "See all >",
                    ),
                    productList(bestSellersSection),
                    sectionTitle(isFilipino ? "Mga Kategorya" : "Categories"),
                    categoryGrid(),
                    sectionTitle(isFilipino
                        ? "Inirerekomenda para sa iyo"
                        : "Recommended for you"),
                    recommendedGrid(allProducts),
                    trendingProductsSection(allProducts),
                    hotDealsSection(allProducts),
                  ],
                ),
              ),
            ),
    );
  }

  Widget sectionTitle(String title) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
      ],
    );
  }

  Widget sectionTitleWithAction(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(actionText, style: TextStyle(color: Colors.blue, fontSize: 14)),
      ],
    );
  }

  Widget categoryGrid() {
    // Shuffle and take only 4 categories
    final List<Map<String, dynamic>> shuffled =
        List<Map<String, dynamic>>.from(categories)..shuffle();
    final List<Map<String, dynamic>> displayCategories =
        shuffled.take(4).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.4, // slightly wider
        ),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final cat = displayCategories[index];
          String imagePath = cat['image_path'] != null &&
                  cat['image_path'].toString().isNotEmpty
              ? '${AppConfig.baseUrl}/storage/${cat['image_path']}'
              : 'assets/product_placeholder.png';
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryProductsScreen(
                      initialCategoryId: cat['id'],
                      initialCategoryName: cat['name'],
                    ),
                  ),
                );
              }, // You can add navigation or action here
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imagePath.startsWith('http')
                          ? Image.network(
                              imagePath,
                              height: 160,
                              width: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset('assets/product_placeholder.png',
                                      height: 60, width: 90, fit: BoxFit.cover),
                            )
                          : Image.asset(imagePath,
                              height: 60, width: 90, fit: BoxFit.cover),
                    ),
                    SizedBox(height: 8),
                    Text(cat['name'] ?? '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Widget imageWidget;
  final String name;
  final String description;
  final String price;

  const ProductItem({
    super.key,
    required this.imageWidget,
    required this.name,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundModel = Provider.of<Backgroundmodel>(context);
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,
          SizedBox(height: 5),
          Text(name,
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(description,
              style: TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: 3),
          Row(children: [
            Icon(Icons.star, color: Colors.orange, size: 16),
            Text(" 4.5")
          ]),
          SizedBox(height: 3),
          Text(price,
              style: TextStyle(
                  color: backgroundModel.textColor,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;

  const CategoryItem({super.key, required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isNetwork = imagePath.startsWith('http');
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          isNetwork
              ? Image.network(
                  imagePath,
                  height: 100,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/product_placeholder.png',
                      height: 100,
                      width: 200,
                      fit: BoxFit.cover),
                )
              : Image.asset(imagePath,
                  height: 100, width: 200, fit: BoxFit.cover),
          SizedBox(height: 5),
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class RecommendedProductItem extends StatelessWidget {
  final String imagePath;
  final String price;
  final String? name;
  final String? description;

  const RecommendedProductItem({
    super.key,
    required this.imagePath,
    required this.price,
    this.name,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundModel = Provider.of<Backgroundmodel>(context);
    return SizedBox(
      width: 240, // wider
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imagePath.startsWith('http')
              ? Image.network(imagePath,
                  height: 170, // higher
                  width: 240, // wider
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/product_placeholder.png',
                      height: 170,
                      width: 240,
                      fit: BoxFit.cover))
              : Image.asset(imagePath,
                  height: 170, width: 240, fit: BoxFit.cover),
          Text(name ?? "Product title",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(description ?? "Product description",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 5),
          Text("30% Off",
              style: TextStyle(
                  color: const Color.fromRGBO(51, 171, 159, 1),
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(price,
              style: TextStyle(
                  color: backgroundModel.textColor,
                  fontWeight: FontWeight.bold)),
          Text("500 sold", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
