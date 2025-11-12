import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  final String lotteryType;
  
  const StatisticsScreen({Key? key, required this.lotteryType}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final List<Map<String, dynamic>> _historicalData = [];
  final Map<int, int> _numberFrequency = {};
  final Map<int, int> _bonusNumberFrequency = {};

  @override
  void initState() {
    super.initState();
    _loadSampleData();
    _calculateFrequencies();
  }

  void _loadSampleData() {
    // Beispiel-Daten - später durch echte API ersetzen
    final now = DateTime.now();
    
    // Generiere Beispiel-Daten für die letzten 30 Tage
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final mainNumbers = _generateRandomNumbers(_getMainNumberRange(), _getNumbersToSelect());
      final bonusNumbers = _getBonusNumbersToSelect() > 0 
          ? _generateRandomNumbers(_getBonusNumberRange(), _getBonusNumbersToSelect())
          : [];
      
      _historicalData.add({
        'date': date,
        'mainNumbers': mainNumbers,
        'bonusNumbers': bonusNumbers,
      });
    }
  }

  void _calculateFrequencies() {
    _numberFrequency.clear();
    _bonusNumberFrequency.clear();
    
    for (final draw in _historicalData) {
      for (final number in draw['mainNumbers']) {
        _numberFrequency[number] = (_numberFrequency[number] ?? 0) + 1;
      }
      for (final number in draw['bonusNumbers']) {
        _bonusNumberFrequency[number] = (_bonusNumberFrequency[number] ?? 0) + 1;
      }
    }
  }

  List<int> _generateRandomNumbers(int range, int count) {
    final numbers = List.generate(range, (index) => index + 1)..shuffle();
    return numbers.take(count).toList()..sort();
  }

  int _getMainNumberRange() {
    switch (widget.lotteryType) {
      case '6aus49': return 49;
      case 'eurojackpot': return 50;
      case 'sayisal_loto': return 90;
      default: return 49;
    }
  }

  int _getNumbersToSelect() {
    switch (widget.lotteryType) {
      case '6aus49': return 6;
      case 'eurojackpot': return 5;
      case 'sayisal_loto': return 6;
      default: return 6;
    }
  }

  int _getBonusNumberRange() {
    switch (widget.lotteryType) {
      case '6aus49': return 10;
      case 'eurojackpot': return 12;
      case 'sayisal_loto': return 90;
      default: return 10;
    }
  }

  int _getBonusNumbersToSelect() {
    switch (widget.lotteryType) {
      case '6aus49': return 1;
      case 'eurojackpot': return 2;
      case 'sayisal_loto': return 1;
      default: return 1;
    }
  }

  String _getLotteryName() {
    switch (widget.lotteryType) {
      case '6aus49': return 'Lotto 6aus49';
      case 'eurojackpot': return 'Eurojackpot';
      case 'sayisal_loto': return 'Sayısal Loto';
      default: return 'Custom Lotto';
    }
  }

  Widget _buildFrequencyChart(bool isBonus) {
    final frequencyMap = isBonus ? _bonusNumberFrequency : _numberFrequency;
    final maxNumber = isBonus ? _getBonusNumberRange() : _getMainNumberRange();
    final maxFrequency = frequencyMap.values.isNotEmpty ? frequencyMap.values.reduce((a, b) => a > b ? a : b) : 1;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBonus ? 'Häufigkeit Bonus-Zahlen' : 'Häufigkeit Haupt-Zahlen',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(maxNumber, (index) {
              final number = index + 1;
              final frequency = frequencyMap[number] ?? 0;
              final percentage = (frequency / _historicalData.length) * 100;
              final intensity = frequency / maxFrequency;
              
              return Container(
                width: 40,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1 + intensity * 0.4),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      number.toString(),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${frequency}x',
                      style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 8, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHotColdNumbers() {
    final sortedNumbers = _numberFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final hotNumbers = sortedNumbers.take(5).map((e) => e.key).toList();
    final coldNumbers = sortedNumbers.reversed.take(5).map((e) => e.key).toList();
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hot & Cold Zahlen',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('🔥 Heiß', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: hotNumbers.map((number) => Chip(
                        label: Text(number.toString()),
                        backgroundColor: Colors.red[100],
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('❄️ Kalt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: coldNumbers.map((number) => Chip(
                        label: Text(number.toString()),
                        backgroundColor: Colors.blue[100],
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalList() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Letzte Ziehungen (${_historicalData.length})',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: _historicalData.length,
              itemBuilder: (context, index) {
                final draw = _historicalData[index];
                final date = draw['date'] as DateTime;
                final mainNumbers = (draw['mainNumbers'] as List<int>);
                final bonusNumbers = (draw['bonusNumbers'] as List<int>);
                
                return Container(
                  margin: EdgeInsets.only(bottom: 6),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${date.day}.${date.month}.${date.year}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          children: mainNumbers.map((number) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              number.toString(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )).toList(),
                        ),
                      ),
                      if (bonusNumbers.isNotEmpty) ...[
                        SizedBox(width: 8),
                        Wrap(
                          spacing: 4,
                          children: bonusNumbers.map((number) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              number.toString(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistik - ${_getLotteryName()}'),
        backgroundColor: Colors.purple[400],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.purple[700]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Daten von: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _buildFrequencyChart(false),
              SizedBox(height: 12),
              if (_getBonusNumbersToSelect() > 0) ...[
                _buildFrequencyChart(true),
                SizedBox(height: 12),
              ],
              _buildHotColdNumbers(),
              SizedBox(height: 12),
              _buildHistoricalList(),
            ],
          ),
        ),
      ),
    );
  }
}
