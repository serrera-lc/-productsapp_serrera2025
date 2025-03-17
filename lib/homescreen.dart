import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 2,
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
              _horizontalList([ProductItem(), ProductItem(), ProductItem()]),
              _sectionTitle("Best Seller", showSeeAll: true),
              _horizontalList([ProductItem(), ProductItem(), ProductItem()]),
              _sectionTitle("Categories"),
              _categoryGrid(),
              _sectionTitle("Recommended for you"),
              _recommendedGrid(),
            ],
          ),
        ),
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

  Widget _horizontalList(List<Widget> items) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemBuilder: (_, index) => items[index],
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

  Widget _recommendedGrid() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: RecommendedProductItem(imagePath: "assets/laptop.jpg", price: "₱1,000")),
            SizedBox(width: 10),
            Expanded(child: RecommendedProductItem(imagePath: "assets/ssd.jpg", price: "₱1,699")),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: RecommendedProductItem(imagePath: "assets/camera.jpg", price: "₱1,000")),
            SizedBox(width: 10),
            Expanded(child: RecommendedProductItem(imagePath: "assets/laptop2.jpg", price: "₱1,000")),
          ],
        ),
      ],
    );
  }
}

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-details');
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
              child: Image.asset("assets/product.jpg",
                  height: 100, width: 140, fit: BoxFit.cover),
            ),
            SizedBox(height: 5),
            Text("Product title", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [Icon(Icons.star, color: Colors.orange, size: 16), Text(" 4.5")]),
            Text("₱99", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
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

class RecommendedProductItem extends StatelessWidget {
  final String imagePath;
  final String price;

  const RecommendedProductItem({super.key, required this.imagePath, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(imagePath, height: 100, width: double.infinity, fit: BoxFit.cover),
          ),
          Text(price, style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
          Text("500 sold", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
