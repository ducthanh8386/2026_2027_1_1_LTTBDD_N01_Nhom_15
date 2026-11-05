import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'FitTrack'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FitTrack'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current language: English'**
  String get currentLanguage;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch to Vietnamese'**
  String get switchLanguage;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'There is nothing here yet.'**
  String get emptyStateMessage;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @positiveNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a positive number'**
  String get positiveNumberRequired;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidEmailOrPassword;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email is already registered'**
  String get emailAlreadyInUse;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registerSuccess;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get navWorkout;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get navNutrition;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @workoutPlans.
  ///
  /// In en, this message translates to:
  /// **'Workout Plans'**
  String get workoutPlans;

  /// No description provided for @createPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get createPlan;

  /// No description provided for @editPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit Plan'**
  String get editPlan;

  /// No description provided for @deletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete Plan'**
  String get deletePlan;

  /// No description provided for @deletePlanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plan?'**
  String get deletePlanConfirm;

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get planName;

  /// No description provided for @planNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter plan name'**
  String get planNameRequired;

  /// No description provided for @planDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get planDescription;

  /// No description provided for @addDay.
  ///
  /// In en, this message translates to:
  /// **'Add Day'**
  String get addDay;

  /// No description provided for @dayName.
  ///
  /// In en, this message translates to:
  /// **'Day Name'**
  String get dayName;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @savePlan.
  ///
  /// In en, this message translates to:
  /// **'Save Plan'**
  String get savePlan;

  /// No description provided for @planSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan saved successfully'**
  String get planSavedSuccess;

  /// No description provided for @planDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Plan deleted'**
  String get planDeletedSuccess;

  /// No description provided for @samplePlans.
  ///
  /// In en, this message translates to:
  /// **'Sample Plans'**
  String get samplePlans;

  /// No description provided for @useSamplePlan.
  ///
  /// In en, this message translates to:
  /// **'Use Sample Plan'**
  String get useSamplePlan;

  /// No description provided for @samplePlanApplied.
  ///
  /// In en, this message translates to:
  /// **'Sample plan applied successfully'**
  String get samplePlanApplied;

  /// No description provided for @planAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Plan must have at least one day'**
  String get planAtLeastOneDay;

  /// No description provided for @dayAtLeastOneExercise.
  ///
  /// In en, this message translates to:
  /// **'Each day must have at least one exercise'**
  String get dayAtLeastOneExercise;

  /// No description provided for @invalidSetsOrReps.
  ///
  /// In en, this message translates to:
  /// **'Sets and reps must be greater than 0'**
  String get invalidSetsOrReps;

  /// No description provided for @noPlansFound.
  ///
  /// In en, this message translates to:
  /// **'No workout plans yet'**
  String get noPlansFound;

  /// No description provided for @noPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first plan or try a sample plan'**
  String get noPlansSubtitle;

  /// No description provided for @historyScreenDisabled.
  ///
  /// In en, this message translates to:
  /// **'Workout history will be available soon'**
  String get historyScreenDisabled;

  /// No description provided for @deleteDayConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this day?'**
  String get deleteDayConfirm;

  /// No description provided for @noExercisesInDay.
  ///
  /// In en, this message translates to:
  /// **'No exercises in this day yet. Tap \'Add Exercise\' to add some.'**
  String get noExercisesInDay;

  /// No description provided for @workoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// No description provided for @workoutSession.
  ///
  /// In en, this message translates to:
  /// **'Workout Session'**
  String get workoutSession;

  /// No description provided for @workoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workout Completed!'**
  String get workoutCompleted;

  /// No description provided for @workoutSummary.
  ///
  /// In en, this message translates to:
  /// **'Workout Summary'**
  String get workoutSummary;

  /// No description provided for @restTimer.
  ///
  /// In en, this message translates to:
  /// **'Rest Time'**
  String get restTimer;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @exitWorkout.
  ///
  /// In en, this message translates to:
  /// **'Exit Workout?'**
  String get exitWorkout;

  /// No description provided for @exitWorkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save logged sets or discard this workout?'**
  String get exitWorkoutConfirm;

  /// No description provided for @continueWorkout.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueWorkout;

  /// No description provided for @discardWorkout.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardWorkout;

  /// No description provided for @saveAndFinish.
  ///
  /// In en, this message translates to:
  /// **'Save & Finish'**
  String get saveAndFinish;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get finishWorkout;

  /// No description provided for @finishWorkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish this workout?'**
  String get finishWorkoutConfirm;

  /// No description provided for @invalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight must be 0 or greater'**
  String get invalidWeight;

  /// No description provided for @exerciseOrder.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseOrder;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @completedSets.
  ///
  /// In en, this message translates to:
  /// **'Completed Sets'**
  String get completedSets;

  /// No description provided for @addSet.
  ///
  /// In en, this message translates to:
  /// **'Add Set'**
  String get addSet;

  /// No description provided for @deleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete Set'**
  String get deleteSet;

  /// No description provided for @previousExercise.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousExercise;

  /// No description provided for @nextExercise.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextExercise;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get totalDuration;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get totalVolume;

  /// No description provided for @totalSets.
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get totalSets;

  /// No description provided for @totalExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get totalExercises;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get sessionDetails;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @freeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Free Workout'**
  String get freeWorkout;

  /// No description provided for @selectDayToStart.
  ///
  /// In en, this message translates to:
  /// **'Select a day to start workout'**
  String get selectDayToStart;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
