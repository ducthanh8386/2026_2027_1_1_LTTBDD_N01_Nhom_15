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

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get invalidEmailOrPassword => 'Invalid email or password';

  @override
  String get emailAlreadyInUse => 'Email is already registered';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get registerSuccess => 'Registration successful!';

  @override
  String get navHome => 'Home';

  @override
  String get navWorkout => 'Workout';

  @override
  String get navProgress => 'Progress';

  @override
  String get navNutrition => 'Nutrition';

  @override
  String get navSettings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get workoutPlans => 'Workout Plans';

  @override
  String get createPlan => 'Create Plan';

  @override
  String get editPlan => 'Edit Plan';

  @override
  String get deletePlan => 'Delete Plan';

  @override
  String get deletePlanConfirm => 'Are you sure you want to delete this plan?';

  @override
  String get planName => 'Plan Name';

  @override
  String get planNameRequired => 'Please enter plan name';

  @override
  String get planDescription => 'Description (optional)';

  @override
  String get addDay => 'Add Day';

  @override
  String get dayName => 'Day Name';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get savePlan => 'Save Plan';

  @override
  String get planSavedSuccess => 'Plan saved successfully';

  @override
  String get planDeletedSuccess => 'Plan deleted';

  @override
  String get samplePlans => 'Sample Plans';

  @override
  String get useSamplePlan => 'Use Sample Plan';

  @override
  String get samplePlanApplied => 'Sample plan applied successfully';

  @override
  String get planAtLeastOneDay => 'Plan must have at least one day';

  @override
  String get dayAtLeastOneExercise =>
      'Each day must have at least one exercise';

  @override
  String get invalidSetsOrReps => 'Sets and reps must be greater than 0';

  @override
  String get noPlansFound => 'No workout plans yet';

  @override
  String get noPlansSubtitle => 'Create your first plan or try a sample plan';

  @override
  String get historyScreenDisabled => 'Workout history will be available soon';

  @override
  String get deleteDayConfirm => 'Are you sure you want to delete this day?';

  @override
  String get noExercisesInDay =>
      'No exercises in this day yet. Tap \'Add Exercise\' to add some.';

  @override
  String get workoutHistory => 'Workout History';

  @override
  String get startWorkout => 'Start Workout';

  @override
  String get workoutSession => 'Workout Session';

  @override
  String get workoutCompleted => 'Workout Completed!';

  @override
  String get workoutSummary => 'Workout Summary';

  @override
  String get restTimer => 'Rest Time';

  @override
  String get skip => 'Skip';

  @override
  String get exitWorkout => 'Exit Workout?';

  @override
  String get exitWorkoutConfirm =>
      'Do you want to save logged sets or discard this workout?';

  @override
  String get continueWorkout => 'Continue';

  @override
  String get discardWorkout => 'Discard';

  @override
  String get saveAndFinish => 'Save & Finish';

  @override
  String get finishWorkout => 'Finish Workout';

  @override
  String get finishWorkoutConfirm =>
      'Are you sure you want to finish this workout?';

  @override
  String get invalidWeight => 'Weight must be 0 or greater';

  @override
  String get exerciseOrder => 'Exercise';

  @override
  String get target => 'Target';

  @override
  String get completedSets => 'Completed Sets';

  @override
  String get addSet => 'Add Set';

  @override
  String get deleteSet => 'Delete Set';

  @override
  String get previousExercise => 'Previous';

  @override
  String get nextExercise => 'Next';

  @override
  String get totalDuration => 'Duration';

  @override
  String get totalVolume => 'Total Volume';

  @override
  String get totalSets => 'Total Sets';

  @override
  String get totalExercises => 'Exercises';

  @override
  String get sessionDetails => 'Session Details';

  @override
  String get done => 'Done';

  @override
  String get freeWorkout => 'Free Workout';

  @override
  String get selectDayToStart => 'Select a day to start workout';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get backToHome => 'Back to Home';
}
