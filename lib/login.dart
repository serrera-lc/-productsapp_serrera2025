import 'package:flutter/material.dart';
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
  // Controls whether the password field shows the text or hides it
  bool _obscurePassword = true;

  // Text controllers for username and password input fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Test connection to the backend server on widget initialization
    _testConnection();
  }

  // Test connection method to check server availability
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
    // Access language preference (Filipino or English) from provider
    final isFilipino = Provider.of<LanguageModel>(context).isFilipino();
    // Access background color scheme from provider
    final backgroundModel = Provider.of<Backgroundmodel>(context);

    return Scaffold(
      backgroundColor: backgroundModel.accent, // Set background color
      body: Center(
        child: SingleChildScrollView( // Makes content scrollable on small screens
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white, // White card background
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting text
                      Text(
                        "Hello.",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      // Welcome message based on selected language
                      Text(
                        isFilipino ? "Maligayang pagdating" : "Welcome back",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Username label
                      Text(
                        "User name",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),

                      // Username input field
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: isFilipino
                              ? "Ilagay ang User name"
                              : "Enter User name",
                          prefixIcon: Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.grey[200], // Light background fill
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none, // No border lines
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Password label
                      Text(
                        "Password",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),

                      // Password input field with toggle visibility
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword, // Hide or show password
                        decoration: InputDecoration(
                          hintText: isFilipino
                              ? "Ilagay ang Password"
                              : "Enter Password",
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              // Toggle password visibility state
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),

                      // "Forgot password" link aligned to right
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password functionality
                          },
                          child: Text(
                            isFilipino
                                ? "Nakalimutan ang password?"
                                : "Forgot password?",
                            style: TextStyle(color: Colors.teal),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Login button
                      SizedBox(
                        width: double.infinity, // Full width button
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: backgroundModel.button,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            // Validate empty fields before submitting
                            if (_usernameController.text.isEmpty ||
                                _passwordController.text.isEmpty) {
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
                              // POST request to login API endpoint
                              final response = await http.post(
                                Uri.parse('${AppConfig.baseUrl}/api/auth/login'),
                                headers: {
                                  'Content-Type': 'application/json; charset=UTF-8',
                                },
                                body: jsonEncode({
                                  'username': _usernameController.text,
                                  'password': _passwordController.text,
                                }),
                              );

                              if (response.statusCode == 200) {
                                // Parse response JSON
                                final responseData = jsonDecode(response.body);
                                final userId = responseData['user']['id'];
                                final username = responseData['user']['username'];
                                final email = responseData['user']['email'];

                                // Save user info locally using shared preferences
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setInt('user_id', userId);
                                await prefs.setString('user_name', username ?? 'User Name');
                                await prefs.setString('user_email', email ?? 'user@example.com');

                                if (!mounted) return;

                                // Navigate to HomeScreen after successful login
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen()),
                                );
                              } else {
                                // Show error if login credentials are invalid
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isFilipino
                                        ? "Maling kredensyal."
                                        : "Invalid credentials."),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Show error if connection fails
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isFilipino
                                      ? "May problema sa koneksyon."
                                      : "Connection error."),
                                ),
                              );
                            }
                          },
                          child: Text(
                            isFilipino ? "Mag-sign In" : "Sign In",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Sign up prompt for users without account
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement sign up navigation
                          },
                          child: RichText(
                            text: TextSpan(
                              text: isFilipino
                                  ? "Walang account?"
                                  : "Don't have an account? ",
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: isFilipino ? "Mag-sign up" : "Sign up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
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
}
