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
}
