import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange, // Shopee's primary color
        elevation: 0,
        leading: Icon(Icons.chat, color: Colors.white),
        actions: [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 15),
          CircleAvatar(
            backgroundImage: AssetImage("assets/profile.jpg"), // Profile image
          ),
          SizedBox(width: 15),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // Banner
              Image.asset("assets/banner.jpg",
                  height: 150, width: double.infinity, fit: BoxFit.cover),
              SizedBox(height: 20),

              // Products Section
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Products",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ProductItem(),
                          SizedBox(width: 10),
                          ProductItem(),
                          SizedBox(width: 10),
                          ProductItem(),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Best Seller Section
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Best Seller",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("See all >",
                            style: TextStyle(color: Colors.orange, fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ProductItem(),
                          SizedBox(width: 10),
                          ProductItem(),
                          SizedBox(width: 10),
                          ProductItem(),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Categories Section
              Text("Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CategoryItem(
                          title: "Mobile and Gadgets",
                          imagePath: "assets/mobile.jpg"),
                      CategoryItem(
                          title: "Men's Apparel", imagePath: "assets/men.jpg"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CategoryItem(
                          title: "Women's Apparel",
                          imagePath: "assets/women.jpg"),
                      CategoryItem(
                          title: "Kitchen Appliances",
                          imagePath: "assets/kitchen.jpg"),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Recommended Products Section
              Text("Recommended for you",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RecommendedProductItem(
                            imagePath: "assets/laptop.jpg", price: "₱1,000"),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RecommendedProductItem(
                            imagePath: "assets/ssd.jpg", price: "₱1,699"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RecommendedProductItem(
                            imagePath: "assets/camera.jpg", price: "₱1,000"),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RecommendedProductItem(
                            imagePath: "assets/laptop2.jpg", price: "₱1,000"),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  const ProductItem({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/product.jpg",
              height: 100, width: 120, fit: BoxFit.cover),
          SizedBox(height: 5),
          Text("Product title", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 3),
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange, size: 16),
              Text(" 4.5"),
            ],
          ),
          SizedBox(height: 3),
          Text("\$99",
              style: TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold)), // Updated color
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
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Image.asset(imagePath,
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

  const RecommendedProductItem(
      {super.key, required this.imagePath, required this.price});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath,
              height: 120, width: 200, fit: BoxFit.cover),
          SizedBox(height: 5),
          Text("Product title", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Product description",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 5),
          Text("30% Off",
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)), // Updated color
          SizedBox(height: 5),
          Text(price,
              style: TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold)), // Updated color
          Text("500 sold", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}