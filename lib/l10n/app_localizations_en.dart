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
  String get progressTitle => 'Progress';

  @override
  String get progressWeightTab => 'Weight';

  @override
  String get progressVolumeTab => 'Volume';

  @override
  String get progressDays7 => '7 Days';

  @override
  String get progressDays30 => '30 Days';

  @override
  String get progressAll => 'All';

  @override
  String get progressAddWeight => 'Log Weight';

  @override
  String get progressWeightInputLabel => 'Weight (kg)';

  @override
  String get progressDateLabel => 'Date';

  @override
  String get progressSaveWeight => 'Save Weight';

  @override
  String get progressWeightSaved => 'Weight recorded successfully';

  @override
  String get progressNoWeightData => 'No weight records yet';

  @override
  String get progressNoWeightSub =>
      'Tap the button below to log your first weight.';

  @override
  String get progressCurrentWeight => 'Current';

  @override
  String get progressChange => 'Change';

  @override
  String get progressMinMax => 'Min / Max';

  @override
  String get progressInvalidWeight =>
      'Please enter a valid weight between 20 and 300 kg';

  @override
  String get progressVolumeChartTitle => 'Workout Volume';

  @override
  String get progressNoVolumeData => 'No volume records yet';

  @override
  String get progressNoVolumeSub =>
      'Completed workouts will automatically generate volume charts.';

  @override
  String get progressWeeklySummary => 'Weekly Summary';

  @override
  String get progressWeeklySessions => 'Sessions';

  @override
  String get progressWeeklyVolume => 'Volume';

  @override
  String get progressWeeklyKcal => 'Calories';

  @override
  String get progressTotalVolume => 'Total Volume';

  @override
  String get progressAvgVolume => 'Avg / Session';

  @override
  String get progressMaxVolume => 'Max Session';

  @override
  String get progressMaxWeightTitle => 'Max Weight By Exercise';

  @override
  String get progressSelectExercise => 'Select Exercise';

  @override
  String get historyTitle => 'Workout History';

  @override
  String get historyEmptyTitle => 'No Workout History';

  @override
  String get historyEmptySubtitle =>
      'Completed workouts will appear here. Start training today!';

  @override
  String get historyFreeWorkout => 'Free Workout';

  @override
  String get historyDeleteTitle => 'Delete Session';

  @override
  String get historyDeleteConfirm =>
      'Are you sure you want to delete this workout session?';

  @override
  String get historyDetailTitle => 'Workout Detail';

  @override
  String get historySets => 'sets';

  @override
  String get historyMinutes => 'min';

  @override
  String get historyVolume => 'Volume';

  @override
  String get historyTotalSets => 'Total Sets';

  @override
  String get historyDuration => 'Duration';

  @override
  String get historyExerciseSets => 'Sets Performed';

  @override
  String historySetNumber(int number) {
    return 'Set $number';
  }

  @override
  String get exerciseLibraryTitle => 'Exercise Library';

  @override
  String get exerciseSelectTitle => 'Select Exercises';

  @override
  String get exerciseSearchPlaceholder => 'Search exercises...';

  @override
  String get exerciseFilterAll => 'All';

  @override
  String exerciseAddSelected(int count) {
    return 'Add ($count)';
  }

  @override
  String get exerciseDetailTitle => 'Exercise Detail';

  @override
  String get exerciseInstructions => 'Instructions';

  @override
  String get exerciseSecondaryMuscles => 'Secondary Muscles';

  @override
  String get exerciseTargetMuscle => 'Target';

  @override
  String get exerciseEquipment => 'Equipment';

  @override
  String get exerciseBodyPart => 'Body Part';

  @override
  String get exerciseNoExercises => 'No exercises found';

  @override
  String get exerciseCredit => 'Exercise data and media © Gym visual';

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

  @override
  String get nutritionTitle => 'Nutrition Diary';

  @override
  String get nutritionCalories => 'Calories';

  @override
  String get nutritionProtein => 'Protein';

  @override
  String get nutritionCarbs => 'Carbs';

  @override
  String get nutritionFat => 'Fat';

  @override
  String get nutritionTarget => 'Target';

  @override
  String get nutritionConsumed => 'Consumed';

  @override
  String get nutritionRemaining => 'Remaining';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snacks';

  @override
  String get addFood => 'Add Food';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get searchFood => 'Search Foods';

  @override
  String get barcodeScanner => 'Barcode Scanner';

  @override
  String get barcodePointCamera => 'Point camera at food barcode';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to scan barcodes.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get searchingProduct => 'Searching product...';

  @override
  String get productNotFound => 'Product not found on Open Food Facts.';

  @override
  String get networkError =>
      'Network error. Please check your internet connection.';

  @override
  String get timeoutError => 'Request timed out. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get foodDetails => 'Food Details';

  @override
  String get per100g => 'Per 100g';

  @override
  String get servingSize => 'Serving (g)';

  @override
  String get selectMeal => 'Select Meal';

  @override
  String get addToDiary => 'Add to Diary';

  @override
  String get foodAddedSuccess => 'Food added to diary';

  @override
  String get createManualFood => 'Create Food Item';

  @override
  String get foodName => 'Food Name';

  @override
  String get foodBrand => 'Brand (optional)';

  @override
  String get barcodeOptional => 'Barcode (optional)';

  @override
  String get caloriesPer100g => 'Calories (kcal / 100g)';

  @override
  String get proteinPer100g => 'Protein (g / 100g)';

  @override
  String get carbsPer100g => 'Carbs (g / 100g)';

  @override
  String get fatPer100g => 'Fat (g / 100g)';

  @override
  String get editGrams => 'Edit Grams';

  @override
  String get deleteFoodEntry => 'Delete Entry';

  @override
  String get deleteFoodConfirm => 'Remove this item from your diary?';

  @override
  String get noFoodInMeal => 'No food logged for this meal yet.';

  @override
  String get gramsPositiveRequired => 'Grams must be greater than 0';

  @override
  String get today => 'Today';

  @override
  String homeGreetingMorning(String name) {
    return 'Good morning, $name!';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Good afternoon, $name!';
  }

  @override
  String homeGreetingEvening(String name) {
    return 'Good evening, $name!';
  }

  @override
  String homeGreetingGeneric(String name) {
    return 'Hello, $name!';
  }

  @override
  String get homeWeeklyOverview => 'Weekly Overview';

  @override
  String get homeWeeklySessions => 'Sessions';

  @override
  String get homeWeeklyVolume => 'Volume';

  @override
  String get homeTodayCalories => 'Calories Today';

  @override
  String get homeTodayWorkout => 'Today\'s Workout';

  @override
  String get homeNoPlanYet => 'No workout plan yet';

  @override
  String get homeNoPlanSubtitle =>
      'Choose a sample plan or start a free workout session.';

  @override
  String get homeStartWorkout => 'Start Workout';

  @override
  String get homeContinueWorkout => 'Resume Workout';

  @override
  String get homeActiveSessionRunning => 'Active workout session in progress';

  @override
  String get homeFreeWorkoutPrompt => 'Start Free Workout';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homeQuickScanBarcode => 'Scan Food Barcode';

  @override
  String get homeQuickLogWeight => 'Log Weight';

  @override
  String get homeViewAllPlans => 'View Plans';

  @override
  String get homeUnitSessions => 'sessions';

  @override
  String homeTarget(String target) {
    return 'Target: $target';
  }

  @override
  String get profile => 'Profile';
}
