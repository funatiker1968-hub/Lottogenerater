import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/disclaimer_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/language_service.dart';
import 'features/home/home_screen.dart';
import 'widgets/disclaimer_dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
            home: FutureBuilder<bool>(
              future: DisclaimerService.isDisclaimerAccepted(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                
                final disclaimerAccepted = snapshot.data ?? false;
                if (!disclaimerAccepted) {
                  return DisclaimerDialog(
                    onAccepted: () {
                      DisclaimerService.setDisclaimerAccepted(true);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    },
                    onRejected: () {
                      Future.microtask(() => Navigator.of(context).pop());
                    },
                  );
                }
                
                return HomeScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
