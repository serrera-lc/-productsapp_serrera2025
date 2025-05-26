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
        List<Map<String, dynamic>> fetched =
            List<Map<String, dynamic>>.from(jsonData['data'] ?? jsonData);
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
      userName = prefs.getString('user_name') ?? 'UserName';
      userEmail = prefs.getString('user_email') ?? 'user@example.com';
    });
  }

  Widget productList(List<Map<String, dynamic>> items, {Set<int>? excludeIds}) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final product = items[index];
          if (excludeIds != null && excludeIds.contains(product['id']))
            return SizedBox.shrink();

          final imagePath = product['image_path'] != null &&
                  product['image_path'].toString().isNotEmpty
              ? '${AppConfig.baseUrl}/storage/${product['image_path']}'
              : 'assets/product_placeholder.png';

          return Padding(
            padding: EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: product)),
              ),
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        imagePath,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/product_placeholder.png',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product['name']?.toString() ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        product['description']?.toString() ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '₱${product['price']?.toString() ?? ''}',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
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

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: recs.length,
      itemBuilder: (context, index) => _buildRecommendedCard(recs, index),
    );
  }

  Widget _buildRecommendedCard(List<Map<String, dynamic>> recs, int idx) {
    if (idx >= recs.length) return SizedBox.shrink();

    final product = recs[idx];
    final imagePath = product['image_path'] != null &&
            product['image_path'].toString().isNotEmpty
        ? '${AppConfig.baseUrl}/storage/${product['image_path']}'
        : 'assets/product_placeholder.png';

    return GestureDetector(
      onTap: () => _navigateToProductInfo(recs, idx),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(2, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imagePath,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/product_placeholder.png',
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                product['name']?.toString() ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                product['description']?.toString() ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '₱${product['price']?.toString() ?? ''}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProductInfo(List<Map<String, dynamic>> list, int idx) {
    if (idx >= list.length) return;
    final product = list[idx];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
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
        sectionTitle('🔥 Hot Deals'),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          padding: EdgeInsets.all(12),
          child: recommendedGrid(recs),
        ),
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
      backgroundColor: Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: backgroundModel.appBar,
        elevation: 0,
        title: Text(isFilipino ? "Maligayang pagdating" : "Welcome",
            style: TextStyle(color: Colors.black)),
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
                  Text(
                      userName ??
                          (isFilipino ? "Pangalan ng User" : "User Name"),
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text(userEmail ?? "user@example.com",
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text(isFilipino ? "Home" : "Home"),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(isFilipino
                            ? "Walang naka-log in na user."
                            : "No user logged in.")),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(isFilipino ? "Mga Setting" : 'Settings'),
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
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset("assets/banner.jpg",
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover),
                    ),
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
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        SizedBox(height: 6),
        Container(
          height: 3,
          width: 30,
          decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              borderRadius: BorderRadius.circular(2)),
        ),
        SizedBox(height: 14),
      ],
    );
  }

  Widget sectionTitleWithAction(String title, String actionText,
      {VoidCallback? onActionTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                actionText,
                style: TextStyle(
                    color: Colors.deepOrangeAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryGrid() {
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
          childAspectRatio: 1.4,
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
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imagePath,
                        height: 160,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset('assets/product_placeholder.png',
                                height: 60, width: 90, fit: BoxFit.cover),
                      ),
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
