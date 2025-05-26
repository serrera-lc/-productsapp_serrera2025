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
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
    } catch (e) {
      debugPrint('Connection failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFilipino = Provider.of<LanguageModel>(context).isFilipino();
    final backgroundModel = Provider.of<Backgroundmodel>(context);

    return Scaffold(
      backgroundColor: backgroundModel.accent,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // App Logo / Avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 48, color: backgroundModel.button),
                ),
                const SizedBox(height: 20),

                // Card container
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFilipino ? "Maligayang pagdating" : "Welcome Back",
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: backgroundModel.button,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isFilipino
                            ? "Pakituloy ang pag-login"
                            : "Please sign in to continue",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 24),

                      // Username
                      _label("Username", isFilipino),
                      _inputField(
                        controller: _usernameController,
                        hint: isFilipino ? "Ilagay ang User name" : "Enter Username",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      _label("Password", isFilipino),
                      _inputField(
                        controller: _passwordController,
                        hint: isFilipino ? "Ilagay ang Password" : "Enter Password",
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
                            style: TextStyle(color: backgroundModel.button),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Gradient Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: backgroundModel.button,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _handleLogin,
                          child: Text(
                            isFilipino ? "Mag-sign In" : "Sign In",
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: RichText(
                            text: TextSpan(
                              text: isFilipino
                                  ? "Walang account? "
                                  : "Don't have an account? ",
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: isFilipino ? "Mag-sign up" : "Sign up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: backgroundModel.button,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Label Widget
  Widget _label(String label, bool isFilipino) {
    return Text(
      isFilipino && label == "User name"
          ? "Pangalan ng User"
          : isFilipino && label == "Password"
              ? "Lihim na salita"
              : label,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
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
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[700]),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Login Handler
  void _handleLogin() async {
    final isFilipino = Provider.of<LanguageModel>(context, listen: false).isFilipino();

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
            content: Text(isFilipino
                ? "Maling kredensyal."
                : "Invalid credentials."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFilipino
              ? "May problema sa koneksyon."
              : "Connection error."),
        ),
      );
    }
  }
}
