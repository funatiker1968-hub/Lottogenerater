import 'package:flutter/material.dart';

class Lotto6aus49Screen extends StatefulWidget {
  const Lotto6aus49Screen({super.key});

  @override
  State<Lotto6aus49Screen> createState() => _Lotto6aus49ScreenState();
}

class _Lotto6aus49ScreenState extends State<Lotto6aus49Screen> with TickerProviderStateMixin {
  final List<List<bool>> _selectedNumbers = List.generate(12, (_) => List.filled(49, false));
  final List<List<int>> _generatedTips = List.generate(12, (_) => []);
  final List<bool> _tipGenerated = List.filled(12, false);
  int _scheinSuperzahl = 0; // NUR EINE Superzahl pro SCHEIN
  bool _superzahlGenerated = false;
  late AnimationController _superzahlAnimationController;
  late AnimationController _numbersAnimationController;

  @override
  void initState() {
    super.initState();
    _superzahlAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _numbersAnimationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _superzahlAnimationController.dispose();
    _numbersAnimationController.dispose();
    super.dispose();
  }

  bool _canSelectNumber(int tipIndex) {
    return _generatedTips[tipIndex].length < 6;
  }

  void _generateSuperzahl() {
    if (!_superzahlGenerated) {
      setState(() {
        _scheinSuperzahl = DateTime.now().millisecond % 10;
        _superzahlGenerated = true;
      });
      _superzahlAnimationController.forward(from: 0.0);
    }
  }

  void _generateTip(int tipIndex) async {
    if (_tipGenerated[tipIndex]) {
      // Löschen
      setState(() {
        for (int i = 0; i < 49; i++) {
          _selectedNumbers[tipIndex][i] = false;
        }
        _generatedTips[tipIndex].clear();
        _tipGenerated[tipIndex] = false;
      });
    } else {
      // Superzahl zuerst generieren (nur einmal pro Schein)
      if (!_superzahlGenerated) {
        _generateSuperzahl();
      }

      // Generieren - nur fehlende Zahlen ergänzen
      setState(() {
        final currentCount = _generatedTips[tipIndex].length;
        final numbersNeeded = 6 - currentCount;
        
        if (numbersNeeded > 0) {
          final availableNumbers = List.generate(49, (index) => index + 1)
            ..removeWhere((number) => _generatedTips[tipIndex].contains(number));
          availableNumbers.shuffle();
          final newNumbers = availableNumbers.take(numbersNeeded).toList()..sort();

          for (final number in newNumbers) {
            _selectedNumbers[tipIndex][number - 1] = true;
            _generatedTips[tipIndex].add(number);
          }
          _generatedTips[tipIndex].sort();
        }
        _tipGenerated[tipIndex] = true;
      });

      // Zahlen-Animation starten
      _numbersAnimationController.forward(from: 0.0);
    }
  }

  void _toggleNumber(int tipIndex, int number) {
    if (!_tipGenerated[tipIndex] || _selectedNumbers[tipIndex][number]) {
      setState(() {
        if (_selectedNumbers[tipIndex][number]) {
          // Zahl abwählen
          _selectedNumbers[tipIndex][number] = false;
          _generatedTips[tipIndex].remove(number + 1);
        } else if (_canSelectNumber(tipIndex)) {
          // Zahl auswählen (nur wenn < 6)
          _selectedNumbers[tipIndex][number] = true;
          _generatedTips[tipIndex].add(number + 1);
          _generatedTips[tipIndex].sort();
        }
      });
    }
  }

  Widget _buildSuperzahlGrid() {
    return AnimatedBuilder(
      animation: _superzahlAnimationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[100], // Hellblau
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[300]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SCHEIN-SUPERZAHL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1.0,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final isAnimating = _superzahlAnimationController.isAnimating;
                  final isSelected = _superzahlGenerated && _scheinSuperzahl == index;
                  final shouldHighlight = isAnimating && 
                      (_superzahlAnimationController.value * 20).floor() % 10 == index;
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: shouldHighlight ? Colors.red : 
                            isSelected ? Colors.blue[300] : Colors.blue[100],
                      border: Border.all(color: Colors.blue[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        index.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.blue[900],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                _superzahlGenerated ? 'Superzahl: $_scheinSuperzahl' : 'Noch nicht generiert',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _superzahlGenerated ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNumberGrid(int tipIndex, BuildContext context) {
    return Container(
      height: 200, // Feste Höhe für Scrollbarkeit
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow[700]!),
      ),
      child: SingleChildScrollView( // Scrollen für Zahlen 1-49
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1.0,
          ),
          itemCount: 49,
          itemBuilder: (context, index) {
            final number = index + 1;
            final isSelected = _selectedNumbers[tipIndex][index];
            return GestureDetector(
              onTap: () => _toggleNumber(tipIndex, index),
              child: AnimatedBuilder(
                animation: _numbersAnimationController,
                builder: (context, child) {
                  final isAnimating = _numbersAnimationController.isAnimating;
                  final shouldAnimate = isAnimating && _tipGenerated[tipIndex] &&
                      _generatedTips[tipIndex].contains(number);
                  final animationValue = _numbersAnimationController.value;
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: shouldAnimate && (animationValue * 10).floor() % 2 == 0 
                          ? Colors.yellow[400] 
                          : (isSelected ? Colors.yellow[300] : Colors.yellow[100]),
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: isSelected 
                        ? const Text(
                            '✗',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            number.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTipCard(int tipIndex, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tipp ${tipIndex + 1}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: _buildNumberGrid(tipIndex, context),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _generatedTips[tipIndex].isNotEmpty 
                  ? 'Zahlen: ${_generatedTips[tipIndex].join(', ')}'
                  : 'Noch keine Zahlen',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: () => _generateTip(tipIndex),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tipGenerated[tipIndex] ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  _tipGenerated[tipIndex] ? 'LÖSCHEN' : 'GENERIEREN',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lotto 6aus49'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Superzahl Bereich
              _buildSuperzahlGrid(),
              const SizedBox(height: 12),
              
              Text(
                '12 Tipps - Wählen Sie Zahlen oder generieren Sie automatisch',
                style: TextStyle(
                  fontSize: isPortrait ? 16 : 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Tipps Bereich mit Scrollen
              Expanded(
                child: isPortrait
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) => _buildTipCard(index, context),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) => _buildTipCard(index, context),
                    ),
              ),
              
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        for (int i = 0; i < 12; i++) {
                          if (!_tipGenerated[i]) {
                            _generateTip(i);
                          }
                        }
                      },
                      icon: const Icon(Icons.auto_mode, size: 18),
                      label: const Text('Alle generieren'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        for (int i = 0; i < 12; i++) {
                          if (_tipGenerated[i]) {
                            _generateTip(i);
                          }
                        }
                      },
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Alle löschen'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
