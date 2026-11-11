// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'FitTrack';

  @override
  String get progressTitle => 'Tiến độ';

  @override
  String get progressWeightTab => 'Cân nặng';

  @override
  String get progressVolumeTab => 'Khối lượng tạ';

  @override
  String get progressDays7 => '7 ngày';

  @override
  String get progressDays30 => '30 ngày';

  @override
  String get progressAll => 'Tất cả';

  @override
  String get progressAddWeight => 'Ghi cân nặng';

  @override
  String get progressWeightInputLabel => 'Cân nặng (kg)';

  @override
  String get progressDateLabel => 'Ngày ghi nhận';

  @override
  String get progressSaveWeight => 'Lưu cân nặng';

  @override
  String get progressWeightSaved => 'Đã ghi nhận cân nặng thành công';

  @override
  String get progressNoWeightData => 'Chưa có dữ liệu cân nặng';

  @override
  String get progressNoWeightSub =>
      'Chạm vào nút bên dưới để ghi nhận cân nặng đầu tiên.';

  @override
  String get progressCurrentWeight => 'Hiện tại';

  @override
  String get progressChange => 'Thay đổi';

  @override
  String get progressMinMax => 'Thấp / Cao';

  @override
  String get progressInvalidWeight =>
      'Vui lòng nhập cân nặng hợp lệ từ 20 đến 300 kg';

  @override
  String get progressVolumeChartTitle => 'Khối lượng tạ';

  @override
  String get progressNoVolumeData => 'Chưa có dữ liệu khối lượng';

  @override
  String get progressNoVolumeSub =>
      'Hoàn thành các buổi tập để xem biểu đồ khối lượng tự động.';

  @override
  String get progressWeeklySummary => 'Tổng kết tuần này';

  @override
  String get progressWeeklySessions => 'Số buổi';

  @override
  String get progressWeeklyVolume => 'Khối lượng';

  @override
  String get progressWeeklyKcal => 'Calories';

  @override
  String get progressTotalVolume => 'Tổng khối lượng';

  @override
  String get progressAvgVolume => 'Trung bình / Buổi';

  @override
  String get progressMaxVolume => 'Buổi cao nhất';

  @override
  String get progressMaxWeightTitle => 'Mức tạ cao nhất theo bài';

  @override
  String get progressSelectExercise => 'Chọn bài tập';

  @override
  String get historyTitle => 'Lịch sử tập luyện';

  @override
  String get historyEmptyTitle => 'Chưa có lịch sử tập';

  @override
  String get historyEmptySubtitle =>
      'Các buổi tập đã hoàn thành sẽ xuất hiện tại đây. Bắt đầu ngay hôm nay!';

  @override
  String get historyFreeWorkout => 'Buổi tập tự do';

  @override
  String get historyDeleteTitle => 'Xóa buổi tập';

  @override
  String get historyDeleteConfirm =>
      'Bạn có chắc chắn muốn xóa buổi tập này không?';

  @override
  String get historyDetailTitle => 'Chi tiết buổi tập';

  @override
  String get historySets => 'hiệp';

  @override
  String get historyMinutes => 'phút';

  @override
  String get historyVolume => 'Khối lượng';

  @override
  String get historyTotalSets => 'Tổng hiệp';

  @override
  String get historyDuration => 'Thời gian';

  @override
  String get historyExerciseSets => 'Chi tiết các hiệp';

  @override
  String historySetNumber(int number) {
    return 'Hiệp $number';
  }

  @override
  String get exerciseLibraryTitle => 'Thư viện bài tập';

  @override
  String get exerciseSelectTitle => 'Chọn bài tập';

  @override
  String get exerciseSearchPlaceholder => 'Tìm kiếm bài tập...';

  @override
  String get exerciseFilterAll => 'Tất cả';

  @override
  String exerciseAddSelected(int count) {
    return 'Thêm ($count)';
  }

  @override
  String get exerciseDetailTitle => 'Chi tiết bài tập';

  @override
  String get exerciseInstructions => 'Hướng dẫn thực hiện';

  @override
  String get exerciseSecondaryMuscles => 'Nhóm cơ phụ';

  @override
  String get exerciseTargetMuscle => 'Cơ mục tiêu';

  @override
  String get exerciseEquipment => 'Dụng cụ';

  @override
  String get exerciseBodyPart => 'Nhóm cơ';

  @override
  String get exerciseNoExercises => 'Không tìm thấy bài tập nào';

  @override
  String get exerciseCredit => 'Dữ liệu & hình ảnh bài tập © Gym visual';

  @override
  String get welcome => 'Chào mừng đến với FitTrack';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get currentLanguage => 'Ngôn ngữ hiện tại: Tiếng Việt';

  @override
  String get switchLanguage => 'Chuyển sang Tiếng Anh';

  @override
  String get themeMode => 'Chế độ giao diện';

  @override
  String get lightTheme => 'Giao diện sáng';

  @override
  String get darkTheme => 'Giao diện tối';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get emptyStateTitle => 'Không có dữ liệu';

  @override
  String get emptyStateMessage => 'Chưa có dữ liệu nào ở đây.';

  @override
  String get emailInvalid => 'Định dạng email không hợp lệ';

  @override
  String get passwordTooShort => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get positiveNumberRequired => 'Vui lòng nhập một số dương';

  @override
  String get fieldRequired => 'Trường này là bắt buộc';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get nameRequired => 'Vui lòng nhập họ tên';

  @override
  String get passwordsDoNotMatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get invalidEmailOrPassword => 'Email hoặc mật khẩu không đúng';

  @override
  String get emailAlreadyInUse => 'Email đã được đăng ký';

  @override
  String get dontHaveAccount => 'Chưa có tài khoản? Đăng ký ngay';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get registerSuccess => 'Đăng ký thành công!';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navWorkout => 'Tập luyện';

  @override
  String get navProgress => 'Tiến độ';

  @override
  String get navNutrition => 'Dinh dưỡng';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get workoutPlans => 'Kế hoạch tập luyện';

  @override
  String get createPlan => 'Tạo kế hoạch';

  @override
  String get editPlan => 'Sửa kế hoạch';

  @override
  String get deletePlan => 'Xóa kế hoạch';

  @override
  String get deletePlanConfirm =>
      'Bạn có chắc chắn muốn xóa kế hoạch này không?';

  @override
  String get planName => 'Tên kế hoạch';

  @override
  String get planNameRequired => 'Vui lòng nhập tên kế hoạch';

  @override
  String get planDescription => 'Mô tả (không bắt buộc)';

  @override
  String get addDay => 'Thêm ngày';

  @override
  String get dayName => 'Tên ngày';

  @override
  String get addExercise => 'Thêm bài tập';

  @override
  String get sets => 'Hiệp (Sets)';

  @override
  String get reps => 'Lần (Reps)';

  @override
  String get savePlan => 'Lưu kế hoạch';

  @override
  String get planSavedSuccess => 'Lưu kế hoạch thành công';

  @override
  String get planDeletedSuccess => 'Đã xóa kế hoạch';

  @override
  String get samplePlans => 'Kế hoạch mẫu';

  @override
  String get useSamplePlan => 'Dùng kế hoạch mẫu';

  @override
  String get samplePlanApplied => 'Đã áp dụng kế hoạch mẫu thành công';

  @override
  String get planAtLeastOneDay => 'Kế hoạch phải có ít nhất một ngày';

  @override
  String get dayAtLeastOneExercise => 'Mỗi ngày phải có ít nhất một bài tập';

  @override
  String get invalidSetsOrReps => 'Số hiệp và số lần phải lớn hơn 0';

  @override
  String get noPlansFound => 'Chưa có kế hoạch tập nào';

  @override
  String get noPlansSubtitle => 'Tạo kế hoạch đầu tiên hoặc thử kế hoạch mẫu';

  @override
  String get historyScreenDisabled => 'Lịch sử tập luyện sẽ sớm khả dụng';

  @override
  String get deleteDayConfirm => 'Bạn có chắc chắn muốn xóa ngày này không?';

  @override
  String get noExercisesInDay =>
      'Chưa có bài tập nào trong ngày này. Bấm \'Thêm bài tập\' để thêm.';

  @override
  String get workoutHistory => 'Lịch sử tập luyện';

  @override
  String get startWorkout => 'Bắt đầu tập';

  @override
  String get workoutSession => 'Buổi tập';

  @override
  String get workoutCompleted => 'Buổi tập hoàn thành!';

  @override
  String get workoutSummary => 'Tổng kết buổi tập';

  @override
  String get restTimer => 'Thời gian nghỉ';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get exitWorkout => 'Thoát buổi tập?';

  @override
  String get exitWorkoutConfirm =>
      'Bạn có muốn lưu các set đã ghi hay hủy buổi tập này?';

  @override
  String get continueWorkout => 'Tiếp tục';

  @override
  String get discardWorkout => 'Hủy bỏ';

  @override
  String get saveAndFinish => 'Lưu & Kết thúc';

  @override
  String get finishWorkout => 'Kết thúc buổi tập';

  @override
  String get finishWorkoutConfirm =>
      'Bạn có chắc chắn muốn kết thúc buổi tập này không?';

  @override
  String get invalidWeight => 'Mức tạ phải từ 0 trở lên';

  @override
  String get exerciseOrder => 'Bài tập';

  @override
  String get target => 'Mục tiêu';

  @override
  String get completedSets => 'Các hiệp đã hoàn thành';

  @override
  String get addSet => 'Ghi nhận hiệp';

  @override
  String get deleteSet => 'Xóa hiệp';

  @override
  String get previousExercise => 'Bài trước';

  @override
  String get nextExercise => 'Bài kế';

  @override
  String get totalDuration => 'Thời gian';

  @override
  String get totalVolume => 'Tổng khối lượng';

  @override
  String get totalSets => 'Tổng số hiệp';

  @override
  String get totalExercises => 'Số bài tập';

  @override
  String get sessionDetails => 'Chi tiết các hiệp tập';

  @override
  String get done => 'Hoàn tất';

  @override
  String get freeWorkout => 'Buổi tập tự do';

  @override
  String get selectDayToStart => 'Chọn ngày để bắt đầu buổi tập';

  @override
  String get weightKg => 'Mức tạ (kg)';

  @override
  String get backToHome => 'Về trang chủ';

  @override
  String get nutritionTitle => 'Nhật ký dinh dưỡng';

  @override
  String get nutritionCalories => 'Calo';

  @override
  String get nutritionProtein => 'Chất đạm';

  @override
  String get nutritionCarbs => 'Tinh bột';

  @override
  String get nutritionFat => 'Chất béo';

  @override
  String get nutritionTarget => 'Mục tiêu';

  @override
  String get nutritionConsumed => 'Đã nạp';

  @override
  String get nutritionRemaining => 'Còn lại';

  @override
  String get mealBreakfast => 'Bữa sáng';

  @override
  String get mealLunch => 'Bữa trưa';

  @override
  String get mealDinner => 'Bữa tối';

  @override
  String get mealSnack => 'Bữa phụ';

  @override
  String get addFood => 'Thêm món';

  @override
  String get scanBarcode => 'Quét mã vạch';

  @override
  String get manualEntry => 'Nhập thủ công';

  @override
  String get searchFood => 'Tìm món ăn';

  @override
  String get barcodeScanner => 'Quét mã vạch';

  @override
  String get barcodePointCamera => 'Hướng camera vào mã vạch thực phẩm';

  @override
  String get cameraPermissionRequired =>
      'Cần cấp quyền camera để quét mã vạch.';

  @override
  String get openSettings => 'Mở cài đặt';

  @override
  String get searchingProduct => 'Đang tìm sản phẩm...';

  @override
  String get productNotFound => 'Không tìm thấy sản phẩm trên Open Food Facts.';

  @override
  String get networkError => 'Lỗi mạng. Vui lòng kiểm tra kết nối internet.';

  @override
  String get timeoutError => 'Quá thời gian yêu cầu. Vui lòng thử lại.';

  @override
  String get retry => 'Thử lại';

  @override
  String get foodDetails => 'Chi tiết món ăn';

  @override
  String get per100g => 'Trên 100g';

  @override
  String get servingSize => 'Khối lượng (g)';

  @override
  String get selectMeal => 'Chọn bữa ăn';

  @override
  String get addToDiary => 'Thêm vào nhật ký';

  @override
  String get foodAddedSuccess => 'Đã thêm món vào nhật ký';

  @override
  String get createManualFood => 'Tạo món ăn thủ công';

  @override
  String get foodName => 'Tên món ăn';

  @override
  String get foodBrand => 'Thương hiệu (tùy chọn)';

  @override
  String get barcodeOptional => 'Mã vạch (tùy chọn)';

  @override
  String get caloriesPer100g => 'Calo (kcal / 100g)';

  @override
  String get proteinPer100g => 'Chất đạm (g / 100g)';

  @override
  String get carbsPer100g => 'Tinh bột (g / 100g)';

  @override
  String get fatPer100g => 'Chất béo (g / 100g)';

  @override
  String get editGrams => 'Sửa số gram';

  @override
  String get deleteFoodEntry => 'Xóa món ăn';

  @override
  String get deleteFoodConfirm => 'Bạn có chắc muốn xóa món này khỏi nhật ký?';

  @override
  String get noFoodInMeal => 'Chưa có món nào trong bữa này.';

  @override
  String get gramsPositiveRequired => 'Khối lượng phải lớn hơn 0';

  @override
  String get today => 'Hôm nay';

  @override
  String homeGreetingMorning(String name) {
    return 'Chào buổi sáng, $name!';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Chào buổi chiều, $name!';
  }

  @override
  String homeGreetingEvening(String name) {
    return 'Chào buổi tối, $name!';
  }

  @override
  String homeGreetingGeneric(String name) {
    return 'Xin chào, $name!';
  }

  @override
  String get homeWeeklyOverview => 'Tổng quan tuần';

  @override
  String get homeWeeklySessions => 'Số buổi tập';

  @override
  String get homeWeeklyVolume => 'Khối lượng';

  @override
  String get homeTodayCalories => 'Calo hôm nay';

  @override
  String get homeTodayWorkout => 'Buổi tập hôm nay';

  @override
  String get homeNoPlanYet => 'Chưa có kế hoạch tập';

  @override
  String get homeNoPlanSubtitle =>
      'Chọn kế hoạch mẫu hoặc bắt đầu buổi tập tự do.';

  @override
  String get homeStartWorkout => 'Bắt đầu tập';

  @override
  String get homeContinueWorkout => 'Tiếp tục tập';

  @override
  String get homeActiveSessionRunning => 'Buổi tập đang diễn ra';

  @override
  String get homeFreeWorkoutPrompt => 'Tập tự do ngay';

  @override
  String get homeQuickActions => 'Thao tác nhanh';

  @override
  String get homeQuickScanBarcode => 'Quét mã thực phẩm';

  @override
  String get homeQuickLogWeight => 'Ghi cân nặng';

  @override
  String get homeViewAllPlans => 'Xem kế hoạch';

  @override
  String get homeUnitSessions => 'buổi';

  @override
  String homeTarget(String target) {
    return 'Mục tiêu: $target';
  }

  @override
  String get profile => 'Hồ sơ cá nhân';

  @override
  String get progressNoExerciseData =>
      'Chưa có dữ liệu bài tập này trong khoảng thời gian đã chọn';

  @override
  String get exerciseNotFound => 'Không tìm thấy bài tập';

  @override
  String get refresh => 'Làm mới';

  @override
  String get profileUpdatedSuccess => 'Hồ sơ đã được cập nhật thành công!';

  @override
  String profileUpdateError(String error) {
    return 'Lỗi cập nhật hồ sơ: $error';
  }

  @override
  String get genderMale => 'Nam';

  @override
  String get genderFemale => 'Nữ';

  @override
  String get goalLoseFat => 'Giảm mỡ';

  @override
  String get goalMaintain => 'Duy trì';

  @override
  String get goalBuildMuscle => 'Tăng cơ';

  @override
  String get profileAutoCalculate => 'Tính tự động';

  @override
  String get settingsDeleteTitle => 'Xóa dữ liệu cá nhân?';

  @override
  String get settingsDeletePrompt =>
      'Hành động này sẽ xóa toàn bộ lịch sử tập, dữ liệu cân nặng, kế hoạch tự tạo và đưa ứng dụng về trạng thái ban đầu.';

  @override
  String get settingsDeleteConfirmTitle => 'Xác nhận lần cuối';

  @override
  String get settingsDeleteConfirmPrompt =>
      'Thao tác này KHÔNG THỂ hoàn tác. Bạn có hoàn toàn chắc chắn không?';

  @override
  String get settingsDeleteSuccess =>
      'Toàn bộ dữ liệu cá nhân đã được dọn sạch.';

  @override
  String settingsDeleteError(String error) {
    return 'Lỗi xóa dữ liệu: $error';
  }

  @override
  String get settingsLogoutConfirm =>
      'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get settingsTeamInfo => 'Thông tin nhóm & Dự án';

  @override
  String get settingsTeamSubtitle =>
      'Đại học Phenikaa · GV: TS. Nguyễn Xuân Quế';

  @override
  String get settingsCreditsTitle => 'Ghi công Dữ liệu & Bản quyền';

  @override
  String get settingsCreditsSubtitle =>
      'hasaneyldrm / Gym Visual / Open Food Facts';

  @override
  String teamLinkError(String url) {
    return 'Không thể mở liên kết: $url';
  }

  @override
  String get profileBodyInfo => 'Thông tin cơ thể';

  @override
  String get profileHeightCm => 'Chiều cao (cm)';

  @override
  String get profileAge => 'Tuổi';

  @override
  String get profileFitnessGoal => 'Mục tiêu tập luyện';

  @override
  String get profileActivityLevel => 'Mức độ hoạt động hàng ngày';

  @override
  String get profileDailyCalorieTarget => 'Mục tiêu Calo hàng ngày';

  @override
  String get profileCalorieTargetUnit => 'Mục tiêu Calo (kcal/ngày)';

  @override
  String get profileSave => 'Lưu hồ sơ';

  @override
  String get profileMifflinFormula =>
      '* Công thức Mifflin-St Jeor (Am J Clin Nutr 1990)';

  @override
  String get profileEditPrompt => 'Chỉnh sửa hồ sơ & chỉ số cơ thể →';

  @override
  String get settingsAppearanceLanguage => 'Giao diện & Ngôn ngữ';

  @override
  String get settingsAccountData => 'Tài khoản & Dữ liệu';

  @override
  String get settingsDeleteAllData => 'Xóa toàn bộ dữ liệu cá nhân';

  @override
  String get settingsDeleteDataSub =>
      'Xóa kế hoạch, lịch sử tập, cân nặng, nhật ký ăn (giữ tài khoản)';

  @override
  String get exerciseNoInstructions => 'Chưa có hướng dẫn cho bài tập này.';

  @override
  String get teamUniversity => 'Trường:';

  @override
  String get teamCourse => 'Học phần:';

  @override
  String get teamInstructor => 'Giảng viên:';

  @override
  String get teamMembers => 'Thành viên nhóm';

  @override
  String get teamCredits => 'Ghi công bản quyền & Dữ liệu';

  @override
  String get teamExerciseDataTitle => 'Dữ liệu & Hình ảnh bài tập';

  @override
  String get teamNutritionDataTitle =>
      'Cơ sở dữ liệu Dinh dưỡng Open Food Facts';

  @override
  String get nutritionStandardFromOff => 'Các chỉ số chuẩn từ Open Food Facts';

  @override
  String get nutritionScanBarcodeSub => 'Quét mã vạch bằng camera';

  @override
  String get nutritionManualEntrySub => 'Nhập tên và dinh dưỡng món ăn';

  @override
  String get planPleaseReLogin => 'Vui lòng đăng nhập lại để lưu kế hoạch';
}
