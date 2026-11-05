# HỢP ĐỒNG A ↔ B (contract) — nguồn duy nhất

Phiên bản: `contract-v1`. Chỉ máy A sửa file này. Đổi hợp đồng: B mở GitHub Issue nhãn `contract-change` (nêu: cần gì, vì sao, đề xuất chữ ký) → A duyệt → A sửa file này + `CHANGELOG.md` + nâng tag (`contract-v1.1`, …) → B `git merge origin/main`.
**Khi code thật mâu thuẫn với file này: tin code, A sửa file này.** A phải đối chiếu hợp đồng với code hiện có ở prompt A02 trước khi đặt tag.

## 1. Quyền sở hữu file
Xem `docs/contracts/ownership.txt`. Máy B chỉ sửa các mẫu trong `[B_OWNED]`, được thêm key vào `.arb`. Mọi thứ khác thuộc A, gồm `main.dart`, `app.dart`, `routes.dart`, `pubspec.yaml`, `database_helper.dart`, `constants.dart`, `theme.dart`, mọi model, mọi repository/service/provider/screen không nằm trong danh sách B.

## 2. Schema `exercises` (thay bảng cũ trong SRS)
`id` INTEGER PK AUTOINCREMENT · `source_id` TEXT UNIQUE NOT NULL (id của dataset, vd "0025") · `name_en` TEXT NOT NULL · `name_vi` TEXT NOT NULL · `body_part` TEXT NOT NULL · `target` TEXT · `equipment` TEXT · `secondary_muscles` TEXT (chuỗi JSON mảng) · `instructions_en` TEXT (các bước nối `\n`) · `instructions_vi` TEXT NULL (thiếu → hiển thị EN) · `image_asset` TEXT · `gif_asset` TEXT.
`plan_exercises.exercise_id` và `set_logs.exercise_id` trỏ tới `exercises.id`. Schema 9 bảng còn lại theo `project_context.md` mục 5. Tên bảng là hằng số trong `lib/core/constants.dart` (B chỉ đọc).

## 3. Chữ ký B phải triển khai (A chỉ gọi đúng các hàm này)
```dart
// lib/data/repositories/exercise_repository.dart
class ExerciseRepository {
  Future<List<Exercise>> findAll({String? bodyPart, String? equipment, String? query});
  Future<Exercise?> findById(int id);
  Future<Exercise?> findBySourceId(String sourceId);
  Future<List<String>> distinctBodyParts();
  Future<List<String>> distinctEquipment();
}

// lib/providers/exercise_provider.dart
class ExerciseProvider extends ChangeNotifier {
  List<Exercise> get exercises;            // đã lọc
  List<String> get bodyParts;
  String? get selectedBodyPart;  String get query;
  bool get isLoading;  String? get error;
  Future<void> load();
  void setBodyPart(String? v);  void setQuery(String q);
  Exercise? byId(int id);                  // tra từ cache
}

// lib/screens/plan/exercise_library_screen.dart
class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key, this.selectMode = false});
  final bool selectMode;  // true: tick nhiều bài, nút "Thêm (n)", Navigator.pop(context, List<Exercise>)
}                          // false: chạm một bài → ExerciseDetailScreen(exerciseId: ...)
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});
  final int exerciseId;
}

// lib/services/stats_service.dart   (định nghĩa luôn các lớp dữ liệu bên dưới)
enum StatsRange { days7, days30, all }
class WeightPoint  { final DateTime date; final double kg; }
class VolumePoint  { final DateTime date; final double value; }
class WeeklySummary { final int sessions; final double totalVolume; final double totalKcal; }
class StatsService {
  StatsService({StatsRepository? stats, WeightRepository? weights}); // mặc định tự tạo repo
  Future<List<WeightPoint>> weightSeries(int userId, StatsRange range);
  Future<List<VolumePoint>> volumeSeries(int userId, StatsRange range);
  Future<List<VolumePoint>> maxWeightSeries(int userId, int exerciseId, StatsRange range);
  Future<WeeklySummary> weeklySummary(int userId);     // tuần bắt đầu thứ Hai
  Future<void> upsertWeight(int userId, DateTime date, double kg);
}

// lib/providers/progress_provider.dart  (BỔ SUNG so với bản cũ: UI không gọi Service trực tiếp)
class ProgressProvider extends ChangeNotifier {
  ProgressProvider({StatsService? service});
  void updateUser(int? userId);            // A gọi từ ProxyProvider.update; KHÔNG gọi notifyListeners đồng bộ trong build (dùng scheduleMicrotask)
  StatsRange get range;  void setRange(StatsRange r);
  List<WeightPoint> get weightPoints;
  List<VolumePoint> get volumePoints;
  List<VolumePoint> get maxWeightPoints;
  WeeklySummary? get weeklySummary;
  bool get isLoading;  String? get error;
  Future<void> reload();                   // nạp lại series theo range
  Future<void> loadWeekly();               // HomeScreen của A gọi
  Future<void> loadMaxWeight(int exerciseId);
  Future<void> addWeight(DateTime date, double kg);   // upsert (user,date)
}
```
`WeeklySummary.totalKcal` = Σ `food_log_entries.kcal` trong tuần; bằng 0 khi chưa có dữ liệu.

