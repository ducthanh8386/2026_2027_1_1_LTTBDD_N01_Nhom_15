// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FitTrack';

  @override
  String get welcome => 'Welcome to FitTrack';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get currentLanguage => 'Current language: English';

  @override
  String get switchLanguage => 'Switch to Vietnamese';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get emptyStateTitle => 'No Data Found';

  @override
  String get emptyStateMessage => 'There is nothing here yet.';

  @override
  String get emailInvalid => 'Invalid email format';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get positiveNumberRequired => 'Please enter a positive number';

  @override
  String get fieldRequired => 'This field is required';
}
