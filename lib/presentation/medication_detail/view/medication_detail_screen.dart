import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder detail screen; real content comes in a later step.
class MedicationDetailScreen extends StatelessWidget {
  final String id;

  const MedicationDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detail'),
      ),
      body: Center(child: Text('Medication id: $id')),
    );
  }
}
