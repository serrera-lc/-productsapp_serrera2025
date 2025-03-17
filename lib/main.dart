import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'productinfo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/product-details': (context) => ProductDetailsScreen(),
      },
    );
  }
}
