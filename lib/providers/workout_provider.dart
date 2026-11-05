import 'package:flutter/foundation.dart';

class WorkoutProvider extends ChangeNotifier {
  final bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
}
