// Lotto 6aus49 Screen - NUR Animationen korrigiert, Design unverändert
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Lotto6Aus49Screen extends StatefulWidget {
  const Lotto6Aus49Screen({Key? key}) : super(key: key);

  @override
  _Lotto6Aus49ScreenState createState() => _Lotto6Aus49ScreenState();
}

class _Lotto6Aus49ScreenState extends State<Lotto6Aus49Screen> {
  List<int> generatedNumbers = [];
  int superzahl = 0;
  bool isGenerating = false;
  List<int> currentAnimationNumbers = [];
  int currentSuperzahlAnimation = 0;
  bool animationCompleted = false;
  List<int> selectedNumbers = [];
  bool canInteract = true;

  // SUPERZAHL FIX: Lauflicht bleibt auf finaler Zahl stehen
  Future<void> _animateSuperzahl() async {
    final random = Random();
    int cycles = 3;
    int finalSuperzahl = random.nextInt(10);
    
    for (int cycle = 0; cycle < cycles; cycle++) {
      for (int i = 0; i < 10; i++) {
        if (mounted) {
          setState(() {
            currentSuperzahlAnimation = i;
          });
        }
        // FINAL FIX: Letzter Durchlauf bleibt auf der finalen Zahl stehen
        if (cycle == cycles - 1 && i == finalSuperzahl) {
          await Future.delayed(const Duration(milliseconds: 300));
          break; // Beende auf der finalen Zahl
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    
    if (mounted) {
      setState(() {
        superzahl = finalSuperzahl;
        currentSuperzahlAnimation = finalSuperzahl;
      });
    }
  }

  // HAUPTZAHLEN FIX: 2x beschleunigt
  Future<void> _animateMainNumbers() async {
    final random = Random();
    List<int> finalNumbers = [];
    
    while (finalNumbers.length < 6) {
      int num = random.nextInt(49) + 1;
      if (!finalNumbers.contains(num)) {
        finalNumbers.add(num);
      }
    }
    finalNumbers.sort();

    // FIX: 2x schneller - nur 10 Zyklen à 25ms
    for (int i = 0; i < 10; i++) {
      if (mounted) {
        setState(() {
          currentAnimationNumbers = List.generate(6, (_) => random.nextInt(49) + 1);
        });
      }
      await Future.delayed(const Duration(milliseconds: 25));
    }

    if (mounted) {
      setState(() {
        generatedNumbers = finalNumbers;
        currentAnimationNumbers = finalNumbers;
        animationCompleted = true;
        canInteract = true;
      });
    }
  }

  void _generateNumbers() async {
    if (isGenerating) return;
    
    setState(() {
      isGenerating = true;
      generatedNumbers = [];
      superzahl = 0;
      currentAnimationNumbers = [];
      animationCompleted = false;
      canInteract = false;
      selectedNumbers = []; // Kreuz auf 49 löschen
    });

    await _animateSuperzahl();
    await _animateMainNumbers();

    setState(() {
      isGenerating = false;
    });
  }

  void _onNumberTap(int number) {
    if (!canInteract || isGenerating) return;
    
    setState(() {
      if (selectedNumbers.contains(number)) {
        selectedNumbers.remove(number);
      } else if (selectedNumbers.length < 6) {
        selectedNumbers.add(number);
      }
    });
  }

  void _onSuperzahlTap() {
    if (!animationCompleted || isGenerating) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Superzahl ändern'),
        content: Container(
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 10,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                setState(() {
                  superzahl = index;
                });
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: superzahl == index ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: superzahl == index ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuperzahlSection(Orientation orientation) {
    return GestureDetector(
      onTap: _onSuperzahlTap,
      child: Container(
        height: orientation == Orientation.portrait ? 60 : 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Superzahl',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isGenerating ? currentSuperzahlAnimation.toString() : superzahl.toString(),
              style: TextStyle(
                fontSize: orientation == Orientation.portrait ? 28 : 22,
                color: isGenerating ? Colors.orange : Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumbersGrid(Orientation orientation) {
    int crossAxisCount = orientation == Orientation.portrait ? 7 : 10;
    double aspectRatio = orientation == Orientation.portrait ? 1.0 : 0.8;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: aspectRatio,
      ),
      itemCount: 49,
      itemBuilder: (context, index) {
        int number = index + 1;
        bool isGenerated = generatedNumbers.contains(number);
        bool isSelected = selectedNumbers.contains(number);
        bool isAnimating = currentAnimationNumbers.contains(number) && isGenerating;

        return GestureDetector(
          onTap: () => _onNumberTap(number),
          child: Container(
            decoration: BoxDecoration(
              color: isAnimating 
                ? Colors.orange 
                : isGenerated 
                  ? Colors.blue 
                  : isSelected 
                    ? Colors.green 
                    : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isGenerated ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: orientation == Orientation.portrait ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: isAnimating || isGenerated || isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneratedNumbersSection() {
    if (!animationCompleted) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deine Tipps:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              ...generatedNumbers.map((number) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              )).toList(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'S: $superzahl',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _generateNumbers,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          isGenerating ? 'Generiert...' : 'Zahlen generieren',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lotto 6aus49'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSuperzahlSection(orientation),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildNumbersGrid(orientation),
                ),
                _buildGeneratedNumbersSection(),
                _buildGenerateButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}
