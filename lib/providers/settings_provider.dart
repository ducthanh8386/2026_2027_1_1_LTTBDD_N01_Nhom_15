import 'package:flutter/material.dart';
import '../data/local/prefs_store.dart';

class SettingsProvider extends ChangeNotifier {
  final PrefsStore _prefsStore;
  Locale _locale = const Locale('vi');
  ThemeMode _themeMode = ThemeMode.system;

  SettingsProvider(this._prefsStore) {
    _loadSettings();
  }

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  void _loadSettings() {
    final savedLocale = _prefsStore.getLocale();
    if (savedLocale != null && (savedLocale == 'en' || savedLocale == 'vi')) {
      _locale = Locale(savedLocale);
    }

    final savedTheme = _prefsStore.getThemeMode();
    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale.languageCode == newLocale.languageCode) return;
    _locale = newLocale;
    await _prefsStore.setLocale(newLocale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    if (_locale.languageCode == 'vi') {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('vi'));
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';
    await _prefsStore.setThemeMode(modeString);
    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
