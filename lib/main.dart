import 'package:flutter/material.dart';
// import 'homescreen.dart';
import 'productinfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:ProductDetailsScreen (), // Ensure this is your main screen
    );
  }
}

// ProductDetailsScreen and other classes...