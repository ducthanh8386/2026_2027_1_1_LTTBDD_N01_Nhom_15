class TeamMember {
  final String name;
  final String studentId;
  final String role;
  final String contribution;
  final String githubUrl;
  final String email;

  const TeamMember({
    required this.name,
    required this.studentId,
    required this.role,
    required this.contribution,
    required this.githubUrl,
    required this.email,
  });
}

/// Centralized configuration for project, course, and team members.
/// Owned by Partner B (Module B3).
class TeamData {
  static const String appName = 'FitTrack';
  static const String projectTitle = 'Ứng dụng theo dõi tập luyện & dinh dưỡng';
  static const String university = 'Đại học Phenikaa';
  static const String course = 'Lập trình thiết bị di động';
  static const String instructor = 'TS. Nguyễn Xuân Quế';

  static const String exerciseAttribution =
      'Exercise data and media: hasaneyldrm/exercises-dataset (MIT License for dataset); media © Gym visual — https://gymvisual.com/';
  static const String nutritionAttribution =
      'Food barcode data powered by Open Food Facts (ODbL License) — https://openfoodfacts.org';

  static const List<TeamMember> members = [
    TeamMember(
      name: 'Nguyễn Đức Thanh',
      studentId: '(điền)',
      role: 'Máy A / Trưởng nhóm (~70%)',
      contribution: 'Kiến trúc 4 tầng, SQLite CSDL, Auth, Workout Plan, Active Workout Session, Dinh dưỡng, Tích hợp tổng thể',
      githubUrl: 'https://github.com/ducthanh8386',
      email: 'thanhygqv9@gmail.com',
    ),
    TeamMember(
      name: 'Lê Văn Sơn',
      studentId: '(điền)',
      role: 'Máy B / Thành viên (~30%)',
      contribution: 'Xử lý & dịch thuật bộ dữ liệu bài tập song ngữ, Thư viện bài tập, Module Tiến độ cân nặng (fl_chart), Hồ sơ & Cài đặt, Thống kê khối lượng & Lịch sử buổi tập',
      githubUrl: 'https://github.com/zackcutee',
      email: 'lson44554@gmail.com',
    ),
  ];
}
