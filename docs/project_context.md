# PROJECT_CONTEXT – FitTrack (Gym & Dinh dưỡng)

> Đặt tại `docs/project_context.md`. Antigravity đọc file này ở đầu mỗi phiên (xem `AGENTS.md`). Mô tả dự án là gì và được xây thế nào (ít thay đổi, chỉ máy A sửa).
> Tiến độ, bug, quyết định gần đây nằm ở `docs/memory/project_memory.md` (A) và `docs/memory/project_memory_partner.md` (B).

## 1. Tổng quan

- **Tên app:** FitTrack (tạm đặt, có thể đổi)
- **Môn:** Lập trình thiết bị di động – ĐH Phenikaa (GV: TS. Nguyễn Xuân Quế)
- **Loại:** Ứng dụng Flutter theo dõi tập gym + dinh dưỡng, **offline là chính**
- **Chức năng chính:** đăng ký/đăng nhập cục bộ; kế hoạch tập; nhật ký buổi tập; biểu đồ tiến độ; quét mã vạch tra dinh dưỡng (Open Food Facts); nhật ký ăn uống; đa ngôn ngữ EN/VI; trang thông tin nhóm.
- **Ngoài phạm vi:** server riêng, đồng bộ cloud, thanh toán, mạng xã hội, thuật toán gợi ý phức tạp.
- **Nền tảng:** Android là chính (kiểm thử), iOS phụ. Màn hình 5–6.7 inch, chiều dọc.

> ⚠️ **Không dùng Firestore/Firebase.** Dự án dùng **SQLite cục bộ (sqflite)**. Schema ở mục 5. Nếu agent đề xuất Firebase → từ chối.

## 2. Tech stack

| Mục đích | Gói |
| --- | --- |
| Framework | Flutter + Dart |
| State | `provider` (ChangeNotifier) |
| CSDL | `sqflite` + `path` |
| Cài đặt nhẹ | `shared_preferences` |
| API | `http` (timeout 10s) |
| Quét mã vạch | `mobile_scanner` |
| Biểu đồ | `fl_chart` |
| Băm mật khẩu | `crypto` (SHA-256 + salt ngẫu nhiên) |
| i18n | `flutter_localizations` + `intl` (file `.arb`, `flutter gen-l10n`) |
| Mở link | `url_launcher` |

Luôn kiểm tra phiên bản mới nhất trên pub.dev trước khi code; API của gói có thể khác giữa các phiên bản.

## 3. Kiến trúc 4 tầng (mỗi tầng chỉ gọi tầng ngay dưới)

1. **Presentation** (Screens, Widgets): vẽ UI, điều hướng. KHÔNG truy cập DB/API trực tiếp.
2. **State** (Provider/ChangeNotifier): giữ trạng thái, gọi Service, `notifyListeners`. KHÔNG chứa widget. Mỗi provider có `isLoading`, `error`.
3. **Domain/Service**: AuthService, WorkoutService, NutritionService, StatsService. Chứa quy tắc nghiệp vụ (validate, băm mật khẩu, tính calo, tính khối lượng tạ). KHÔNG biết SQL/HTTP.
4. **Data**: Repository, DatabaseHelper (SQLite), OffApiClient (HTTP), PrefsStore (SharedPreferences). KHÔNG chứa nghiệp vụ.

Quyết định thiết kế:
- Offline trước; API chỉ tra cứu, kết quả lưu đệm vào bảng `foods`.
- `NutritionService.lookupBarcode`: tìm DB local trước, thiếu mới gọi API.
- Mọi SQL nằm trong Repository.
- Phiên đăng nhập: chỉ lưu `userId` trong SharedPreferences. Mật khẩu chỉ ở DB dạng hash+salt.

## 4. Cấu trúc thư mục

```text
lib/
  main.dart                 # khởi động, bọc MultiProvider, runApp
  app.dart                  # MaterialApp: theme, locale, routes
  l10n/ app_en.arb  app_vi.arb
  core/ theme.dart  constants.dart  routes.dart  validators.dart
  models/ user  exercise  workout_plan  plan_day  plan_exercise
          workout_session  set_log  weight_entry  food  food_log_entry   (.dart)
  data/
    database_helper.dart
    repositories/ user_ exercise_ plan_ session_ weight_ food_ food_log_ repository.dart
    remote/off_api_client.dart
    local/prefs_store.dart
  services/ auth_service  workout_service  nutrition_service  stats_service (.dart)
  providers/ auth_  plan_  workout_  progress_  nutrition_  settings_ provider.dart
  screens/
    auth/      login_screen  register_screen
    home/      main_shell  home_screen
    plan/      plan_list_screen  plan_edit_screen  exercise_library_screen  exercise_detail_screen
    workout/   workout_session_screen  workout_summary_screen  history_screen
    progress/  progress_screen  add_weight_sheet
    nutrition/ food_diary_screen  barcode_scan_screen  food_detail_screen  manual_food_screen
    settings/  settings_screen  profile_screen  team_info_screen
  widgets/     PrimaryButton, StatCard, EmptyState, RestTimerBar, ...
```

