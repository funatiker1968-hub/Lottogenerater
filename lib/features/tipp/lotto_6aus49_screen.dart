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
  final List<int> _superNumbers = List.filled(12, 0);
  final List<AnimationController> _animationControllers = [];
  final List<List<Animation<double>>> _numberAnimations = [];

  @override
  void initState() {
    super.initState();
    // Animation Controller für jeden Tipp initialisieren
    for (int i = 0; i < 12; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 3000),
        vsync: this,
      );
      _animationControllers.add(controller);
      
      final animations = List.generate(6, (index) {
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              (0.1 + index * 0.15).clamp(0.0, 1.0),
              (0.25 + index * 0.15).clamp(0.0, 1.0),
            ),
          ),
        );
      });
      _numberAnimations.add(animations);
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _canSelectNumber(int tipIndex) {
    return _generatedTips[tipIndex].length < 6;
  }

  void _generateTip(int tipIndex) async {
    if (_tipGenerated[tipIndex]) {
      // Löschen
      setState(() {
        for (int i = 0; i < 49; i++) {
          _selectedNumbers[tipIndex][i] = false;
        }
        _generatedTips[tipIndex].clear();
        _superNumbers[tipIndex] = 0;
        _tipGenerated[tipIndex] = false;
      });
    } else {
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

        // Superzahl generieren (0-9)
        _superNumbers[tipIndex] = DateTime.now().millisecond % 10;
        _tipGenerated[tipIndex] = true;
      });

      // Animation starten
      _animationControllers[tipIndex].forward(from: 0.0);
    }
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

  Widget _buildSuperNumberField(int tipIndex) {
    return AnimatedBuilder(
      animation: _animationControllers[tipIndex],
      builder: (context, child) {
        final animationValue = _animationControllers[tipIndex].value;
        final isAnimating = _animationControllers[tipIndex].isAnimating;
        
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100], // Hellblau
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Superzahl: ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (isAnimating)
                Text(
                  _getAnimatedSuperNumber(animationValue),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                )
              else
                Text(
                  _tipGenerated[tipIndex] ? _superNumbers[tipIndex].toString() : '-',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _tipGenerated[tipIndex] ? Colors.red : Colors.grey,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getAnimatedSuperNumber(double animationValue) {
    final numbers = List.generate(10, (index) => index);
    final index = (animationValue * 30).floor() % 10;
    return numbers[index].toString();
  }

  Widget _buildNumberGrid(int tipIndex, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow[700]!),
      ),
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
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.yellow[300] : Colors.yellow[100],
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
                        fontSize: isPortrait ? 12 : 10,
                        color: Colors.red[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipSection(int startIndex, int endIndex, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final crossAxisCount = isPortrait ? 2 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: isPortrait ? 1.2 : 1.0,
      ),
      itemCount: endIndex - startIndex,
      itemBuilder: (context, gridIndex) {
        final tipIndex = startIndex + gridIndex;
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
                // Zahlenliste mit Animation
                AnimatedBuilder(
                  animation: _animationControllers[tipIndex],
                  builder: (context, child) {
                    final animation = _animationControllers[tipIndex];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: _buildAnimatedNumbersList(tipIndex, animation.value),
                    );
                  },
                ),
                const SizedBox(height: 6),
                // Superzahl Feld
                _buildSuperNumberField(tipIndex),
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
      },
    );
  }

  Widget _buildAnimatedNumbersList(int tipIndex, double animationValue) {
    final numbers = _generatedTips[tipIndex];
    final visibleCount = (numbers.length * animationValue).ceil();
    final visibleNumbers = numbers.take(visibleCount).toList();
    
    String displayText;
    if (_tipGenerated[tipIndex]) {
      displayText = visibleNumbers.isNotEmpty 
        ? 'Zahlen: ${visibleNumbers.join(', ')}${visibleCount >= numbers.length ? ' | Superzahl: ${_superNumbers[tipIndex]}' : ''}'
        : 'Generiere...';
    } else {
      displayText = numbers.isNotEmpty 
        ? 'Zahlen: ${numbers.join(', ')}'
        : 'Noch keine Zahlen';
    }

    return Text(
      displayText,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
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
          padding: EdgeInsets.all(isPortrait ? 12 : 8),
          child: Column(
            children: [
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
                  ? Column(
                      children: [
                        Expanded(child: _buildTipSection(0, 6, context)),
                        const SizedBox(height: 8),
                        Expanded(child: _buildTipSection(6, 12, context)),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildTipSection(0, 12, context),
                        ],
                      ),
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
