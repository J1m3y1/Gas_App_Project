import 'package:flutter/material.dart';

class AcknowledgmentsPage extends StatelessWidget {
  const AcknowledgmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acknowledgments'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acknowledgments',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'We would like to thank all everyone who made this app possible.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Add text here',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ],
          ),

      ),
    );
  }
}
