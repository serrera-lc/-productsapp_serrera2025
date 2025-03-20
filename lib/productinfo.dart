import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productTitle;
  final String productImage;
  final String productPrice;
  final String productDescription; // New parameter for description

  const ProductDetailsScreen({
    super.key,
    required this.productTitle,
    required this.productImage,
    required this.productPrice,
    required this.productDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        elevation: 0,
        title: Text(productTitle,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(productImage, height: 200, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(productTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(productPrice, style: TextStyle(fontSize: 18, color: Colors.deepOrange)),
            SizedBox(height: 10),
            Text(
              productDescription, // Displaying the actual description
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
