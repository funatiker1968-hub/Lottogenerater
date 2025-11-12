import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { german, english, turkish }

class LanguageService with ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  AppLanguage _currentLanguage = AppLanguage.german;

  AppLanguage get currentLanguage => _currentLanguage;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageIndex = prefs.getInt(_languageKey) ?? AppLanguage.german.index;
    _currentLanguage = AppLanguage.values[languageIndex];
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_languageKey, language.index);
    notifyListeners();
  }

  String getLanguageName(AppLanguage language) {
    switch (language) {
      case AppLanguage.german:
        return 'Deutsch';
      case AppLanguage.english:
        return 'English';
      case AppLanguage.turkish:
        return 'Türkçe';
    }
  }

  String get currentLanguageName => getLanguageName(_currentLanguage);
}
