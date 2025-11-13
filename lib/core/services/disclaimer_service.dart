class DisclaimerService {
  // KEINE Speicherung der Entscheidung - Disclaimer erscheint immer
  static bool get isDisclaimerAccepted => false;

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
