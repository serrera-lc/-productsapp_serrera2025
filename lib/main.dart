import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login.dart';
import 'models/background_model.dart';
import 'models/language_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Backgroundmodel()),
        ChangeNotifierProvider(create: (_) => LanguageModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Backgroundmodel>(
      builder: (context, bgModel, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LoginScreen(),
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white, // Fixed white background
            appBarTheme: AppBarTheme(
              backgroundColor: bgModel.appBar,
              foregroundColor: Colors.white,
            ),

            colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: bgModel.accent,
            ),
          ),
        );
      },
    );
  }
}
