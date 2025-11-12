import 'package:shared_preferences/shared_preferences.dart';

class DisclaimerService {
  static const String _disclaimerKey = 'disclaimer_accepted';
  
  static Future<bool> isDisclaimerAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_disclaimerKey) ?? false;
  }
  
  static Future<void> setDisclaimerAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_disclaimerKey, accepted);
  }
  
  static String getDisclaimerText() {
    return '''
HAFTUNGSAUSSCHLUSS & NUTZUNGSBEDINGUNGEN

Diese Anwendung ist eine simulierte Glücksspiel-Umgebung zu Unterhaltungszwecken. 
Sie bietet keine Möglichkeit, echte Wetten abzuschließen oder Geldgewinne zu erzielen.

WICHTIGE HINWEISE:
• Keine Gewährleistung: Die App wird ohne jegliche Gewährleistung bereitgestellt.
• Haftungsausschluss: Der Entwickler haftet nicht für Schäden aus der Nutzung.
• Glücksspielrisiko: Diese App soll nicht zur Teilnahme an realen Glücksspielen ermutigen.
• Altersbeschränkung: Nutzung nur für Personen ab 18 Jahren.
• Simulation: Alle Jackpots und Gewinne sind fiktiv.

Durch die Zustimmung bestätigen Sie, diese Bedingungen verstanden zu haben.
''';
  }
}
