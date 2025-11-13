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

  // NEUE METHODE: toggleLanguage für Sprachumschaltung
  void toggleLanguage() {
    final languages = AppLanguage.values;
    final currentIndex = languages.indexOf(_currentLanguage);
    final nextIndex = (currentIndex + 1) % languages.length;
    setLanguage(languages[nextIndex]);
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
        return 'Deutsch 🇩🇪';
      case AppLanguage.english:
        return 'English 🇬🇧';
      case AppLanguage.turkish:
        return 'Türkçe 🇹🇷';
    }
  }

  String get currentLanguageName => getLanguageName(_currentLanguage);

  // Text-Methoden für die gesamte App
  String get appTitle {
    switch (_currentLanguage) {
      case AppLanguage.german:
        return 'Lottogenerator';
      case AppLanguage.english:
        return 'Lottery Generator';
      case AppLanguage.turkish:
        return 'Loto Üretici';
    }
  }

  String get disclaimerTitle {
    switch (_currentLanguage) {
      case AppLanguage.german:
        return 'HAFTUNGSAUSSCHLUSS & NUTZUNGSBEDINGUNGEN';
      case AppLanguage.english:
        return 'DISCLAIMER & TERMS OF USE';
      case AppLanguage.turkish:
        return 'SORUMLULUK REDDI & KULLANIM ŞARTLARI';
    }
  }

  String get acceptButton {
    switch (_currentLanguage) {
      case AppLanguage.german:
        return 'AKZEPTIEREN';
      case AppLanguage.english:
        return 'ACCEPT';
      case AppLanguage.turkish:
        return 'KABUL ET';
    }
  }

  String get rejectButton {
    switch (_currentLanguage) {
      case AppLanguage.german:
        return 'ABLEHNEN UND APP VERLASSEN';
      case AppLanguage.english:
        return 'REJECT AND EXIT APP';
      case AppLanguage.turkish:
        return 'REDDET VE UYGULAMADAN ÇIK';
    }
  }
}
