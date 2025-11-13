import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/theme_service.dart';
import 'core/services/language_service.dart';
import 'widgets/disclaimer_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Lottogenerator v3',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: themeService.themeMode,
            home: DisclaimerDialog(
              onAccepted: () {
                // Wird in der Dialog-Komponente behandelt
              },
              onRejected: () {
                // Wird in der Dialog-Komponente behandelt
              },
            ),
          );
        },
      ),
    );
  }
}
