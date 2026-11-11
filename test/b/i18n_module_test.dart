import 'package:flutter_test/flutter_test.dart';

import 'package:fit_track/l10n/app_localizations_en.dart';
import 'package:fit_track/l10n/app_localizations_vi.dart';

void main() {
  group('B08 i18n Localization Integrity Tests', () {
    late AppLocalizationsEn l10nEn;
    late AppLocalizationsVi l10nVi;

    setUp(() {
      l10nEn = AppLocalizationsEn();
      l10nVi = AppLocalizationsVi();
    });

    test('Locale identifiers are correct', () {
      expect(l10nEn.localeName, equals('en'));
      expect(l10nVi.localeName, equals('vi'));
    });

    test('Progress module keys are non-empty and localized', () {
      expect(l10nEn.progressTitle, isNotEmpty);
      expect(l10nVi.progressTitle, isNotEmpty);
      expect(l10nEn.progressTitle, isNot(equals(l10nVi.progressTitle)));

      expect(l10nEn.progressWeightTab, equals('Weight'));
      expect(l10nVi.progressWeightTab, equals('Cân nặng'));

      expect(l10nEn.progressVolumeTab, equals('Volume'));
      expect(l10nVi.progressVolumeTab, equals('Khối lượng tạ'));

      expect(l10nEn.progressNoExerciseData, isNotEmpty);
      expect(l10nVi.progressNoExerciseData, isNotEmpty);
    });

    test('History module keys are non-empty and localized', () {
      expect(l10nEn.historyTitle, equals('Workout History'));
      expect(l10nVi.historyTitle, equals('Lịch sử tập luyện'));

      expect(l10nEn.historyEmptyTitle, isNotEmpty);
      expect(l10nVi.historyEmptyTitle, isNotEmpty);

      expect(l10nEn.historyDeleteTitle, equals('Delete Session'));
      expect(l10nVi.historyDeleteTitle, equals('Xóa buổi tập'));

      // Parameterized set number
      expect(l10nEn.historySetNumber(3), equals('Set 3'));
      expect(l10nVi.historySetNumber(3), equals('Hiệp 3'));
    });

    test('Exercise module keys are non-empty and localized', () {
      expect(l10nEn.exerciseLibraryTitle, isNotEmpty);
      expect(l10nVi.exerciseLibraryTitle, isNotEmpty);

      expect(l10nEn.exerciseNotFound, equals('Exercise not found'));
      expect(l10nVi.exerciseNotFound, equals('Không tìm thấy bài tập'));

      expect(l10nEn.exerciseAddSelected(4), equals('Add (4)'));
      expect(l10nVi.exerciseAddSelected(4), equals('Thêm (4)'));
    });

    test('Settings & Profile module keys are non-empty and localized', () {
      expect(l10nEn.genderMale, equals('Male'));
      expect(l10nVi.genderMale, equals('Nam'));

      expect(l10nEn.genderFemale, equals('Female'));
      expect(l10nVi.genderFemale, equals('Nữ'));

      expect(l10nEn.goalLoseFat, equals('Lose Fat'));
      expect(l10nVi.goalLoseFat, equals('Giảm mỡ'));

      expect(l10nEn.goalMaintain, equals('Maintain'));
      expect(l10nVi.goalMaintain, equals('Duy trì'));

      expect(l10nEn.goalBuildMuscle, equals('Build Muscle'));
      expect(l10nVi.goalBuildMuscle, equals('Tăng cơ'));

      expect(l10nEn.settingsTeamInfo, equals('Team & Project Info'));
      expect(l10nVi.settingsTeamInfo, equals('Thông tin nhóm & Dự án'));

      // Parameterized error string
      expect(
        l10nEn.teamLinkError('https://github.com'),
        contains('https://github.com'),
      );
      expect(
        l10nVi.teamLinkError('https://github.com'),
        contains('https://github.com'),
      );

      // Phase 6 audited keys
      expect(l10nEn.profileBodyInfo, equals('Body Information'));
      expect(l10nVi.profileBodyInfo, equals('Thông tin cơ thể'));

      expect(l10nEn.profileHeightCm, equals('Height (cm)'));
      expect(l10nVi.profileHeightCm, equals('Chiều cao (cm)'));

      expect(l10nEn.profileAge, equals('Age'));
      expect(l10nVi.profileAge, equals('Tuổi'));

      expect(l10nEn.settingsDeleteAllData, equals('Delete Personal Data'));
      expect(l10nVi.settingsDeleteAllData, equals('Xóa toàn bộ dữ liệu cá nhân'));

      expect(l10nEn.exerciseNoInstructions, isNotEmpty);
      expect(l10nVi.exerciseNoInstructions, isNotEmpty);

      expect(l10nEn.teamMembers, equals('Team Members'));
      expect(l10nVi.teamMembers, equals('Thành viên nhóm'));
    });
  });
}

