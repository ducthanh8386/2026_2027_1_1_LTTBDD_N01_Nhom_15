import 'package:flutter/material.dart';

/// ExerciseLibraryScreen stub owned by Partner B (Module B1).
///
/// B will implement search bar, body part filters, and exercise list here.
class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectMode ? 'Select Exercises' : 'Exercise Library'),
      ),
      body: const Center(
        child: Text('Exercise Library Stub (Partner B - B1)'),
      ),
    );
  }
}
