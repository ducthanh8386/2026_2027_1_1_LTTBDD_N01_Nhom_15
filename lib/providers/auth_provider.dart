import 'package:flutter/foundation.dart';

import '../data/local/prefs_store.dart';
import '../data/repositories/user_repository.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepo;
  final PrefsStore? _prefsStore;

  User? _currentUser;
  bool _isLoading = false;
  bool _isRestoring = true;
  String? _error;

  AuthProvider({
    AuthService? authService,
    UserRepository? userRepo,
    this._prefsStore,
  })  : _authService = authService ?? AuthService(),
        _userRepo = userRepo ?? UserRepository();

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isRestoring => _isRestoring;
  String? get error => _error;

  /// Restores session on app startup from SharedPreferences
  Future<void> restoreSession() async {
    _isRestoring = true;
    notifyListeners();

    try {
      final userId = _prefsStore?.getUserId();
      if (userId != null) {
        final user = await _userRepo.findById(userId);
        _currentUser = user;
      }
    } catch (e) {
      debugPrint('Session restore error: $e');
      _currentUser = null;
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      _currentUser = user;
      if (user.id != null) {
        await _prefsStore?.setUserId(user.id);
      }
      return true;
    } on DuplicateEmailException catch (e) {
      _error = e.message;
      return false;
    } catch (e, stack) {
      debugPrint('Register error: $e\n$stack');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );
      _currentUser = user;
      if (user.id != null) {
        await _prefsStore?.setUserId(user.id);
      }
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e, stack) {
      debugPrint('Login error: $e\n$stack');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates profile in SQLite and local state (contract requirement)
  Future<void> updateProfile(User updated) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userRepo.update(updated);
      _currentUser = updated;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deletes user workout plans, sessions, weights, and food logs, keeping the user account
  Future<void> deleteMyData() async {
    if (_currentUser?.id == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userRepo.deleteUserData(_currentUser!.id!);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs out and clears persisted user session
  Future<void> logout() async {
    _currentUser = null;
    _error = null;
    await _prefsStore?.clearAuth();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
