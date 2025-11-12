import 'dart:math' as math;
import 'package:flutter/material.dart';

class SayisalLotoScreen extends StatefulWidget {
  const SayisalLotoScreen({Key? key}) : super(key: key);

  @override
  State<SayisalLotoScreen> createState() => _SayisalLotoScreenState();
}

class _SayisalLotoScreenState extends State<SayisalLotoScreen> {
  final List<List<bool>> _selectedNumbers = List.generate(4, (_) => List.filled(90, false));
  final List<List<int>> _generatedTips = List.generate(4, (_) => []);
  final List<bool> _tipGenerated = List.filled(4, false);
  final List<bool> _superstarSelected = List.filled(4, false);
  final List<int> _superstarNumbers = List.filled(4, 0);
  final _random = math.Random();

  void _generateTip(int tipIndex) {
    if (_tipGenerated[tipIndex]) {
      // Löschen
      setState(() {
        for (int i = 0; i < 90; i++) {
          _selectedNumbers[tipIndex][i] = false;
        }
        _generatedTips[tipIndex].clear();
        _superstarSelected[tipIndex] = false;
        _superstarNumbers[tipIndex] = 0;
        _tipGenerated[tipIndex] = false;
      });
    } else {
      // Generieren
      setState(() {
        _generatedTips[tipIndex].clear();
        final numbers = List.generate(90, (index) => index + 1)..shuffle();
        final selectedNumbers = numbers.take(6).toList()..sort();
        
        for (final number in selectedNumbers) {
          _selectedNumbers[tipIndex][number - 1] = true;
          _generatedTips[tipIndex].add(number);
        }
        
        // Süperstar nur wenn Checkbox aktiv
        if (_superstarSelected[tipIndex]) {
          _superstarNumbers[tipIndex] = _random.nextInt(90) + 1;
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

  void _toggleSuperstar(int tipIndex) {
    setState(() {
      _superstarSelected[tipIndex] = !_superstarSelected[tipIndex];
      if (!_superstarSelected[tipIndex]) {
        _superstarNumbers[tipIndex] = 0;
      } else if (_tipGenerated[tipIndex]) {
        _superstarNumbers[tipIndex] = _random.nextInt(90) + 1;
      }
    });
  }

  void _generateSuperstar(int tipIndex) {
    setState(() {
      _superstarNumbers[tipIndex] = _random.nextInt(90) + 1;
    });
  }

  Widget _buildNumberGrid(int tipIndex, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1.0,
        ),
        itemCount: 90,
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
                    fontSize: isPortrait ? 10 : 8,
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

  Widget _buildSuperstarField(int tipIndex, BuildContext context) {
    final hasSuperstar = _superstarSelected[tipIndex] && _superstarNumbers[tipIndex] > 0;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasSuperstar ? Colors.blue[400]! : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Checkbox(
                value: _superstarSelected[tipIndex],
                onChanged: (value) => _toggleSuperstar(tipIndex),
              ),
              Text('Süperstar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              if (_superstarSelected[tipIndex])
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _generateSuperstar(tipIndex),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 4),
                    ),
                    child: Text(
                      hasSuperstar ? 'NEU GENERIEREN' : 'GENERIEREN',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          if (hasSuperstar)
            Container(
              margin: EdgeInsets.only(top: 4),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Süperstar: ${_superstarNumbers[tipIndex]}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTipSection(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isPortrait ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isPortrait ? 1.6 : 0.8,
      ),
      itemCount: 4,
      itemBuilder: (context, tipIndex) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
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
              Text('6 aus 90:', style: TextStyle(fontSize: 10)),
              SizedBox(height: 4),
              Expanded(child: _buildNumberGrid(tipIndex, context)),
              SizedBox(height: 8),
              _buildSuperstarField(tipIndex, context),
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
        title: Text('Sayısal Loto'),
        backgroundColor: Colors.red[300],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isPortrait ? 16 : 8),
          child: Column(
            children: [
              Text(
                '4 Tipps - 6 Zahlen + optional Süperstar',
                style: TextStyle(
                  fontSize: isPortrait ? 16 : 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isPortrait ? 16 : 12),
              Text(
                'Süperstar ist eine gebührenpflichtige Zusatzzahl',
                style: TextStyle(
                  fontSize: isPortrait ? 12 : 10,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isPortrait ? 16 : 12),
              Expanded(child: _buildTipSection(context)),
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
                        for (int i = 0; i < 4; i++) {
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
                        for (int i = 0; i < 4; i++) {
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
