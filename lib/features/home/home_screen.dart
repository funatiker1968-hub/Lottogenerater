import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../tipp/lotto_6aus49_screen.dart';
import '../tipp/eurojackpot_screen.dart';
import '../tipp/sayisal_loto_screen.dart';
import '../tipp/custom_lotto_screen.dart';
import '../statistics/statistics_screen.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/language_service.dart';
import '../../widgets/disclaimer_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('App verlassen?'),
        content: Text('Möchten Sie die App wirklich verlassen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Verlassen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sprache wählen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((language) {
            return ListTile(
              leading: Radio(
                value: language,
                groupValue: languageService.currentLanguage,
                onChanged: (value) {
                  languageService.setLanguage(value as AppLanguage);
                  Navigator.of(context).pop();
                },
              ),
              title: Text(languageService.getLanguageName(language)),
              onTap: () {
                languageService.setLanguage(language);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DisclaimerDialog(
        onAccepted: () => Navigator.of(context).pop(),
        onRejected: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showStatisticsDialog(BuildContext context, String lotteryType) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StatisticsScreen(lotteryType: lotteryType)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final languageService = Provider.of<LanguageService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lottogenerator v3'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeService.toggleTheme(),
            tooltip: 'Theme wechseln',
          ),
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () => _showLanguageDialog(context),
            tooltip: 'Sprache wechseln',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.bar_chart),
            tooltip: 'Statistik',
            onSelected: (value) => _showStatisticsDialog(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(value: '6aus49', child: Text('Lotto 6aus49 Statistik')),
              PopupMenuItem(value: 'eurojackpot', child: Text('Eurojackpot Statistik')),
              PopupMenuItem(value: 'sayisal_loto', child: Text('Sayısal Loto Statistik')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showDisclaimer(context),
            tooltip: 'Haftungsausschluss',
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _showExitDialog(context),
            tooltip: 'App verlassen',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bitte wähle ein System:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildLotteryCard(
                    context,
                    title: 'Lotto 6aus49',
                    subtitle: '12 Tipps + Superzahl',
                    color: Colors.yellow[700]!,
                    icon: Icons.confirmation_number,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Lotto6aus49Screen()),
                      );
                    },
                  ),
                  _buildLotteryCard(
                    context,
                    title: 'Eurojackpot',
                    subtitle: '8 Tipps + Eurozahlen',
                    color: Colors.blue[300]!,
                    icon: Icons.star,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EurojackpotScreen()),
                      );
                    },
                  ),
                  _buildLotteryCard(
                    context,
                    title: 'Sayısal Loto',
                    subtitle: '4 Tipps + Süperstar',
                    color: Colors.red[300]!,
                    icon: Icons.flag,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SayisalLotoScreen()),
                      );
                    },
                  ),
                  _buildLotteryCard(
                    context,
                    title: 'Custom Lotto',
                    subtitle: 'Konfigurierbar',
                    color: Colors.green[400]!,
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CustomLottoScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            _buildInfoBar(context, languageService),
          ],
        ),
      ),
    );
  }

  Widget _buildLotteryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context, LanguageService languageService) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sprache: ${languageService.currentLanguageName} • Aktualisiert: ${_getCurrentTime()}',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
