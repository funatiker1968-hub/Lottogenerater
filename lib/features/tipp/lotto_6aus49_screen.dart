import 'package:flutter/material.dart';

class Lotto6aus49Screen extends StatefulWidget {
  const Lotto6aus49Screen({Key? key}) : super(key: key);

  @override
  State<Lotto6aus49Screen> createState() => _Lotto6aus49ScreenState();
}

class _Lotto6aus49ScreenState extends State<Lotto6aus49Screen> {
  final List<List<bool>> _selectedNumbers = List.generate(12, (_) => List.filled(49, false));
  final List<List<int>> _generatedTips = List.generate(12, (_) => []);
  final List<bool> _tipGenerated = List.filled(12, false);

  void _generateTip(int tipIndex) {
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
      // Generieren
      setState(() {
        _generatedTips[tipIndex].clear();
        final random = List.generate(49, (index) => index + 1)..shuffle();
        final numbers = random.take(6).toList()..sort();
        
        for (final number in numbers) {
          _selectedNumbers[tipIndex][number - 1] = true;
          _generatedTips[tipIndex].add(number);
        }
        _tipGenerated[tipIndex] = true;
      });
    }
  }

  void _toggleNumber(int tipIndex, int number) {
    setState(() {
      _selectedNumbers[tipIndex][number] = !_selectedNumbers[tipIndex][number];
      if (_selectedNumbers[tipIndex][number]) {
        _generatedTips[tipIndex].add(number + 1);
        _generatedTips[tipIndex].sort();
      } else {
        _generatedTips[tipIndex].remove(number + 1);
      }
    });
  }

  Widget _buildNumberGrid(int tipIndex, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow[700]!),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // Immer 7x7 Grid für Konsistenz
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1.0, // Quadratische Zellen
        ),
        itemCount: 49,
        itemBuilder: (context, index) {
          final number = index + 1;
          final isSelected = _selectedNumbers[tipIndex][index];
          return GestureDetector(
            onTap: () => _toggleNumber(tipIndex, index),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.red[800] : Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: isPortrait ? 12 : 10, // Kleinere Schrift im Querformat
                    color: isSelected ? Colors.white : Colors.black,
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
    final crossAxisCount = isPortrait ? 3 : 6; // 3 Spalten Hochformat, 6 Spalten Querformat
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: isPortrait ? 0.8 : 0.6, // Angepasstes Seitenverhältnis
      ),
      itemCount: endIndex - startIndex,
      itemBuilder: (context, gridIndex) {
        final tipIndex = startIndex + gridIndex;
        return Container(
          margin: EdgeInsets.all(2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tipp ${tipIndex + 1}',
                style: TextStyle(
                  fontSize: isPortrait ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Expanded(
                child: _buildNumberGrid(tipIndex, context),
              ),
              SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: isPortrait ? 36 : 32,
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
                      fontSize: isPortrait ? 12 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lotto 6aus49'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isPortrait ? 16 : 8),
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
              SizedBox(height: isPortrait ? 20 : 12),
              Expanded(
                child: isPortrait 
                  ? Column(
                      children: [
                        // Hochformat: 2 Reihen mit je 6 Tipps
                        Expanded(
                          child: _buildTipSection(0, 6, context),
                        ),
                        SizedBox(height: 12),
                        Expanded(
                          child: _buildTipSection(6, 12, context),
                        ),
                      ],
                    )
                  : _buildTipSection(0, 12, context), // Querformat: Alle 12 Tipps in einem Grid
              ),
              SizedBox(height: isPortrait ? 16 : 12),
              Container(
                padding: EdgeInsets.all(isPortrait ? 12 : 8),
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
                      icon: Icon(Icons.auto_mode, size: isPortrait ? 20 : 16),
                      label: Text(
                        'Alle generieren',
                        style: TextStyle(fontSize: isPortrait ? 14 : 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        for (int i = 0; i < 12; i++) {
                          if (_tipGenerated[i]) {
                            _generateTip(i);
                          }
                        }
                      },
                      icon: Icon(Icons.delete, size: isPortrait ? 20 : 16),
                      label: Text(
                        'Alle löschen',
                        style: TextStyle(fontSize: isPortrait ? 14 : 12),
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
