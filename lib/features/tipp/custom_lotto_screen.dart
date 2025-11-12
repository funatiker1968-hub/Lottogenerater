import 'package:flutter/material.dart';

class CustomLottoScreen extends StatefulWidget {
  const CustomLottoScreen({Key? key}) : super(key: key);

  @override
  State<CustomLottoScreen> createState() => _CustomLottoScreenState();
}

class _CustomLottoScreenState extends State<CustomLottoScreen> {
  int _numberRange = 49;
  int _numbersToSelect = 6;
  int _bonusNumberRange = 10;
  int _bonusNumbersToSelect = 2;
  int _tipCount = 5;
  
  final List<List<bool>> _selectedNumbers = [];
  final List<List<bool>> _selectedBonusNumbers = [];
  final List<List<int>> _generatedTips = [];
  final List<List<int>> _generatedBonusTips = [];
  final List<bool> _tipGenerated = [];

  @override
  void initState() {
    super.initState();
    _resetArrays();
  }

  void _resetArrays() {
    _selectedNumbers.clear();
    _selectedBonusNumbers.clear();
    _generatedTips.clear();
    _generatedBonusTips.clear();
    _tipGenerated.clear();
    
    for (int i = 0; i < _tipCount; i++) {
      _selectedNumbers.add(List.filled(_numberRange, false));
      _selectedBonusNumbers.add(List.filled(_bonusNumberRange, false));
      _generatedTips.add([]);
      _generatedBonusTips.add([]);
      _tipGenerated.add(false);
    }
  }

  void _updateConfiguration() {
    setState(() {
      _resetArrays();
    });
  }

  void _generateTip(int tipIndex) {
    if (_tipGenerated[tipIndex]) {
      // Löschen
      setState(() {
        for (int i = 0; i < _numberRange; i++) {
          _selectedNumbers[tipIndex][i] = false;
        }
        for (int i = 0; i < _bonusNumberRange; i++) {
          _selectedBonusNumbers[tipIndex][i] = false;
        }
        _generatedTips[tipIndex].clear();
        _generatedBonusTips[tipIndex].clear();
        _tipGenerated[tipIndex] = false;
      });
    } else {
      // Generieren
      setState(() {
        _generatedTips[tipIndex].clear();
        final mainNumbers = List.generate(_numberRange, (index) => index + 1)..shuffle();
        final selectedMain = mainNumbers.take(_numbersToSelect).toList()..sort();
        
        for (final number in selectedMain) {
          _selectedNumbers[tipIndex][number - 1] = true;
          _generatedTips[tipIndex].add(number);
        }

        _generatedBonusTips[tipIndex].clear();
        if (_bonusNumbersToSelect > 0) {
          final bonusNumbers = List.generate(_bonusNumberRange, (index) => index + 1)..shuffle();
          final selectedBonus = bonusNumbers.take(_bonusNumbersToSelect).toList()..sort();
          
          for (final number in selectedBonus) {
            _selectedBonusNumbers[tipIndex][number - 1] = true;
            _generatedBonusTips[tipIndex].add(number);
          }
        }
        
        _tipGenerated[tipIndex] = true;
      });
    }
  }

  void _toggleNumber(int tipIndex, int number, bool isBonus) {
    setState(() {
      if (!isBonus) {
        _selectedNumbers[tipIndex][number] = !_selectedNumbers[tipIndex][number];
        if (_selectedNumbers[tipIndex][number]) {
          _generatedTips[tipIndex].add(number + 1);
          _generatedTips[tipIndex].sort();
        } else {
          _generatedTips[tipIndex].remove(number + 1);
        }
      } else {
        _selectedBonusNumbers[tipIndex][number] = !_selectedBonusNumbers[tipIndex][number];
        if (_selectedBonusNumbers[tipIndex][number]) {
          _generatedBonusTips[tipIndex].add(number + 1);
          _generatedBonusTips[tipIndex].sort();
        } else {
          _generatedBonusTips[tipIndex].remove(number + 1);
        }
      }
    });
  }

  Widget _buildConfigurationPanel(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konfiguration:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[800]),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildNumberConfig('Zahlenbereich:', _numberRange, 10, 100, (value) {
                _numberRange = value;
                _updateConfiguration();
              }),
              _buildNumberConfig('Zahlen pro Tipp:', _numbersToSelect, 1, 10, (value) {
                _numbersToSelect = value;
                _updateConfiguration();
              }),
              _buildNumberConfig('Bonusbereich:', _bonusNumberRange, 0, 20, (value) {
                _bonusNumberRange = value;
                _updateConfiguration();
              }),
              _buildNumberConfig('Bonus pro Tipp:', _bonusNumbersToSelect, 0, 5, (value) {
                _bonusNumbersToSelect = value;
                _updateConfiguration();
              }),
              _buildNumberConfig('Anzahl Tipps:', _tipCount, 1, 12, (value) {
                _tipCount = value;
                _updateConfiguration();
              }),
            ],
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _updateConfiguration,
            icon: Icon(Icons.refresh),
            label: Text('Konfiguration anwenden'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberConfig(String label, int value, int min, int max, ValueChanged<int> onChanged) {
    return Container(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, size: 16),
                onPressed: value > min ? () => onChanged(value - 1) : null,
                padding: EdgeInsets.zero,
              ),
              Expanded(
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, size: 16),
                onPressed: value < max ? () => onChanged(value + 1) : null,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberGrid(int tipIndex, bool isBonus, BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final numberRange = isBonus ? _bonusNumberRange : _numberRange;
    final numbersPerRow = isBonus ? 4 : 7;
    
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isBonus ? Colors.orange[300]! : Colors.green[300]!),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: numbersPerRow,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1.0,
        ),
        itemCount: numberRange,
        itemBuilder: (context, index) {
          final number = index + 1;
          final isSelected = isBonus 
              ? _selectedBonusNumbers[tipIndex][index]
              : _selectedNumbers[tipIndex][index];
          return GestureDetector(
            onTap: () => _toggleNumber(tipIndex, index, isBonus),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected 
                    ? (isBonus ? Colors.orange[800] : Colors.green[800])
                    : Colors.white,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: isPortrait ? (isBonus ? 12 : 10) : (isBonus ? 10 : 8),
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

  Widget _buildTipSection(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _tipCount,
      itemBuilder: (context, tipIndex) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tipp ${tipIndex + 1}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text('$_numbersToSelect aus $_numberRange:', style: TextStyle(fontSize: 10)),
              SizedBox(height: 4),
              _buildNumberGrid(tipIndex, false, context),
              if (_bonusNumbersToSelect > 0) ...[
                SizedBox(height: 8),
                Text('$_bonusNumbersToSelect Bonus aus $_bonusNumberRange:', style: TextStyle(fontSize: 10)),
                SizedBox(height: 4),
                _buildNumberGrid(tipIndex, true, context),
              ],
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: () => _generateTip(tipIndex),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tipGenerated[tipIndex] ? Colors.red : Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    _tipGenerated[tipIndex] ? 'LÖSCHEN' : 'GENERIEREN',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
        title: Text('Custom Lotto'),
        backgroundColor: Colors.green[400],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isPortrait ? 16 : 8),
          child: Column(
            children: [
              _buildConfigurationPanel(context),
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
                        for (int i = 0; i < _tipCount; i++) {
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
                        for (int i = 0; i < _tipCount; i++) {
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
