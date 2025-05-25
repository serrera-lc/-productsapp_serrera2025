import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login.dart'; // Import login screen
import 'models/background_model.dart'; // Import background color provider
import 'models/language_model.dart'; // Import language provider

void main() {
  runApp(
    MultiProvider(
      // Register multiple providers for state management
      providers: [
        ChangeNotifierProvider(create: (_) => Backgroundmodel()), // Background color provider
        ChangeNotifierProvider(create: (_) => LanguageModel()), // Language preference provider
      ],
      child: const MyApp(), // Root widget of the app
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to Backgroundmodel changes and rebuild accordingly
    return Consumer<Backgroundmodel>(
      builder: (context, bgModel, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false, // Hide debug banner in app
          home: LoginScreen(), // Set initial screen to LoginScreen
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white, // Set scaffold background to white
            appBarTheme: AppBarTheme(
              backgroundColor: bgModel.appBar, // Dynamic app bar background color
              foregroundColor: Colors.white, // App bar text/icon color
            ),
            // Define color scheme with accent color from background model
            colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: bgModel.accent, // Accent color (e.g., buttons, highlights)
            ),
          ),
        );
      },
    );
  }
}
