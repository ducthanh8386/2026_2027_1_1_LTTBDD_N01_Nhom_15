import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/repositories/exercise_repository.dart';
import '../models/exercise.dart';

/// ExerciseProvider owned by Partner B (Module B1).
///
/// Manages state for the exercise library, search query with debounce,
/// body part filtering, and in-memory caching for instant byId lookups.
class ExerciseProvider extends ChangeNotifier {
  final ExerciseRepository _repository;

  final List<Exercise> _allExercises = [];
  final Map<int, Exercise> _cacheById = {};
  List<Exercise> _filteredExercises = [];
  List<String> _bodyParts = [];

  String? _selectedBodyPart;
  String _query = '';
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;
  Timer? _debounceTimer;

  ExerciseProvider({ExerciseRepository? repository})
      : _repository = repository ?? ExerciseRepository();

  List<Exercise> get exercises => List.unmodifiable(_filteredExercises);
  List<String> get bodyParts => List.unmodifiable(_bodyParts);
  String? get selectedBodyPart => _selectedBodyPart;
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final list = await _repository.findAll();
      final parts = await _repository.distinctBodyParts();

      _allExercises.clear();
      _cacheById.clear();
      for (final ex in list) {
        _allExercises.add(ex);
        if (ex.id != null) {
          _cacheById[ex.id!] = ex;
        }
      }
      _bodyParts = parts;
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void setBodyPart(String? v) {
    if (_selectedBodyPart == v) return;
    _selectedBodyPart = (v != null && v.trim().isNotEmpty && v.toLowerCase() != 'all') ? v : null;
    _applyFilters();
    _safeNotifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _applyFilters();
      _safeNotifyListeners();
    });
  }

  void _applyFilters() {
    final q = _query.trim().toLowerCase();
    final noDiacriticQ = ExerciseRepository._stripDiacritics(q);

    _filteredExercises = _allExercises.where((ex) {
      if (_selectedBodyPart != null &&
          ex.bodyPart.toLowerCase() != _selectedBodyPart!.toLowerCase()) {
        return false;
      }

      if (q.isNotEmpty) {
        final en = ex.nameEn.toLowerCase();
        final vi = ex.nameVi.toLowerCase();
        final viNoDiacritic = ExerciseRepository._stripDiacritics(vi);
        final target = (ex.target ?? '').toLowerCase();

        final matches = en.contains(q) ||
            vi.contains(q) ||
            viNoDiacritic.contains(noDiacriticQ) ||
            target.contains(q);

        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  Exercise? byId(int id) {
    if (_cacheById.containsKey(id)) {
      return _cacheById[id];
    }
    try {
      return _allExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
