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
}
