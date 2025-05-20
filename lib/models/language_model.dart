import 'package:flutter/material.dart';

class LanguageModel extends ChangeNotifier {
  String _language = "English"; // default

  String get language => _language;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  bool isFilipino() => _language == "Filipino";
}