Điều hướng: app mở → có phiên thì `MainShell`, không thì `LoginScreen`. `MainShell` = `NavigationBar` 5 tab (Trang chủ, Tập luyện, Tiến độ, Dinh dưỡng, Cài đặt) + `IndexedStack`. `LoginScreen` ⇄ `RegisterScreen` nằm ngoài shell.

## 5. Schema SQLite (thay cho "Firestore schema")

Bật `PRAGMA foreign_keys = ON` (trong `onConfigure`). Thời gian: ISO 8601 string. Ngày: `YYYY-MM-DD`.

| Bảng | Cột | Ràng buộc |
| --- | --- | --- |
| users | id, name, email, password_hash, salt, height_cm, weight_kg, age, gender, goal, kcal_target, created_at | PK id; email UNIQUE NOT NULL |
| exercises | id, source_id, name_en, name_vi, body_part, target, equipment, secondary_muscles (JSON string), instructions_en, instructions_vi (nullable), image_asset, gif_asset | PK id; source_id UNIQUE NOT NULL (id của dataset); seed từ `assets/data/exercises_seed.json` lần chạy đầu |
| workout_plans | id, user_id, name, created_at | FK user_id→users ON DELETE CASCADE |
| plan_days | id, plan_id, day_index, name | FK plan_id→workout_plans CASCADE |
| plan_exercises | id, plan_day_id, exercise_id, order_index, target_sets, target_reps | FK plan_day_id→plan_days CASCADE; FK exercise_id→exercises |
| workout_sessions | id, user_id, plan_day_id, started_at, ended_at, total_volume | plan_day_id nullable, ON DELETE SET NULL (giữ lịch sử khi xóa kế hoạch) |
| set_logs | id, session_id, exercise_id, set_index, reps, weight_kg | FK session_id→workout_sessions CASCADE |
| weight_entries | id, user_id, date, weight_kg | UNIQUE(user_id, date) |
| foods | id, barcode, name, brand, kcal_100g, protein_100g, carbs_100g, fat_100g, image_url, source | barcode UNIQUE nullable; source ∈ {off, manual} |
| food_log_entries | id, user_id, food_id, date, meal_type, grams, kcal, protein, carbs, fat | FK→users, FK→foods; lưu sẵn kcal/macro đã tính |

Giá trị enum: `goal` ∈ {lose_fat, build_muscle, maintain}; `meal_type` ∈ {breakfast, lunch, dinner, snack}; `gender` ∈ {male, female}.

Công thức:
- Khối lượng tạ buổi = Σ(reps × weight_kg)
- Calo mục ăn = kcal_100g × grams / 100 (macro tính tương tự)
- Mục tiêu calo = BMR × hệ số hoạt động, điều chỉnh theo mục tiêu. Dùng Mifflin-St Jeor, ghi nguồn trong báo cáo.

## 6. Yêu cầu chức năng (rút gọn, mã để truy vết)

Ưu tiên: Cao = bắt buộc theo đề (login, CSDL, API); TB = nên có; Thấp = nếu còn thời gian.

- **Auth:** A01 đăng ký (email không trùng) · A02 validate (email đúng định dạng, mk ≥ 6, lỗi tại ô) · A03 đăng nhập · A04 hash+salt · A05 ghi nhớ đăng nhập (TB) · A06 đăng xuất
- **Profile:** U01 sửa chiều cao/cân nặng/tuổi/giới/mục tiêu · U02 tính kcal mục tiêu (TB)
- **Plan:** P01 thư viện bài tập, lọc nhóm cơ, tìm tên · P02 chi tiết bài (TB) · P03 tạo kế hoạch nhiều ngày, mỗi ngày nhiều bài + set/rep · P04 sửa/xóa (xóa có xác nhận) · P05 kế hoạch mẫu 2–3 cái (TB)
- **Session:** L01 bắt đầu từ ngày kế hoạch · L02 ghi set (rep, kg), sửa/xóa · L03 đồng hồ nghỉ (TB) · L04 kết thúc: tổng thời gian + tổng tạ · L05 lịch sử, xem lại, xóa
- **Progress:** T01 ghi cân nặng · T02 biểu đồ đường 7/30/tất cả · T03 biểu đồ khối lượng tạ, max tạ theo bài (TB) · T04 thống kê tuần ở home (TB)
- **Nutrition:** N01 quét mã vạch · N02 gọi OFF, hiện tên/ảnh/calo/macro/100g · N03 thêm vào bữa + gram, tự tính · N04 nhập tay · N05 nhật ký theo ngày, tổng so mục tiêu, sửa/xóa · N06 lỗi dễ hiểu (mất mạng/timeout/không có) · N07 cache vào DB (TB)
- **Settings:** S01 đổi EN/VI, nhớ lựa chọn · S02 dark mode (Thấp) · S03 trang thông tin nhóm (ảnh, họ tên, MSSV, vai trò, GitHub) · S04 xóa dữ liệu (Thấp)

