import 'package:flutter/foundation.dart';

import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  final bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> updateProfile(User updated) async {
    _currentUser = updated;
    notifyListeners();
  }

  void setUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
