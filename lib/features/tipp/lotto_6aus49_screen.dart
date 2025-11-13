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
  int _scheinSuperzahl = 0;
  bool _superzahlGenerated = false;
  late AnimationController _superzahlAnimationController;
  late List<AnimationController> _tipAnimationControllers;

  @override
  void initState() {
    super.initState();
    _superzahlAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _tipAnimationControllers = List.generate(12, (index) => 
      AnimationController(
        duration: const Duration(milliseconds: 4000),
        vsync: this,
      )
    );
  }

  @override
  void dispose() {
    _superzahlAnimationController.dispose();
    for (final controller in _tipAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _canSelectNumber(int tipIndex) {
    return _generatedTips[tipIndex].length < 6;
  }

  void _generateSuperzahl() {
    if (!_superzahlGenerated) {
      _scheinSuperzahl = DateTime.now().millisecond % 10;
      _superzahlAnimationController.forward(from: 0.0).then((_) {
        setState(() {
          _superzahlGenerated = true;
        });
      });
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

      // Zahlen generieren
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
      
      setState(() {
        _tipGenerated[tipIndex] = true;
      });

      // Animation mit Verzögerung starten
      await Future.delayed(Duration(milliseconds: tipIndex * 500));
      _tipAnimationControllers[tipIndex].forward(from: 0.0);
    }
  }

  void _generateAllTips() async {
    // Superzahl zuerst
    if (!_superzahlGenerated) {
      _generateSuperzahl();
      await Future.delayed(const Duration(milliseconds: 3200));
    }

    // Dann alle Tipps nacheinander mit Verzögerung
    for (int i = 0; i < 12; i++) {
      if (!_tipGenerated[i]) {
        // Zahlen generieren
        final currentCount = _generatedTips[i].length;
        final numbersNeeded = 6 - currentCount;
        
        if (numbersNeeded > 0) {
          final availableNumbers = List.generate(49, (index) => index + 1)
            ..removeWhere((number) => _generatedTips[i].contains(number));
          availableNumbers.shuffle();
          final newNumbers = availableNumbers.take(numbersNeeded).toList()..sort();

          for (final number in newNumbers) {
            _selectedNumbers[i][number - 1] = true;
            _generatedTips[i].add(number);
          }
          _generatedTips[i].sort();
        }
        
        setState(() {
          _tipGenerated[i] = true;
        });

        // Animation mit Verzögerung starten
        _tipAnimationControllers[i].forward(from: 0.0);
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
  }

  void _clearAll() {
    setState(() {
      for (int i = 0; i < 12; i++) {
        for (int j = 0; j < 49; j++) {
          _selectedNumbers[i][j] = false;
        }
        _generatedTips[i].clear();
        _tipGenerated[i] = false;
        _tipAnimationControllers[i].reset();
      }
      _superzahlGenerated = false;
      _scheinSuperzahl = 0;
      _superzahlAnimationController.reset();
    });
  }

  void _toggleNumber(int tipIndex, int number) {
    if (!_tipGenerated[tipIndex] || _selectedNumbers[tipIndex][number]) {
      setState(() {
        if (_selectedNumbers[tipIndex][number]) {
          _selectedNumbers[tipIndex][number] = false;
          _generatedTips[tipIndex].remove(number + 1);
        } else if (_canSelectNumber(tipIndex)) {
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
        final animationValue = _superzahlAnimationController.value;
        final isAnimating = _superzahlAnimationController.isAnimating;
        final currentNumber = (animationValue * 40 % 10).floor(); // 0-9
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[100],
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
                  final isFinalNumber = _superzahlGenerated && _scheinSuperzahl == index;
                  final isHighlighted = isAnimating && currentNumber == index;
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: isFinalNumber ? Colors.blue[300] : 
                            isHighlighted ? Colors.red : Colors.blue[100],
                      border: Border.all(color: Colors.blue[400]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        index.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isFinalNumber ? Colors.white : Colors.blue[900],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                _superzahlGenerated ? 'Superzahl: $_scheinSuperzahl' : 
                isAnimating ? 'Lauflicht...' : 'Noch nicht generiert',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _superzahlGenerated ? Colors.red : 
                        isAnimating ? Colors.orange : Colors.grey,
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
      height: 200,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow[700]!),
      ),
      child: SingleChildScrollView(
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
                animation: _tipAnimationControllers[tipIndex],
                builder: (context, child) {
                  final animationValue = _tipAnimationControllers[tipIndex].value;
                  final isAnimating = _tipAnimationControllers[tipIndex].isAnimating;
                  final shouldAnimate = isAnimating && _tipGenerated[tipIndex] &&
                      _generatedTips[tipIndex].contains(number);
                  
                  // Sequenzielle Animation: Jede Zahl erscheint nacheinander
                  final numberIndex = _generatedTips[tipIndex].indexOf(number);
                  final numberAnimation = numberIndex >= 0 ? 
                      (animationValue * 7).clamp(numberIndex * 0.8, (numberIndex + 1) * 0.8) : 0.0;
                  final isNumberVisible = !isAnimating || numberAnimation > numberIndex;
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: shouldAnimate && !isNumberVisible ? Colors.yellow[400] : 
                            (isSelected ? Colors.yellow[300] : Colors.yellow[100]),
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
                              fontWeight: FontWeight.bold,
                              color: shouldAnimate && !isNumberVisible ? Colors.transparent : Colors.red[900],
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
              child: AnimatedBuilder(
                animation: _tipAnimationControllers[tipIndex],
                builder: (context, child) {
                  final animationValue = _tipAnimationControllers[tipIndex].value;
                  final visibleCount = (_generatedTips[tipIndex].length * animationValue).ceil();
                  final visibleNumbers = _generatedTips[tipIndex].take(visibleCount).toList();
                  
                  return Text(
                    visibleNumbers.isNotEmpty 
                      ? 'Zahlen: ${visibleNumbers.join(', ')}'
                      : 'Noch keine Zahlen',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  );
                },
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
                      onPressed: _generateAllTips,
                      icon: const Icon(Icons.auto_mode, size: 18),
                      label: const Text('Alle generieren'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clearAll,
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
