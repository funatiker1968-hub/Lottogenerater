import 'package:flutter/material.dart';
import '../core/services/disclaimer_service.dart';

class DisclaimerDialog extends StatelessWidget {
  final VoidCallback onAccepted;
  final VoidCallback onRejected;

  const DisclaimerDialog({
    Key? key,
    required this.onAccepted,
    required this.onRejected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'HAFTUNGSAUSSCHLUSS & NUTZUNGSBEDINGUNGEN',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  DisclaimerService.getDisclaimerText(),
                  style: TextStyle(fontSize: 14, height: 1.4),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRejected,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('ABLEHNEN UND APP VERLASSEN'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccepted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('AKZEPTIEREN'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