NFR chính: giao diện nhất quán (1 theme) + nhiều loại widget; **không hardcode chuỗi** (mọi text từ .arb); mở app < 3s, DB < 300ms/1000 bản ghi; API timeout 10s không treo UI; không crash khi mất mạng/từ chối camera/nhập sai; không log mật khẩu; chỉ gửi mã vạch lên API; tách lớp rõ; chạy tốt 5–6.7 inch.

## 7. Ràng buộc của đề (quan trọng)

- Repo GitHub tên đúng: `2026_2027_1_1_LTTBDD_N0x_Nhom_ii` (thay x, ii theo nhóm); **commit đầu chỉ chứa code mẫu Flutter**; thêm GV vào repo; README có thông tin nhóm.
- **Mỗi commit phải build được**, commit nhỏ, thông điệp rõ thì hiện tại (VD: `Add UserRepository with insert and findByEmail`). Mỗi thành viên commit bằng tài khoản của mình, làm trên nhánh riêng rồi gộp `main`. Không commit `build/`.
- Đề tài không thuộc thương mại điện tử hay quản lý chi tiêu.
- Biểu đồ trong báo cáo (use case, activity, kiến trúc, component, class, sequence, cây widget) **phải tự vẽ bằng draw.io/StarUML/Visio, không dùng AI hay code vẽ**, có ảnh chụp quá trình vẽ. Agent chỉ hỗ trợ code app, KHÔNG vẽ các biểu đồ này.
- Nộp: báo cáo docx+pdf, slide pptx+pdf (≤ 10 trang), demo ≤ 5 phút (≤ 100MB), link GitHub trong báo cáo. Không dùng lại báo cáo môn khác.

## 8. Lưu ý kỹ thuật

- **sqflite:** bật foreign keys trong `onConfigure`; dùng transaction khi lưu kế hoạch nhiều ngày/bài; seed bài tập trong `onCreate`; `singleton` DatabaseHelper.
- **Băm mật khẩu:** salt từ `Random.secure()` (base64), `sha256(utf8.encode(password + salt))`. Báo lỗi đăng nhập chung "Email hoặc mật khẩu không đúng".
- **Android permissions:** `CAMERA` và `INTERNET` trong `AndroidManifest.xml`; kiểm tra `minSdkVersion` theo yêu cầu `mobile_scanner`. iOS: thêm `NSCameraUsageDescription`.
- **mobile_scanner:** xử lý từ chối quyền (hiện hướng dẫn + nút Nhập tay); chống đọc trùng mã liên tục (debounce/cờ `isProcessing`); dispose controller.
- **Open Food Facts:** endpoint dạng `https://world.openfoodfacts.org/api/v2/product/{barcode}.json`; gửi header `User-Agent` mô tả app; trường dinh dưỡng thường ở `product.nutriments` (`energy-kcal_100g`, `proteins_100g`, `carbohydrates_100g`, `fat_100g`); trường có thể thiếu hoặc là số/chuỗi → parse an toàn, thiếu thì để trống cho người dùng điền. **Kiểm tra lại tài liệu API khi code.**
- **Lỗi mạng:** ném exception có nhãn (`NoInternet`, `NotFound`, `Timeout`) từ `OffApiClient`; UI map sang thông báo dịch được.
- **i18n:** `l10n.yaml` + `flutter gen-l10n`; mọi chuỗi qua `AppLocalizations.of(context)`; lưu locale trong PrefsStore; tên bài tập dùng `name_en/name_vi` theo locale.
- **Điều hướng:** dùng `PopScope` (không dùng `WillPopScope` đã deprecated) để hỏi thoát giữa buổi tập; `NavigationBar` Material 3.
- **Biểu đồ fl_chart:** xử lý rỗng (EmptyState) và 1 điểm dữ liệu; trục x là ngày.
- **Async/context:** kiểm tra `mounted` trước khi dùng `BuildContext` sau `await`.
- **Hiệu năng:** `ListView.builder`; không query DB trong `build()`; gọi qua provider.
- **Xóa kế hoạch:** `workout_sessions.plan_day_id` → NULL, lịch sử vẫn còn.

