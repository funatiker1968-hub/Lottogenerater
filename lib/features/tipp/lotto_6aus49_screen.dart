import 'dart:async';
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
  final List<int> _currentAnimatingNumber = List.filled(12, 1);
  final List<List<bool>> _temporaryCrosses = List.generate(12, (_) => List.filled(49, false));
  int _scheinSuperzahl = 0;
  bool _superzahlGenerated = false;
  bool _isGeneratingAll = false;
  late AnimationController _superzahlAnimationController;
  late List<Timer> _animationTimers;

  @override
  void initState() {
    super.initState();
    _superzahlAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Reduziert von 3000ms
      vsync: this,
    );
    _animationTimers = List.generate(12, (_) => Timer(const Duration(seconds: 0), () {}));
  }

  @override
  void dispose() {
    _superzahlAnimationController.dispose();
    for (final timer in _animationTimers) {
      timer.cancel();
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

  void _startNumberAnimation(int tipIndex) {
    final numbers = _generatedTips[tipIndex];
    if (numbers.isEmpty) return;

    int currentStep = 1;
    final sortedNumbers = List.from(numbers)..sort();
    
    _animationTimers[tipIndex].cancel();
    
    void animateStep() {
      if (currentStep > 49) {
        return;
      }

      setState(() {
        for (int i = 0; i < 49; i++) {
          _temporaryCrosses[tipIndex][i] = false;
        }
        
        _temporaryCrosses[tipIndex][currentStep - 1] = true;
        _currentAnimatingNumber[tipIndex] = currentStep;
      });

      final isTargetNumber = sortedNumbers.contains(currentStep);
      
      if (isTargetNumber) {
        _animationTimers[tipIndex] = Timer(const Duration(milliseconds: 150), () { // Reduziert von 300ms
          setState(() {
            _temporaryCrosses[tipIndex][currentStep - 1] = false;
            _selectedNumbers[tipIndex][currentStep - 1] = true;
          });
          
          _animationTimers[tipIndex] = Timer(const Duration(milliseconds: 150), () { // Reduziert von 300ms
            currentStep++;
            animateStep();
          });
        });
      } else {
        _animationTimers[tipIndex] = Timer(const Duration(milliseconds: 150), () { // Reduziert von 300ms
          currentStep++;
          animateStep();
        });
      }
    }

    animateStep();
  }

  void _generateTip(int tipIndex) async {
    if (_tipGenerated[tipIndex]) {
      setState(() {
        for (int i = 0; i < 49; i++) {
          _selectedNumbers[tipIndex][i] = false;
          _temporaryCrosses[tipIndex][i] = false;
        }
        _generatedTips[tipIndex].clear();
        _tipGenerated[tipIndex] = false;
        _currentAnimatingNumber[tipIndex] = 1;
        _animationTimers[tipIndex].cancel();
      });
    } else {
      final currentCount = _generatedTips[tipIndex].length;
      final numbersNeeded = 6 - currentCount;
      
      if (numbersNeeded > 0) {
        final availableNumbers = List.generate(49, (index) => index + 1)
          ..removeWhere((number) => _generatedTips[tipIndex].contains(number));
        availableNumbers.shuffle();
        final newNumbers = availableNumbers.take(numbersNeeded).toList()..sort();

        for (final number in newNumbers) {
          _generatedTips[tipIndex].add(number);
        }
        _generatedTips[tipIndex].sort();
      }
      
      setState(() {
        _tipGenerated[tipIndex] = true;
        _currentAnimatingNumber[tipIndex] = 1;
      });

      _startNumberAnimation(tipIndex);
    }
  }

  void _stopAllAnimations() {
    setState(() {
      _isGeneratingAll = false;
      for (int i = 0; i < 12; i++) {
        _animationTimers[i].cancel();
      }
    });
  }

  void _generateAllTips() async {
    if (_isGeneratingAll) {
      _stopAllAnimations();
      return;
    }

    if (!_superzahlGenerated) {
      _generateSuperzahl();
      await Future.delayed(const Duration(milliseconds: 2200)); // Reduziert von 3200ms
    }

    setState(() {
      _isGeneratingAll = true;
    });

    for (int i = 0; i < 12; i++) {
      if (!_isGeneratingAll) break;
      
      if (!_tipGenerated[i]) {
        final currentCount = _generatedTips[i].length;
        final numbersNeeded = 6 - currentCount;
        
        if (numbersNeeded > 0) {
          final availableNumbers = List.generate(49, (index) => index + 1)
            ..removeWhere((number) => _generatedTips[i].contains(number));
          availableNumbers.shuffle();
          final newNumbers = availableNumbers.take(numbersNeeded).toList()..sort();

          for (final number in newNumbers) {
            _generatedTips[i].add(number);
          }
          _generatedTips[i].sort();
        }
        
        setState(() {
          _tipGenerated[i] = true;
          _currentAnimatingNumber[i] = 1;
        });

        _startNumberAnimation(i);
        
        await Future.delayed(const Duration(milliseconds: 7500)); // Reduziert von 15000ms
        
        if (!_isGeneratingAll) break;
        await Future.delayed(const Duration(milliseconds: 250)); // Reduziert von 500ms
      }
    }
    
    setState(() {
      _isGeneratingAll = false;
    });
  }

  void _clearAll() {
    setState(() {
      for (int i = 0; i < 12; i++) {
        for (int j = 0; j < 49; j++) {
          _selectedNumbers[i][j] = false;
          _temporaryCrosses[i][j] = false;
        }
        _generatedTips[i].clear();
        _tipGenerated[i] = false;
        _currentAnimatingNumber[i] = 1;
        _animationTimers[i].cancel();
      }
      _superzahlGenerated = false;
      _scheinSuperzahl = 0;
      _isGeneratingAll = false;
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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return AnimatedBuilder(
      animation: _superzahlAnimationController,
      builder: (context, child) {
        final animationValue = _superzahlAnimationController.value;
        final isAnimating = _superzahlAnimationController.isAnimating;
        final currentNumber = (animationValue * 30 % 10).floor(); // Reduzierte Durchgänge
        
        return Container(
          padding: EdgeInsets.all(isPortrait ? 12 : 6), // Kleinere Padding im Querformat
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[300]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SCHEIN-SUPERZAHL',
                style: TextStyle(
                  fontSize: isPortrait ? 16 : 12, // Kleinere Schrift im Querformat
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: isPortrait ? 8 : 4), // Kleinere Abstände im Querformat
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  crossAxisSpacing: 2, // Reduziert von 4
                  mainAxisSpacing: 2, // Reduziert von 4
                  childAspectRatio: 1.0,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final isFinalNumber = _superzahlGenerated && _scheinSuperzahl == index;
                  final isHighlighted = isAnimating && currentNumber == index;
                  final shouldStop = isAnimating && isFinalNumber && animationValue > 0.8; // Stoppt bei 80%
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: shouldStop ? Colors.blue[300] : 
                            isFinalNumber ? Colors.blue[300] : 
                            isHighlighted ? Colors.red : Colors.blue[100],
                      border: Border.all(color: Colors.blue[400]!),
                      borderRadius: BorderRadius.circular(2), // Kleinere Border Radius
                    ),
                    child: Center(
                      child: Text(
                        index.toString(),
                        style: TextStyle(
                          fontSize: isPortrait ? 14 : 10, // Kleinere Schrift im Querformat
                          fontWeight: FontWeight.bold,
                          color: shouldStop ? Colors.white : 
                                isFinalNumber ? Colors.white : Colors.blue[900],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: isPortrait ? 8 : 4), // Kleinere Abstände im Querformat
              Text(
                _superzahlGenerated ? 'Superzahl: $_scheinSuperzahl' : 
                isAnimating ? 'Lauflicht...' : 'Noch nicht generiert',
                style: TextStyle(
                  fontSize: isPortrait ? 14 : 10, // Kleinere Schrift im Querformat
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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Container(
      height: isPortrait ? 180 : 150, // Reduzierte Höhe
      padding: const EdgeInsets.all(2), // Reduzierte Padding
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.yellow[700]!),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 1, // Reduziert von 2
          mainAxisSpacing: 1, // Reduziert von 2
          childAspectRatio: 1.0,
        ),
        itemCount: 49,
        itemBuilder: (context, index) {
          final number = index + 1;
          final isSelected = _selectedNumbers[tipIndex][index];
          final isTemporaryCross = _temporaryCrosses[tipIndex][index];
          final isAnimating = _animationTimers[tipIndex].isActive;
          final currentAnimatingNumber = _currentAnimatingNumber[tipIndex];
          
          return GestureDetector(
            onTap: () => _toggleNumber(tipIndex, index),
            child: Container(
              decoration: BoxDecoration(
                color: isAnimating && currentAnimatingNumber == number ? Colors.yellow[400] : 
                      (isSelected ? Colors.yellow[300] : Colors.yellow[100]),
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(1), // Kleinere Border Radius
              ),
              child: Center(
                child: isSelected || isTemporaryCross
                  ? Text(
                      '✗',
                      style: TextStyle(
                        fontSize: isPortrait ? 14 : 12, // Kleinere Schrift
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: isPortrait ? 10 : 8, // Kleinere Schrift - 10% Verkleinerung
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipCard(int tipIndex, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(2), // Reduzierte Margin
      child: Padding(
        padding: const EdgeInsets.all(4), // Reduzierte Padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tipp ${tipIndex + 1}',
              style: TextStyle(
                fontSize: isPortrait ? 12 : 10, // Kleinere Schrift
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4), // Reduzierter Abstand
            Expanded(
              child: _buildNumberGrid(tipIndex, context),
            ),
            const SizedBox(height: 4), // Reduzierter Abstand
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Reduzierte Padding
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(2), // Kleinere Border Radius
              ),
              child: Text(
                _generatedTips[tipIndex].length == 6 // Nur anzeigen wenn alle 6 Zahlen da sind
                  ? 'Zahlen: ${_generatedTips[tipIndex].join(', ')}'
                  : '${_generatedTips[tipIndex].length}/6 Zahlen',
                style: TextStyle(
                  fontSize: isPortrait ? 8 : 6, // Kleinere Schrift
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 4), // Reduzierter Abstand
            SizedBox(
              width: double.infinity,
              height: 28, // Reduzierte Höhe
              child: ElevatedButton(
                onPressed: () => _generateTip(tipIndex),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tipGenerated[tipIndex] ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  _tipGenerated[tipIndex] ? 'LÖSCHEN' : 'GENERIEREN',
                  style: TextStyle(
                    fontSize: isPortrait ? 10 : 8, // Kleinere Schrift
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
          padding: const EdgeInsets.all(8), // Reduzierte Padding
          child: Column(
            children: [
              _buildSuperzahlGrid(),
              SizedBox(height: isPortrait ? 8 : 4), // Kleinere Abstände im Querformat
              
              Text(
                '12 Tipps - Wählen Sie Zahlen oder generieren Sie automatisch',
                style: TextStyle(
                  fontSize: isPortrait ? 14 : 10, // Kleinere Schrift im Querformat
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isPortrait ? 8 : 4), // Kleinere Abstände im Querformat
              
              Expanded(
                child: isPortrait
                  ? GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4, // Reduziert von 8
                        mainAxisSpacing: 4, // Reduziert von 8
                        childAspectRatio: 0.85, // Angepasstes Seitenverhältnis
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) => _buildTipCard(index, context),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 4, // Reduziert von 8
                        mainAxisSpacing: 4, // Reduziert von 8
                        childAspectRatio: 0.7, // Angepasstes Seitenverhältnis
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) => _buildTipCard(index, context),
                    ),
              ),
              
              SizedBox(height: isPortrait ? 8 : 4), // Kleinere Abstände im Querformat
              Container(
                padding: const EdgeInsets.all(8), // Reduzierte Padding
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _generateAllTips,
                      icon: Icon(Icons.auto_mode, size: isPortrait ? 16 : 12), // Kleinere Icons
                      label: Text(
                        _isGeneratingAll ? 'STOPPEN' : 'Alle generieren',
                        style: TextStyle(fontSize: isPortrait ? 12 : 8), // Kleinere Schrift
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _clearAll,
                      icon: Icon(Icons.delete, size: isPortrait ? 16 : 12), // Kleinere Icons
                      label: Text(
                        'Alle löschen',
                        style: TextStyle(fontSize: isPortrait ? 12 : 8), // Kleinere Schrift
                      ),
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
