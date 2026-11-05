import 'package:flutter/foundation.dart';

import '../models/exercise.dart';

/// ExerciseProvider stub owned by Partner B (Module B1).
///
/// B will implement loading from ExerciseRepository, debounce query,
/// body part filtering, and caching in B1.
class ExerciseProvider extends ChangeNotifier {
  final List<Exercise> _exercises = [];
  final List<String> _bodyParts = [];
  String? _selectedBodyPart;
  String _query = '';
  final bool _isLoading = false;
  String? _error;

  List<Exercise> get exercises => List.unmodifiable(_exercises);
  List<String> get bodyParts => List.unmodifiable(_bodyParts);
  String? get selectedBodyPart => _selectedBodyPart;
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    // Stub implementation for contract-v1
  }

  void setBodyPart(String? v) {
    _selectedBodyPart = v;
    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  Exercise? byId(int id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