## 9. Quy ước code

- Đặt tên theo chuẩn Dart (lowerCamelCase, snake_case cho file); mỗi file một trách nhiệm.
- Model có `fromMap`/`toMap`; Repository CRUD trả về model.
- Màu/kích thước/chuỗi hằng ở `core/`.
- Sau mỗi phase: `flutter analyze` sạch, app chạy, commit, cập nhật `docs/memory/project_memory.md`.

## 10. Phân công

Dự án có 2 người: **A** (chủ repo, ~70%) và **B** (~30%). Chi tiết quyền sở hữu file, chữ ký hàm, định dạng JSON ở `docs/contracts/contract.md` và `docs/contracts/ownership.txt` (nguồn duy nhất; thay cho `team_split_prompts.md` cũ).

- A: Phase 0–1, DatabaseHelper + model + repository (User, Plan, Session, Food, FoodLog), Auth + MainShell, kế hoạch tập, buổi tập, toàn bộ dinh dưỡng, HomeScreen, tích hợp, build APK.
- B: dữ liệu bài tập (tập con dataset + bản dịch VN), module bài tập, module tiến độ, lịch sử buổi tập, hồ sơ/cài đặt/thông tin nhóm, rà soát i18n và kiểm thử máy thật.

Tên thành viên/MSSV thật nằm ở `docs/memory/project_memory.md` mục Team.

## 11. Dataset bài tập (đã chốt)

- Nguồn: `github.com/hasaneyldrm/exercises-dataset` (1.324 bài; ảnh + GIF 180×180; hướng dẫn 10 ngôn ngữ, **không có tiếng Việt**).
- Dùng **tập con ~150–200 bài**, nhúng vào `assets/`: `assets/data/exercises_seed.json`, `assets/data/sample_plans.json`, `assets/exercises/images/*.jpg`, `assets/exercises/gifs/*.gif`. Dữ liệu tập con do người B chuẩn bị bằng `tools/curate_exercises.py`.
- Tên VN tự dịch (`name_vi` bắt buộc); `instructions_vi` tùy chọn, thiếu thì hiển thị EN. Model có `localizedName(lang)`, `localizedInstructions(lang)`.
- Bộ lọc "nhóm cơ" của FR-P01 = `body_part` (chest, back, shoulders, upper arms, lower arms, upper legs, lower legs, waist, cardio, neck).
- **Ghi công bắt buộc:** `© Gym visual — https://gymvisual.com/` (media); dữ liệu/text MIT. Hiển thị trong TeamInfo/Giới thiệu, README, báo cáo. Đồ án học tập; nếu phát hành thật phải tự xin giấy phép media.

## 12. Làm việc nhóm 2 người, 2 máy (Antigravity)

- Mỗi người một máy, cùng một tài khoản Antigravity (chia chung quota). GitHub là nơi DUY NHẤT đồng bộ code, memory, hợp đồng.
- **Không ai commit thẳng lên `main`.** A: `feature/a-<tên>`; B: `feature/b-<tên>`; gộp bằng Pull Request, kiểu Merge commit. Nhánh dữ liệu của B (`feature/b-exercise-data`) rẽ từ `main` sau A01 và merge tag `contract-v1` trước PR0; các cụm sau rẽ từ `main` mới nhất.
- Quyền sở hữu file: `docs/contracts/ownership.txt`. Hợp đồng: `docs/contracts/contract.md`. Đổi hợp đồng qua GitHub Issue nhãn `contract-change`, A duyệt, ghi `CHANGELOG.md`, nâng tag.
- **Provider mới:** `ExerciseProvider` và `ProgressProvider` (B) đã có sẵn dạng stub trong `main.dart` do A đăng ký. `PlanProvider` của A chỉ giữ kế hoạch.
- **ExerciseLibraryScreen(selectMode: true)** trả `List<Exercise>` qua `Navigator.pop`.
- **Memory tách đôi:** A = `docs/memory/project_memory.md`; B = `docs/memory/project_memory_partner.md`.
- **arb:** key của B chèn sau `"appName"`; key của A thêm cuối file.
- Biểu đồ báo cáo (use case, activity, kiến trúc, component, class, sequence, cây widget) nhóm tự vẽ bằng phần mềm, không nhờ AI.
