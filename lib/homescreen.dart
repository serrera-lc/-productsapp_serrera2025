import 'package:flutter/material.dart';
import 'productinfo.dart'; // Import ProductDetailsScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> products = [
      {
        "title": "Laptop",
        "image": "assets/laptop.jpg",
        "price": "₱1,000",
        "description": "A high-performance laptop for gaming and work. Features a fast processor and a sleek design."
      },
      {
        "title": "Smartphone",
        "image": "assets/mobile.jpg",
        "price": "₱5,000",
        "description": "A powerful smartphone with a long-lasting battery, high-resolution camera, and fast charging support."
      },
      {
        "title": "Camera",
        "image": "assets/camera.jpg",
        "price": "₱3,500",
        "description": "Capture stunning photos with this high-quality digital camera, perfect for photography enthusiasts."
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 2,
        title: Text(
          "Seanoy", // Custom branding like Shopee
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true, // Centers the title like Shopee
        leading: Icon(Icons.chat, color: Colors.white),
        actions: [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 15),
          CircleAvatar(
            backgroundImage: AssetImage("assets/profile.jpg"),
          ),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset("assets/banner.jpg",
                    height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(height: 20),
              _sectionTitle("Products"),
              _horizontalList(products),
              _sectionTitle("Best Seller", showSeeAll: true),
              _horizontalList(products),
              _sectionTitle("Categories"),
              _categoryGrid(),
              _sectionTitle("Recommended for you"),
              _horizontalList(products),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-product');
        },
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _horizontalList(List<Map<String, String>> products) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (context, index) {
          return ProductItem(
            title: products[index]["title"]!,
            imagePath: products[index]["image"]!,
            price: products[index]["price"]!,
            description: products[index]["description"]!,
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title, {bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (showSeeAll)
            Text("See all >", style: TextStyle(color: Colors.deepOrange, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _categoryGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CategoryItem(title: "Mobile & Gadgets", imagePath: "assets/mobile.jpg"),
            CategoryItem(title: "Men's Apparel", imagePath: "assets/men.jpg"),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CategoryItem(title: "Women's Apparel", imagePath: "assets/women.jpg"),
            CategoryItem(title: "Kitchen Appliances", imagePath: "assets/kitchen.jpg"),
          ],
        ),
      ],
    );
  }
}

class ProductItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final String price;
  final String description;

  const ProductItem({
    super.key,
    required this.title,
    required this.imagePath,
    required this.price,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              productTitle: title,
              productImage: imagePath,
              productPrice: price,
              productDescription: description,
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(imagePath, height: 100, width: 140, fit: BoxFit.cover),
            ),
            SizedBox(height: 5),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(price, style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
          ],
        ),
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
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(imagePath, height: 90, width: 120, fit: BoxFit.cover),
        ),
        SizedBox(height: 5),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
