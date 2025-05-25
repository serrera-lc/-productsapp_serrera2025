import 'package:flutter/material.dart';

/// Backgroundmodel handles app-wide theme customization using a
/// neon orange, neon blue, black, and grey color palette.
///
/// Use `Provider.of<Backgroundmodel>(context)` to access theme values.
class Backgroundmodel extends ChangeNotifier {
  // --- Current Theme Identifier ---
  String _currentTheme = "neon_dark";

  // --- Theme Color Variables (Default: Neon Dark Theme) ---
  Color _scaffoldBgColor = const Color(0xFF0D1B2A); // App background
  Color _appBarColor = Colors.black;                // AppBar background
  Color _drawerHeaderColor = const Color(0xFF1B263B); // Drawer header
  Color _buttonColor = const Color(0xFFFF5E00);     // Primary button color
  Color _accentColor = const Color(0xFFFF5E00);     // Accent/highlight color
  Color _textColor = Colors.white;                  // Default text color
  Color _secondBtn = const Color(0xFF7E7E7E);       // Secondary button color
  Color _buyBtn = const Color(0xFFFF8C00);          // Buy button color
  Color _cartBtn = const Color(0xFF1B263B);         // Cart button color
  Color _ratingColor = const Color(0xFFFFC107);     // Star rating color

  // --- Getters for UI Access ---
  Color get background => _scaffoldBgColor;
  Color get appBar => _appBarColor;
  Color get drawerHeader => _drawerHeaderColor;
  Color get button => _buttonColor;
  Color get accent => _accentColor;
  Color get textColor => _textColor;
  Color get secondBtn => _secondBtn;
  Color get buyBtn => _buyBtn;
  Color get cartBtn => _cartBtn;
  Color get ratingColor => _ratingColor;
  String get theme => _currentTheme;

  /// Set theme by name and update color values accordingly.
  void setTheme(String themeName) {
    _currentTheme = themeName;

    switch (themeName) {
      case 'neon_orange':
        _scaffoldBgColor = Colors.black;
        _appBarColor = const Color(0xFFFF5E00);
        _drawerHeaderColor = const Color(0xFF1B263B);
        _buttonColor = const Color(0xFFFF5E00);
        _accentColor = const Color(0xFFFF5E00);
        _textColor = Colors.white;
        _secondBtn = const Color(0xFF7E7E7E);
        _buyBtn = const Color(0xFFFF8C00);
        _cartBtn = const Color(0xFF1B263B);
        _ratingColor = const Color(0xFFFFC107);
        break;

      case 'neon_blue':
        _scaffoldBgColor = const Color(0xFF0D1B2A);
        _appBarColor = const Color(0xFF1B263B);
        _drawerHeaderColor = const Color(0xFF415A77);
        _buttonColor = const Color(0xFF00BFFF);
        _accentColor = const Color(0xFF00BFFF);
        _textColor = Colors.white;
        _secondBtn = const Color(0xFF7E7E7E);
        _buyBtn = const Color(0xFF0099FF);
        _cartBtn = const Color(0xFF1B263B);
        _ratingColor = const Color(0xFFFFC107);
        break;

      case 'black_theme':
        _scaffoldBgColor = Colors.black;
        _appBarColor = Colors.black;
        _drawerHeaderColor = const Color(0xFF1C1C1C);
        _buttonColor = const Color(0xFF303030);
        _accentColor = const Color(0xFF303030);
        _textColor = Colors.white;
        _secondBtn = Colors.grey;
        _buyBtn = Colors.grey[800]!;
        _cartBtn = const Color(0xFF1C1C1C);
        _ratingColor = const Color(0xFFFFC107);
        break;

      case 'gray_theme':
        _scaffoldBgColor = const Color(0xFFEEEEEE);
        _appBarColor = Colors.grey[800]!;
        _drawerHeaderColor = Colors.grey[400]!;
        _buttonColor = Colors.grey[600]!;
        _accentColor = Colors.grey[600]!;
        _textColor = Colors.black;
        _secondBtn = Colors.grey[700]!;
        _buyBtn = Colors.grey[800]!;
        _cartBtn = Colors.grey[400]!;
        _ratingColor = const Color(0xFFFFC107);
        break;

      default: // Fallback to default neon_dark theme
        _scaffoldBgColor = const Color(0xFF0D1B2A);
        _appBarColor = Colors.black;
        _drawerHeaderColor = const Color(0xFF1B263B);
        _buttonColor = const Color(0xFFFF5E00);
        _accentColor = const Color(0xFFFF5E00);
        _textColor = Colors.white;
        _secondBtn = const Color(0xFF7E7E7E);
        _buyBtn = const Color(0xFFFF8C00);
        _cartBtn = const Color(0xFF1B263B);
        _ratingColor = const Color(0xFFFFC107);
        break;
    }

    // Notify listeners so UI updates automatically
    notifyListeners();
  }

  /// Manually trigger a UI refresh without changing theme
  void refreshTheme() {
    notifyListeners();
  }
}
