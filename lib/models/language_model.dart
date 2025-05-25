import 'package:flutter/material.dart';

/// LanguageModel manages the app's current language setting.
/// It notifies listeners when the language changes, allowing
/// UI elements to respond accordingly (e.g., for localization).
class LanguageModel extends ChangeNotifier {
  // --- Current selected language (default is English) ---
  String _language = "English";

  /// Getter for the current language
  String get language => _language;

  /// Sets the language and notifies listeners to update UI
  void setLanguage(String lang) {
    _language = lang;
    notifyListeners(); // Triggers rebuilds for widgets listening to this model
  }

  /// Helper method to check if the current language is Filipino
  bool isFilipino() => _language == "Filipino";
}
