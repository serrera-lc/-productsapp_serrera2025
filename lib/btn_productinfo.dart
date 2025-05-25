import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/language_model.dart';
import 'models/background_model.dart';

// A stateless widget that displays two bottom action buttons: Add to Cart and Buy Now
class BottomActionButtons extends StatelessWidget {
  const BottomActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current language preference (Filipino or not)
    final isFilipino = Provider.of<LanguageModel>(context).isFilipino();
    // Get the background theme/colors from the provider
    final backgroundModel = Provider.of<Backgroundmodel>(context);

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white, // Fixed white background for the button container
      child: Row(
        children: [
          // First button: Add to Cart
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.shopping_cart, color: Colors.white), // Cart icon
              label: Text(
                isFilipino ? "Idagdag sa Cart" : "Add to Cart", // Language toggle
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // TODO: Add functionality for adding to cart
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundModel.cartBtn, // Themed cart button color
                padding: EdgeInsets.symmetric(vertical: 15),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
              ),
            ),
          ),
          SizedBox(width: 12), // Spacing between the two buttons

          // Second button: Buy Now
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.payment, color: Colors.white), // Payment icon
              label: Text(
                isFilipino ? "Bumili Na" : "Buy Now", // Language toggle
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                // TODO: Add functionality for buy now
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundModel.buyBtn, // Themed buy button color
                padding: EdgeInsets.symmetric(vertical: 15),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
