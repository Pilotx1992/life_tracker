import 'package:flutter/material.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      body: const Center(
        child: Text('Medication tracking coming soon'),
      ),
    );
  }
}