## 4. Đăng ký Provider (A làm, B không sửa `main.dart`)
```dart
ChangeNotifierProxyProvider<AuthProvider, ProgressProvider>(
  create: (_) => ProgressProvider(),
  update: (_, auth, progress) => progress!..updateUser(auth.currentUser?.id),
),
ChangeNotifierProvider(create: (_) => ExerciseProvider()..load()),
```
Mọi Provider khác (Auth, Settings, Plan, Workout, Nutrition) do A đăng ký.

## 5. Phần A cung cấp cho B
```dart
class AuthProvider extends ChangeNotifier {
  User? get currentUser;
  Future<void> updateProfile(User updated);   // lưu vào users, notifyListeners
  Future<void> deleteMyData();                // xóa plans/sessions/set_logs/weights/food_logs của user, GIỮ tài khoản
  Future<void> logout();
}
class SettingsProvider extends ChangeNotifier {
  Locale get locale;  ThemeMode get themeMode;
  Future<void> setLocale(Locale l);  Future<void> setThemeMode(ThemeMode m);
}
```
Model `User` có: `id, name, email, heightCm, weightKg, age, gender, goal, kcalTarget`.

**Buổi tập (B4 History dùng; đóng băng ở contract-v1, A hoàn tất thật ở A06):**
```dart
class SetLog { int? id; int sessionId; int exerciseId; int setIndex; int reps; double weightKg; }
class WorkoutSession {
  int? id; int userId; int? planDayId; String? planDayName; // null khi plan bị xóa/buổi tự do
  DateTime startedAt; DateTime? endedAt; double totalVolume;
  List<SetLog> sets;                       // sắp theo exercise (thứ tự xuất hiện) rồi setIndex
  Duration? get duration;  int get setCount;
}
class WorkoutProvider extends ChangeNotifier {
  List<WorkoutSession> get history;        // mới nhất trước, đã gồm sets
  Future<void> loadHistory(int userId);
  Future<WorkoutSession?> getSession(int id);
  Future<void> deleteSession(int id);      // set_logs xóa theo (ON DELETE CASCADE)
}
// SessionRepository.getFull(int sessionId) → Future<WorkoutSession?>
```

## 6. Route
`/exercises` `/exercise-detail` (arguments: `int exerciseId`) `/progress` `/profile` `/team-info` `/history` `/settings` đã khai báo sẵn trong `routes.dart` trỏ tới stub; B thay nội dung stub, giữ tên lớp và đường dẫn file.

## 7. Định dạng dữ liệu B giao cho A
`assets/data/exercises_seed.json`:
```json
[{"source_id":"0025","name_en":"barbell bench press","name_vi":"Đẩy ngực với tạ đòn",
  "body_part":"chest","target":"pectorals","equipment":"barbell",
  "secondary_muscles":["triceps","shoulders"],
  "instructions_en":"Step 1...\nStep 2...","instructions_vi":null,
  "image_asset":"assets/exercises/images/0025-EIeI8Vf.jpg",
  "gif_asset":"assets/exercises/gifs/0025-EIeI8Vf.gif"}]
```
`assets/data/sample_plans.json` (A đọc ở `seedSamplePlans`; mọi `source_id` phải tồn tại trong seed):
```json
[{"name_en":"Full body","name_vi":"Toàn thân",
  "days":[{"name_en":"Day 1","name_vi":"Ngày 1",
           "items":[{"source_id":"0025","sets":3,"reps":10}]}]}]
```
`pubspec.yaml` (A) khai báo `assets/data/`, `assets/exercises/images/`, `assets/exercises/gifs/` kèm `.gitkeep`.

## 8. Tag hợp đồng
- `contract-v1`: sau A03 (DB + stub đủ cho B build mọi route). B01–B02 làm trên `feature/b-exercise-data` rẽ từ `main` (sau A01); ở B03 B `git merge contract-v1` vào nhánh đó trước khi mở PR0. Mọi cụm sau rẽ từ `main` mới nhất.
- `contract-v2`: sau A06 (buổi tập thật chạy được; History dùng được dữ liệu thật).
- `contract-v1.x`: đổi nhỏ theo `contract-change`.
