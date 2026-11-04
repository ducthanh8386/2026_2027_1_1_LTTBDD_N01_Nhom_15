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
}
