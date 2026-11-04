import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class PrefsStore {
  final SharedPreferences _prefs;

  PrefsStore(this._prefs);

  /// Factory helper to initialize PrefsStore asynchronously
  static Future<PrefsStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsStore(prefs);
  }

  /// Get stored language code ('en', 'vi', or null)
  String? getLocale() {
    return _prefs.getString(AppConstants.prefKeyLocale);
  }

  /// Save language code ('en', 'vi')
  Future<bool> setLocale(String languageCode) {
    return _prefs.setString(AppConstants.prefKeyLocale, languageCode);
  }

  /// Get stored theme mode ('system', 'light', 'dark', or null)
  String? getThemeMode() {
    return _prefs.getString(AppConstants.prefKeyThemeMode);
  }

  /// Save theme mode
  Future<bool> setThemeMode(String mode) {
    return _prefs.setString(AppConstants.prefKeyThemeMode, mode);
  }

  /// Get authenticated user ID
  int? getUserId() {
    return _prefs.getInt(AppConstants.prefKeyUserId);
  }

  /// Save authenticated user ID
  Future<bool> setUserId(int? userId) {
    if (userId == null) {
      return _prefs.remove(AppConstants.prefKeyUserId);
    }
    return _prefs.setInt(AppConstants.prefKeyUserId, userId);
  }

  /// Clear authentication session
  Future<bool> clearAuth() {
    return _prefs.remove(AppConstants.prefKeyUserId);
  }
}

