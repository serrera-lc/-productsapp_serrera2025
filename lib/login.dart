import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'homescreen.dart';
import 'models/language_model.dart';
import 'models/background_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  void _testConnection() async {
    try {
      final response = await http.get(Uri.parse(AppConfig.baseUrl));
      debugPrint('Status: [32m${response.statusCode}[0m');
      debugPrint('Body: ${response.body}');
    } catch (e) {
      debugPrint('Connection failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFilipino = Provider.of<LanguageModel>(context).isFilipino();
    final backgroundModel = Provider.of<Backgroundmodel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundModel.accent,
      body: Stack(
        children: [
          // Top wave
          Positioned(
            top: -size.height * 0.18,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 1.4,
              height: size.height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [backgroundModel.button, backgroundModel.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(200),
                  bottomRight: Radius.circular(200),
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: backgroundModel.button.withOpacity(0.2),
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.shopping_bag,
                            size: 54, color: backgroundModel.button),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Card with glassmorphism effect
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                        border: Border.all(
                            color: backgroundModel.button.withOpacity(0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isFilipino
                                ? "Maligayang Pagbabalik!"
                                : "Welcome Back!",
                            style: GoogleFonts.montserrat(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: backgroundModel.button,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isFilipino
                                ? "Mag-login upang magpatuloy"
                                : "Sign in to continue",
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 15),
                          ),
                          const SizedBox(height: 28),
                          // Username
                          _label(isFilipino ? "Pangalan ng User" : "Username"),
                          _inputField(
                            controller: _usernameController,
                            hint: isFilipino
                                ? "Ilagay ang User name"
                                : "Enter Username",
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 18),
                          // Password
                          _label(isFilipino ? "Lihim na salita" : "Password"),
                          _inputField(
                            controller: _passwordController,
                            hint: isFilipino
                                ? "Ilagay ang Password"
                                : "Enter Password",
                            icon: Icons.lock,
                            obscureText: _obscurePassword,
                            suffix: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                isFilipino
                                    ? "Nakalimutan ang password?"
                                    : "Forgot password?",
                                style: TextStyle(
                                    color: backgroundModel.button,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Gradient Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 4,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: backgroundModel.button,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _handleLogin,
                              child: Text(
                                isFilipino ? "Mag-sign In" : "Sign In",
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isFilipino
                                    ? "Walang account? "
                                    : "Don't have an account? ",
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 15),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  isFilipino ? "Mag-sign up" : "Sign up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: backgroundModel.button,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Label Widget
  Widget _label(String label) {
    return Text(
      label,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  // Input Field Widget
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Widget? suffix,
    bool obscureText = false,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // Login Handler
  void _handleLogin() async {
    final isFilipino =
        Provider.of<LanguageModel>(context, listen: false).isFilipino();

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFilipino
              ? "Pakitapos ang lahat ng fields."
              : "Please complete all fields."),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', data['user']['id']);
        await prefs.setString('user_name', data['user']['username']);
        await prefs.setString('user_email', data['user']['email']);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                isFilipino ? "Maling kredensyal." : "Invalid credentials."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isFilipino ? "May problema sa koneksyon." : "Connection error."),
        ),
      );
    }
  }
}
