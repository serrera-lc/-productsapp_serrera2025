import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/background_model.dart';
import 'models/language_model.dart';

class SettingsScreen extends StatelessWidget {
  final List<String> languages = ["English", "Filipino"];

  // Theme options
  final Map<String, String> themeOptions = {
    "neon_dark": "Neon Dark",
    "neon_orange": "Neon Orange",
    "neon_blue": "Neon Blue",
    "black_theme": "Black",
    "gray_theme": "Gray",
  };

  @override
  Widget build(BuildContext context) {
    final backgroundModel = Provider.of<Backgroundmodel>(context);
    final languageModel = Provider.of<LanguageModel>(context);
    final isFilipino = languageModel.isFilipino();

    return Scaffold(
      backgroundColor: backgroundModel.background,
      appBar: AppBar(
        backgroundColor: backgroundModel.appBar,
        title: Text(
          isFilipino ? "Mga Setting" : "Settings",
          style: TextStyle(color: backgroundModel.textColor),
        ),
        iconTheme: IconThemeData(color: backgroundModel.textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundModel.drawerHeader,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFilipino ? "Baguhin ang wika" : "Change Language",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: backgroundModel.textColor,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: languageModel.language,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: backgroundModel.accent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                dropdownColor: Colors.white,
                iconEnabledColor: backgroundModel.accent,
                items: languages
                    .map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    languageModel.setLanguage(value);
                  }
                },
              ),
              SizedBox(height: 30),
              Text(
                isFilipino ? "Tema ng App" : "App Theme",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: backgroundModel.textColor,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: backgroundModel.theme,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: backgroundModel.accent),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                dropdownColor: Colors.white,
                iconEnabledColor: backgroundModel.accent,
                items: themeOptions.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    backgroundModel.setTheme(value);
                  }
                },
              ),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: backgroundModel.secondBtn,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isFilipino ? "Kanselahin" : "Cancel"),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: backgroundModel.accent,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isFilipino ? "I-save" : "Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
