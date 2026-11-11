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

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @progressWeightTab.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get progressWeightTab;

  /// No description provided for @progressVolumeTab.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get progressVolumeTab;

  /// No description provided for @progressDays7.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get progressDays7;

  /// No description provided for @progressDays30.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get progressDays30;

  /// No description provided for @progressAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get progressAll;

  /// No description provided for @progressAddWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get progressAddWeight;

  /// No description provided for @progressWeightInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get progressWeightInputLabel;

  /// No description provided for @progressDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get progressDateLabel;

  /// No description provided for @progressSaveWeight.
  ///
  /// In en, this message translates to:
  /// **'Save Weight'**
  String get progressSaveWeight;

  /// No description provided for @progressWeightSaved.
  ///
  /// In en, this message translates to:
  /// **'Weight recorded successfully'**
  String get progressWeightSaved;

  /// No description provided for @progressNoWeightData.
  ///
  /// In en, this message translates to:
  /// **'No weight records yet'**
  String get progressNoWeightData;

  /// No description provided for @progressNoWeightSub.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to log your first weight.'**
  String get progressNoWeightSub;

  /// No description provided for @progressCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get progressCurrentWeight;

  /// No description provided for @progressChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get progressChange;

  /// No description provided for @progressMinMax.
  ///
  /// In en, this message translates to:
  /// **'Min / Max'**
  String get progressMinMax;

  /// No description provided for @progressInvalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight between 20 and 300 kg'**
  String get progressInvalidWeight;

  /// No description provided for @progressVolumeChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Volume'**
  String get progressVolumeChartTitle;

  /// No description provided for @progressNoVolumeData.
  ///
  /// In en, this message translates to:
  /// **'No volume records yet'**
  String get progressNoVolumeData;

  /// No description provided for @progressNoVolumeSub.
  ///
  /// In en, this message translates to:
  /// **'Completed workouts will automatically generate volume charts.'**
  String get progressNoVolumeSub;

  /// No description provided for @progressWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get progressWeeklySummary;

  /// No description provided for @progressWeeklySessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get progressWeeklySessions;

  /// No description provided for @progressWeeklyVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get progressWeeklyVolume;

  /// No description provided for @progressWeeklyKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get progressWeeklyKcal;

  /// No description provided for @progressTotalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get progressTotalVolume;

  /// No description provided for @progressAvgVolume.
  ///
  /// In en, this message translates to:
  /// **'Avg / Session'**
  String get progressAvgVolume;

  /// No description provided for @progressMaxVolume.
  ///
  /// In en, this message translates to:
  /// **'Max Session'**
  String get progressMaxVolume;

  /// No description provided for @progressMaxWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Max Weight By Exercise'**
  String get progressMaxWeightTitle;

  /// No description provided for @progressSelectExercise.
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get progressSelectExercise;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Workout History'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completed workouts will appear here. Start training today!'**
  String get historyEmptySubtitle;

  /// No description provided for @historyFreeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Free Workout'**
  String get historyFreeWorkout;

  /// No description provided for @historyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Session'**
  String get historyDeleteTitle;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this workout session?'**
  String get historyDeleteConfirm;

  /// No description provided for @historyDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Detail'**
  String get historyDetailTitle;

  /// No description provided for @historySets.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get historySets;

  /// No description provided for @historyMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get historyMinutes;

  /// No description provided for @historyVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get historyVolume;

  /// No description provided for @historyTotalSets.
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get historyTotalSets;

  /// No description provided for @historyDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get historyDuration;

  /// No description provided for @historyExerciseSets.
  ///
  /// In en, this message translates to:
  /// **'Sets Performed'**
  String get historyExerciseSets;

  /// No description provided for @historySetNumber.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String historySetNumber(int number);

  /// No description provided for @exerciseLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exerciseLibraryTitle;

  /// No description provided for @exerciseSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Exercises'**
  String get exerciseSelectTitle;

  /// No description provided for @exerciseSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get exerciseSearchPlaceholder;

  /// No description provided for @exerciseFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get exerciseFilterAll;

  /// No description provided for @exerciseAddSelected.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String exerciseAddSelected(int count);

  /// No description provided for @exerciseDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Detail'**
  String get exerciseDetailTitle;

  /// No description provided for @exerciseInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get exerciseInstructions;

  /// No description provided for @exerciseSecondaryMuscles.
  ///
  /// In en, this message translates to:
  /// **'Secondary Muscles'**
  String get exerciseSecondaryMuscles;

  /// No description provided for @exerciseTargetMuscle.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get exerciseTargetMuscle;

  /// No description provided for @exerciseEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get exerciseEquipment;

  /// No description provided for @exerciseBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Body Part'**
  String get exerciseBodyPart;

  /// No description provided for @exerciseNoExercises.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get exerciseNoExercises;

  /// No description provided for @exerciseCredit.
  ///
  /// In en, this message translates to:
  /// **'Exercise data and media © Gym visual'**
  String get exerciseCredit;

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

  /// No description provided for @nutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Diary'**
  String get nutritionTitle;

  /// No description provided for @nutritionCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get nutritionCalories;

  /// No description provided for @nutritionProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get nutritionProtein;

  /// No description provided for @nutritionCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get nutritionCarbs;

  /// No description provided for @nutritionFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get nutritionFat;

  /// No description provided for @nutritionTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get nutritionTarget;

  /// No description provided for @nutritionConsumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get nutritionConsumed;

  /// No description provided for @nutritionRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get nutritionRemaining;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get mealSnack;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFood;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// No description provided for @searchFood.
  ///
  /// In en, this message translates to:
  /// **'Search Foods'**
  String get searchFood;

  /// No description provided for @barcodeScanner.
  ///
  /// In en, this message translates to:
  /// **'Barcode Scanner'**
  String get barcodeScanner;

  /// No description provided for @barcodePointCamera.
  ///
  /// In en, this message translates to:
  /// **'Point camera at food barcode'**
  String get barcodePointCamera;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan barcodes.'**
  String get cameraPermissionRequired;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @searchingProduct.
  ///
  /// In en, this message translates to:
  /// **'Searching product...'**
  String get searchingProduct;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found on Open Food Facts.'**
  String get productNotFound;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get timeoutError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @foodDetails.
  ///
  /// In en, this message translates to:
  /// **'Food Details'**
  String get foodDetails;

  /// No description provided for @per100g.
  ///
  /// In en, this message translates to:
  /// **'Per 100g'**
  String get per100g;

  /// No description provided for @servingSize.
  ///
  /// In en, this message translates to:
  /// **'Serving (g)'**
  String get servingSize;

  /// No description provided for @selectMeal.
  ///
  /// In en, this message translates to:
  /// **'Select Meal'**
  String get selectMeal;

  /// No description provided for @addToDiary.
  ///
  /// In en, this message translates to:
  /// **'Add to Diary'**
  String get addToDiary;

  /// No description provided for @foodAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Food added to diary'**
  String get foodAddedSuccess;

  /// No description provided for @createManualFood.
  ///
  /// In en, this message translates to:
  /// **'Create Food Item'**
  String get createManualFood;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodName;

  /// No description provided for @foodBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get foodBrand;

  /// No description provided for @barcodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Barcode (optional)'**
  String get barcodeOptional;

  /// No description provided for @caloriesPer100g.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal / 100g)'**
  String get caloriesPer100g;

  /// No description provided for @proteinPer100g.
  ///
  /// In en, this message translates to:
  /// **'Protein (g / 100g)'**
  String get proteinPer100g;

  /// No description provided for @carbsPer100g.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g / 100g)'**
  String get carbsPer100g;

  /// No description provided for @fatPer100g.
  ///
  /// In en, this message translates to:
  /// **'Fat (g / 100g)'**
  String get fatPer100g;

  /// No description provided for @editGrams.
  ///
  /// In en, this message translates to:
  /// **'Edit Grams'**
  String get editGrams;

  /// No description provided for @deleteFoodEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get deleteFoodEntry;

  /// No description provided for @deleteFoodConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this item from your diary?'**
  String get deleteFoodConfirm;

  /// No description provided for @noFoodInMeal.
  ///
  /// In en, this message translates to:
  /// **'No food logged for this meal yet.'**
  String get noFoodInMeal;

  /// No description provided for @gramsPositiveRequired.
  ///
  /// In en, this message translates to:
  /// **'Grams must be greater than 0'**
  String get gramsPositiveRequired;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}!'**
  String homeGreetingMorning(String name);

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}!'**
  String homeGreetingAfternoon(String name);

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}!'**
  String homeGreetingEvening(String name);

  /// No description provided for @homeGreetingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String homeGreetingGeneric(String name);

  /// No description provided for @homeWeeklyOverview.
  ///
  /// In en, this message translates to:
  /// **'Weekly Overview'**
  String get homeWeeklyOverview;

  /// No description provided for @homeWeeklySessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get homeWeeklySessions;

  /// No description provided for @homeWeeklyVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get homeWeeklyVolume;

  /// No description provided for @homeTodayCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories Today'**
  String get homeTodayCalories;

  /// No description provided for @homeTodayWorkout.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get homeTodayWorkout;

  /// No description provided for @homeNoPlanYet.
  ///
  /// In en, this message translates to:
  /// **'No workout plan yet'**
  String get homeNoPlanYet;

  /// No description provided for @homeNoPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a sample plan or start a free workout session.'**
  String get homeNoPlanSubtitle;

  /// No description provided for @homeStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get homeStartWorkout;

  /// No description provided for @homeContinueWorkout.
  ///
  /// In en, this message translates to:
  /// **'Resume Workout'**
  String get homeContinueWorkout;

  /// No description provided for @homeActiveSessionRunning.
  ///
  /// In en, this message translates to:
  /// **'Active workout session in progress'**
  String get homeActiveSessionRunning;

  /// No description provided for @homeFreeWorkoutPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start Free Workout'**
  String get homeFreeWorkoutPrompt;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @homeQuickScanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Food Barcode'**
  String get homeQuickScanBarcode;

  /// No description provided for @homeQuickLogWeight.
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get homeQuickLogWeight;

  /// No description provided for @homeViewAllPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get homeViewAllPlans;

  /// No description provided for @homeUnitSessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get homeUnitSessions;

  /// No description provided for @homeTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {target}'**
  String homeTarget(String target);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @progressNoExerciseData.
  ///
  /// In en, this message translates to:
  /// **'No data recorded for this exercise in selected range'**
  String get progressNoExerciseData;

  /// No description provided for @exerciseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Exercise not found'**
  String get exerciseNotFound;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String profileUpdateError(String error);

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @goalLoseFat.
  ///
  /// In en, this message translates to:
  /// **'Lose Fat'**
  String get goalLoseFat;

  /// No description provided for @goalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get goalMaintain;

  /// No description provided for @goalBuildMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build Muscle'**
  String get goalBuildMuscle;

  /// No description provided for @profileAutoCalculate.
  ///
  /// In en, this message translates to:
  /// **'Auto Calculate'**
  String get profileAutoCalculate;

  /// No description provided for @settingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Personal Data?'**
  String get settingsDeleteTitle;

  /// No description provided for @settingsDeletePrompt.
  ///
  /// In en, this message translates to:
  /// **'This will wipe all weight records, workout history, custom plans, and restore initial state.'**
  String get settingsDeletePrompt;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmPrompt.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you absolutely sure?'**
  String get settingsDeleteConfirmPrompt;

  /// No description provided for @settingsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'All personal data has been wiped successfully.'**
  String get settingsDeleteSuccess;

  /// No description provided for @settingsDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error clearing data: {error}'**
  String settingsDeleteError(String error);

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get settingsLogoutConfirm;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @settingsTeamInfo.
  ///
  /// In en, this message translates to:
  /// **'Team & Project Info'**
  String get settingsTeamInfo;

  /// No description provided for @settingsTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Phenikaa University · Instructor: Dr. Nguyen Xuan Que'**
  String get settingsTeamSubtitle;

  /// No description provided for @settingsCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Data & Media Attribution'**
  String get settingsCreditsTitle;

  /// No description provided for @settingsCreditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'hasaneyldrm / Gym Visual / Open Food Facts'**
  String get settingsCreditsSubtitle;

  /// No description provided for @teamLinkError.
  ///
  /// In en, this message translates to:
  /// **'Could not open link: {url}'**
  String teamLinkError(String url);

  /// No description provided for @profileBodyInfo.
  ///
  /// In en, this message translates to:
  /// **'Body Information'**
  String get profileBodyInfo;

  /// No description provided for @profileHeightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get profileHeightCm;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @profileFitnessGoal.
  ///
  /// In en, this message translates to:
  /// **'Fitness Goal'**
  String get profileFitnessGoal;

  /// No description provided for @profileActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Daily Activity Level'**
  String get profileActivityLevel;

  /// No description provided for @profileDailyCalorieTarget.
  ///
  /// In en, this message translates to:
  /// **'Daily Calorie Target'**
  String get profileDailyCalorieTarget;

  /// No description provided for @profileCalorieTargetUnit.
  ///
  /// In en, this message translates to:
  /// **'Calorie Target (kcal/day)'**
  String get profileCalorieTargetUnit;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get profileSave;

  /// No description provided for @profileMifflinFormula.
  ///
  /// In en, this message translates to:
  /// **'* Mifflin-St Jeor formula (Am J Clin Nutr 1990)'**
  String get profileMifflinFormula;

  /// No description provided for @profileEditPrompt.
  ///
  /// In en, this message translates to:
  /// **'Edit profile & body metrics →'**
  String get profileEditPrompt;

  /// No description provided for @settingsAppearanceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Language'**
  String get settingsAppearanceLanguage;

  /// No description provided for @settingsAccountData.
  ///
  /// In en, this message translates to:
  /// **'Account & Data'**
  String get settingsAccountData;

  /// No description provided for @settingsDeleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete Personal Data'**
  String get settingsDeleteAllData;

  /// No description provided for @settingsDeleteDataSub.
  ///
  /// In en, this message translates to:
  /// **'Wipe custom plans, workout history, weight, and meal logs'**
  String get settingsDeleteDataSub;

  /// No description provided for @exerciseNoInstructions.
  ///
  /// In en, this message translates to:
  /// **'No instructions available for this exercise.'**
  String get exerciseNoInstructions;

  /// No description provided for @teamUniversity.
  ///
  /// In en, this message translates to:
  /// **'University:'**
  String get teamUniversity;

  /// No description provided for @teamCourse.
  ///
  /// In en, this message translates to:
  /// **'Course:'**
  String get teamCourse;

  /// No description provided for @teamInstructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor:'**
  String get teamInstructor;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// No description provided for @teamCredits.
  ///
  /// In en, this message translates to:
  /// **'Data & Media Attributions'**
  String get teamCredits;

  /// No description provided for @teamExerciseDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Data & Media'**
  String get teamExerciseDataTitle;

  /// No description provided for @teamNutritionDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts Nutrition Database'**
  String get teamNutritionDataTitle;

  /// No description provided for @nutritionStandardFromOff.
  ///
  /// In en, this message translates to:
  /// **'Standard nutrients from Open Food Facts'**
  String get nutritionStandardFromOff;

  /// No description provided for @nutritionScanBarcodeSub.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode using camera'**
  String get nutritionScanBarcodeSub;

  /// No description provided for @nutritionManualEntrySub.
  ///
  /// In en, this message translates to:
  /// **'Enter food name and nutrients manually'**
  String get nutritionManualEntrySub;

  /// No description provided for @planPleaseReLogin.
  ///
  /// In en, this message translates to:
  /// **'Please re-login to save plan'**
  String get planPleaseReLogin;
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
