import 'package:flutter/material.dart';

/// ExerciseDetailScreen stub owned by Partner B (Module B1).
///
/// B will implement animated GIF, instructions, and target muscles here.
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise #$exerciseId'),
      ),
      body: Center(
        child: Text('Exercise Detail Stub for ID $exerciseId (Partner B - B1)'),
      ),
    );
  }
}
