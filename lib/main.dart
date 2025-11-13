import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/theme_service.dart';
import 'core/services/language_service.dart';
import 'features/home/home_screen.dart';
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
            home: const DisclaimerWrapper(),
          );
        },
      ),
    );
  }
}

class DisclaimerWrapper extends StatefulWidget {
  const DisclaimerWrapper({super.key});

  @override
  State<DisclaimerWrapper> createState() => _DisclaimerWrapperState();
}

class _DisclaimerWrapperState extends State<DisclaimerWrapper> {
  bool _showHomeScreen = false;

  void _handleAccepted() {
    setState(() {
      _showHomeScreen = true;
    });
  }

  void _handleRejected() {
    // App beenden - funktioniert auf den meisten Plattformen
    // In Flutter gibt es keine universelle Exit-Methode, aber Navigator.pop() kann helfen
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_showHomeScreen) {
      return const HomeScreen();
    }

    return DisclaimerDialog(
      onAccepted: _handleAccepted,
      onRejected: _handleRejected,
    );
  }
}
