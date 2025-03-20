import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'productinfo.dart';
import 'login_screen.dart';
import 'product_form.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    routes: {
      '/login': (context) => LoginScreen(),
      '/home': (context) => HomeScreen(),
      '/add-product': (context) => ProductFormScreen(),
    },
  ));
}
