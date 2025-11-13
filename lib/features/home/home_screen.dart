import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import '../../widgets/disclaimer_dialog.dart';
import '../tipp/lotto_6aus49_screen.dart';
import '../tipp/eurojackpot_screen.dart';
import '../tipp/sayisal_loto_screen.dart';
import '../tipp/custom_lotto_screen.dart';
import '../statistics/statistics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App verlassen?'),
        content: const Text('Möchten Sie die App wirklich verlassen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DisclaimerDialog(
        onAccepted: () {
          Navigator.of(context).pop();
        },
        onRejected: () {
          Navigator.of(context).pop();
          _showExitDialog(context);
        },
      ),
    );
  }

  Widget _buildLotteryCard(String title, String subtitle, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageService>(
          builder: (context, languageService, child) {
            return Text(languageService.appTitle);
          },
        ),
        backgroundColor: Colors.blue[400],
        foregroundColor: Colors.white,
        actions: [
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return IconButton(
                icon: Icon(themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => themeService.toggleTheme(),
                tooltip: 'Theme wechseln',
              );
            },
          ),
          Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return IconButton(
                icon: const Icon(Icons.language),
                onPressed: () => languageService.toggleLanguage(),
                tooltip: 'Sprache wechseln',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDisclaimer(context),
            tooltip: 'Haftungsausschluss',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _showExitDialog(context),
            tooltip: 'App verlassen',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<LanguageService>(
              builder: (context, languageService, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Willkommen beim Lottogenerator',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Wählen Sie eine Lotterie aus:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildLotteryCard(
                    'LOTTO 6aus49',
                    '12 Tipps\n6 aus 49 + Superzahl',
                    Colors.yellow[700]!,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Lotto6aus49Screen())),
                  ),
                  _buildLotteryCard(
                    'EUROJACKPOT',
                    '8 Tipps\n5 aus 50 + 2 aus 10',
                    Colors.purple[400]!,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EurojackpotScreen())),
                  ),
                  _buildLotteryCard(
                    'SAYISAL LOTO',
                    '4 Tipps\n6 aus 60 + Superstar',
                    Colors.red[400]!,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SayisalLotoScreen())),
                  ),
                  _buildLotteryCard(
                    'CUSTOM LOTTO',
                    'Konfigurierbar\nEigene Regeln',
                    Colors.green[400]!,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomLottoScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (_) => const StatisticsScreen(lotteryType: 'all')
                  )
                ),
                icon: const Icon(Icons.analytics),
                label: const Text('STATISTIKEN ANZEIGEN'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
