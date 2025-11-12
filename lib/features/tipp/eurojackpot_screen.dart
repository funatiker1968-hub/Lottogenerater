import 'package:flutter/material.dart';

class EurojackpotScreen extends StatefulWidget {
  const EurojackpotScreen({Key? key}) : super(key: key);

  @override
  State<EurojackpotScreen> createState() => _EurojackpotScreenState();
}

class _EurojackpotScreenState extends State<EurojackpotScreen> {
  final List<List<bool>> _selectedMainNumbers = List.generate(8, (_) => List.filled(50, false));
  final List<List<bool>> _selectedEuroNumbers = List.generate(8, (_) => List.filled(12, false));
  final List<List<int>> _generatedMainTips = List.generate(8, (_) => []);
  final List<List<int>> _generatedEuroTips = List.generate(8, (_) => []);
  final List<bool> _tipGenerated = List.filled(8, false);

  void _generateTip(int tipIndex) async {
    if (_tipGenerated[tipIndex]) {
      // Löschen
      setState(() {
        for (int i = 0; i < 50; i++) {
          _selectedMainNumbers[tipIndex][i] = false;
        }
        for (int i = 0; i < 12; i++) {
          _selectedEuroNumbers[tipIndex][i] = false;
        }
        _generatedMainTips[tipIndex].clear();
        _generatedEuroTips[tipIndex].clear();
        _tipGenerated[tipIndex] = false;
      });
    } else {
      // Hauptzahlen generieren
      setState(() {
        _generatedMainTips[tipIndex].clear();
        final mainRandom = List.generate(50, (index) => index + 1)..shuffle();
        final mainNumbers = mainRandom.take(5).toList()..sort();
        
        for (final number in mainNumbers) {
          _selectedMainNumbers[tipIndex][number - 1] = true;
          _generatedMainTips[tipIndex].add(number);
        }
      });

      // 1,5 Sekunden Verzögerung für Eurozahlen
      await Future.delayed(Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _generatedEuroTips[tipIndex].clear();
          final euroRandom = List.generate(12, (index) => index + 1)..shuffle();
          final euroNumbers = euroRandom.take(2).toList()..sort();
          
          for (final number in euroNumbers) {
            _selectedEuroNumbers[tipIndex][number - 1] = true;
            _generatedEuroTips[tipIndex].add(number);
          }
          _tipGenerated[tipIndex] = true;
        });
      }
    }
  }

  void _toggleMainNumber(int tipIndex, int number) {
    setState(() {
      _selectedMainNumbers[tipIndex][number] = !_selectedMainNumbers[tipIndex][number];
      if (_selectedMainNumbers[tipIndex][number]) {
        _generatedMainTips[tipIndex].add(number + 1);
        _generatedMainTips[tipIndex].sort();
      } else {
        _generatedMainTips[tipIndex].remove(number + 1);
      }
    });
  }

  void _toggleEuroNumber(int tipIndex, int number) {
    setState(() {
      _selectedEuroNumbers[tipIndex][number] = !_selectedEuroNumbers[tipIndex][number];
      if (_selectedEuroNumbers[tipIndex][number]) {
        _generatedEuroTips[tipIndex].add(number + 1);
        _generatedEuroTips[tipIndex].sort();
      } else {
        _generatedEuroTips[tipIndex].remove(number + 1);
      }
    });
  }

  Widget _buildMainNumberGrid(int tipIndex, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1.0,
        ),
        itemCount: 50,
        itemBuilder: (context, index) {
          final number = index + 1;
          final isSelected = _selectedMainNumbers[tipIndex][index];
          return GestureDetector(
            onTap: () => _toggleMainNumber(tipIndex, index),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[800] : Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: isPortrait ? 12 : 10,
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

  Widget _buildEuroNumberGrid(int tipIndex, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1.0,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final number = index + 1;
          final isSelected = _selectedEuroNumbers[tipIndex][index];
          return GestureDetector(
            onTap: () => _toggleEuroNumber(tipIndex, index),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange[800] : Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: isPortrait ? 14 : 12,
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
    final crossAxisCount = isPortrait ? 2 : 4; // 2 Spalten Hochformat, 4 Spalten Querformat
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isPortrait ? 1.4 : 0.8,
      ),
      itemCount: endIndex - startIndex,
      itemBuilder: (context, gridIndex) {
        final tipIndex = startIndex + gridIndex;
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
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
              SizedBox(height: 6),
              Text('Hauptzahlen (5 aus 50):', style: TextStyle(fontSize: 10)),
              SizedBox(height: 4),
              Expanded(child: _buildMainNumberGrid(tipIndex, context)),
              SizedBox(height: 8),
              Text('Eurozahlen (2 aus 12):', style: TextStyle(fontSize: 10)),
              SizedBox(height: 4),
              _buildEuroNumberGrid(tipIndex, context),
              SizedBox(height: 8),
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
        title: Text('Eurojackpot'),
        backgroundColor: Colors.blue[300],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isPortrait ? 16 : 8),
          child: Column(
            children: [
              Text(
                '8 Tipps - 5 Hauptzahlen + 2 Eurozahlen',
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
                        // Hochformat: 2 Reihen mit je 4 Tipps
                        Expanded(
                          child: _buildTipSection(0, 4, context),
                        ),
                        SizedBox(height: 12),
                        Expanded(
                          child: _buildTipSection(4, 8, context),
                        ),
                      ],
                    )
                  : _buildTipSection(0, 8, context), // Querformat: Alle 8 Tipps in einem Grid
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
                        for (int i = 0; i < 8; i++) {
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
                        for (int i = 0; i < 8; i++) {
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
