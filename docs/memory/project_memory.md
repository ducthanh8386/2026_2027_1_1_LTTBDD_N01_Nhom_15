# PROJECT_MEMORY – FitTrack

> **Dành cho AI agent.** Đặt tại `docs/memory/project_memory.md`. Đọc file này (và `docs/project_context.md`) ở đầu mỗi session. KHÔNG cần quét lại toàn bộ dự án.
> Chỉ mở file code khi task hiện tại chạm tới nó; dùng mục "File Index" để biết file nào làm gì.
> **Cuối mỗi session, agent PHẢI cập nhật file này** theo mục "Quy tắc cập nhật" ở cuối.

Last updated: 2026-11-08 · by: AI Senior Flutter Engineer · Session #8

## 1. Trạng thái hiện tại

- **Giai đoạn hiện tại:** S07 – Dinh dưỡng, quét mã vạch, Open Food Facts (HOÀN THÀNH 100%) → Sẵn sàng PR sang `main`
- **Tiến độ tổng:** Đã xong S00–S07. 83/83 unit test và widget test toàn app pass 100%.
- **Nhánh hiện tại:** `feature/a-nutrition`
- **App chạy được không:** Có, app chạy tốt trên cả Android, Web và Desktop. 83 tests pass 100%.
- **Việc đang làm dở:** Không
- **Việc tiếp theo (làm ngay):** Merge PR nhánh `feature/a-nutrition` vào `main`, bắt đầu S08 (HomeScreen thật & Tích hợp toàn app)
- **Đang bị chặn bởi:** Không bị chặn.

## 2. Checklist phase (theo bảng giai đoạn FitTrack_Prompts)

Ký hiệu: [ ] chưa · [~] đang làm · [x] xong (đã build + test + commit)

- [x] S00 – Cài đặt môi trường, Git identity, local rule máy A
- [x] S01 – Phân tích dự án, đưa tài liệu `docs/`, `AGENTS.md`, `.github/`, Git hooks vào repo
- [x] S02 – Nền tảng: theme, routes, Provider, i18n, PrefsStore
- [x] S03 – Dữ liệu & Hợp đồng (DatabaseHelper, 10 Models, Repositories, Stubs cho B)
- [x] S04 – Xác thực (Auth: register, login, session, deleteMyData) + MainShell (5 tabs, AuthGate)
- [x] S05 – Kế hoạch tập (Plan: CRUD plan, days, exercises, gán bài tập, kế hoạch mẫu)
- [x] S06 – Buổi tập, ghi set, đồng hồ nghỉ → tag `contract-v2`
- [x] S07 – Dinh dưỡng + quét mã vạch Open Food Facts
- [ ] S08 – HomeScreen + tích hợp module B
- [ ] S09 – Kiểm thử toàn app, QA
- [ ] S10 – Hoàn thiện, build APK, tag `v1.0`

## 3. Checklist yêu cầu (truy vết)

Đánh dấu khi yêu cầu được code VÀ test.

- Auth: [x] A01 [x] A02 [x] A03 [x] A04 [x] A05 [x] A06
- Profile: [x] U01 [x] U02
- Plan: [x] P01 [x] P02 [x] P03 [x] P04 [x] P05
- Session: [x] L01 [x] L02 [x] L03 [x] L04 [x] L05
- Progress: [x] T01 [x] T02 [x] T03 [x] T04
- Nutrition: [x] N01 [x] N02 [x] N03 [x] N04 [x] N05 [x] N06 [x] N07
- Settings: [x] S01 [x] S02 [x] S03 [x] S04

## 4. File Index (agent cập nhật khi tạo/sửa file quan trọng)

Định dạng: `đường dẫn` – mục đích – trạng thái (done/wip/stub) – ghi chú

- `AGENTS.md` – Quy tắc dự án luôn bật cho mọi phiên Antigravity (<6KB) – done
- `docs/project_context.md` – Bối cảnh, kiến trúc 4 tầng, tech stack, schema 10 bảng SQLite – done
- `docs/workflow_rules.md` – Quy tắc làm việc chung, vòng đời phiên, gate chuyển giai đoạn – done
- `docs/git_workflow.md` – Quy trình Git 2 máy, nhánh, PR merge commit, xử lý xung đột – done
- `docs/antigravity_guide.md` – Hướng dẫn vận hành 2 máy trên 1 tài khoản Antigravity – done
- `docs/contracts/contract.md` – Hợp đồng chữ ký, route, schema giữa A và B – done
- `docs/contracts/ownership.txt` – Phân định quyền sở hữu file của máy B và máy A – done
- `docs/contracts/CHANGELOG.md` – Nhật ký thay đổi hợp đồng theo version tag – done
- `.github/pull_request_template.md` – Mẫu PR cho cả hai máy – done
- `.github/CODEOWNERS` – Chỉ định review theo file ownership (@ducthanh8386) – done
- `tools/git/install_hooks.sh` – Script cài đặt hook cho từng máy – done
- `tools/git/pre-commit` – Hook chặn commit sai email và chặn B sửa file ngoài ownership – done
- `tools/git/pre-push` – Hook chặn force push và chặn push thẳng `main` – done
- `docs/memory/project_memory.md` – Memory làm việc của Máy A – done
- `docs/memory/project_memory_partner.md` – Memory làm việc của Máy B (A không sửa) – done
- `pubspec.yaml` – Khai báo dependencies, sqflite_common_ffi, crypto, assets – done
- `lib/models/user.dart` – Model User hoàn chỉnh fromMap/toMap/copyWith – done
- `lib/models/exercise.dart` – Model Exercise schema mới, secondaryMuscles JSON, localizedName/Instructions – done
- `lib/models/workout_plan.dart` – Model WorkoutPlan fromMap/toMap/copyWith – done
- `lib/models/plan_day.dart` – Model PlanDay fromMap/toMap/copyWith – done
- `lib/models/plan_exercise.dart` – Model PlanExercise fromMap/toMap/copyWith – done
- `lib/models/workout_session.dart` – Model WorkoutSession fromMap/toMap/copyWith – done
- `lib/models/set_log.dart` – Model SetLog fromMap/toMap/copyWith – done
- `lib/models/weight_entry.dart` – Model WeightEntry fromMap/toMap/copyWith – done
- `lib/models/food.dart` – Model Food fromMap/toMap/copyWith – done
- `lib/models/food_log_entry.dart` – Model FoodLogEntry fromMap/toMap/copyWith – done
- `lib/data/database_helper.dart` – Singleton SQLite, PRAGMA foreign_keys = ON, tạo 10 bảng, CASCADE và SET NULL – done
- `lib/data/seed/exercise_seed.dart` – ExerciseSeeder stub rỗng cho B (Module B1) – stub
- `lib/data/local/prefs_store.dart` – SharedPreferences store (userId, locale, themeMode) – done
- `lib/data/repositories/user_repository.dart` – CRUD User, chặn duplicate email, deleteUserData – done
- `lib/data/repositories/plan_repository.dart` – CRUD Plan, Day, Exercise nguyên tử trong transaction – done
- `lib/data/repositories/session_repository.dart` – Session & SetLog CRUD, finishSession, getFull – done
- `lib/data/repositories/food_repository.dart` – Food CRUD, tìm theo barcode, tìm theo tên/brand – done
- `lib/data/repositories/food_log_repository.dart` – FoodLogEntry CRUD, findByDate, totalsByDate – done
- `lib/data/repositories/exercise_repository.dart` – Stub theo hợp đồng cho B – stub
- `lib/data/repositories/weight_repository.dart` – Stub theo hợp đồng cho B – stub
- `lib/data/repositories/stats_repository.dart` – Stub theo hợp đồng cho B – stub
- `lib/services/auth_service.dart` – Băm mật khẩu SHA-256 + salt (Random.secure), đăng ký, đăng nhập – done
- `lib/services/stats_service.dart` – Stub theo hợp đồng cho B – stub
- `lib/providers/auth_provider.dart` – AuthProvider (currentUser, register, login, restoreSession, updateProfile, deleteMyData, logout) – done
- `lib/providers/settings_provider.dart` – Quản lý locale EN/VI và themeMode light/dark/system – done
- `lib/providers/exercise_provider.dart` – ExerciseProvider stub cho B – stub
- `lib/providers/progress_provider.dart` – ProgressProvider stub cho B (updateUser theo hợp đồng) – stub
- `lib/providers/plan_provider.dart` – PlanProvider stub – stub
- `lib/providers/workout_provider.dart` – WorkoutProvider stub – stub
- `lib/data/remote/off_api_client.dart` – Client API Open Food Facts v2, timeout 10s, User-Agent, safe parsing kcal/protein/carbs/fat, exception handling (NoInternet, NotFound, Timeout, Parse) – done
- `lib/providers/nutrition_provider.dart` – Quản lý nhật ký dinh dưỡng ngày đang xem, 4 bữa ăn, tổng calo vs mục tiêu, tìm kiếm mã vạch – done
- `lib/services/nutrition_service.dart` – Tra cứu mã vạch (cache local -> API -> lưu foods), thêm món thủ công, ghi nhật ký ăn, tính calo/macro, xóa/sửa số gram, tính tổng ngày – done
- `lib/screens/nutrition/barcode_scan_screen.dart` – Quét mã vạch bằng MobileScanner, bật/tắt flash, đổi camera, chống quét trùng, loading API, xử lý lỗi kèm nút nhập tay – done
- `lib/screens/nutrition/food_detail_screen.dart` – Chi tiết món ăn: ảnh, tên, brand, barcode, chỉ số dinh dưỡng / 100g (cho phép sửa), chọn bữa, nhập gram, live preview calo phần ăn – done
- `lib/screens/nutrition/manual_food_screen.dart` – Tạo món ăn thủ công (tên, hãng, calo, macro / 100g, bữa ăn, gram) nạp vào DB và nhật ký – done
- `lib/screens/nutrition/food_diary_screen.dart` – Nhật ký ăn uống: chuyển ngày/chọn lịch, Card tổng calo/macro, 4 ExpansionTile bữa ăn kèm xóa/sửa gram, FAB thêm món – done
- `test/nutrition_test.dart` – 14 unit tests kiểm tra toàn diện OffApiClient, NutritionService, NutritionProvider pass 100% – done
- `lib/services/workout_service.dart` – Validate plan, CRUD plan qua PlanRepository, seed sample plans từ json – done
- `lib/providers/plan_provider.dart` – Quản lý danh sách plan và PlanDraft (thêm/xóa/đổi tên ngày, thêm/xóa/reorder bài tập, targetSets/Reps) – done
- `lib/screens/auth/login_screen.dart` – Màn hình Đăng nhập (validator email/pass, toggle ẩn hiện, loading, SnackBar) – done
- `lib/screens/auth/register_screen.dart` – Màn hình Đăng ký (validator tên/email/pass/confirm, toggle ẩn hiện, loading) – done
- `lib/screens/home/main_shell.dart` – Shell điều hướng 5 tab (Home, Workout, Progress, Nutrition, Settings) + IndexedStack – done
- `lib/screens/home/home_screen.dart` – Màn hình trang chủ chào mừng user, hiển thị avatar, email, nút đăng xuất – done
- `lib/screens/plan/plan_list_screen.dart` – Danh sách kế hoạch tập (ListView, EmptyState, FAB tạo kế hoạch, bottom sheet kế hoạch mẫu, Dismissible & AlertDialog xác nhận xóa) – done
- `lib/screens/plan/plan_edit_screen.dart` – Màn hình tạo mới và sửa kế hoạch (Form validate, ExpansionTile theo ngày, ReorderableListView bài tập, Thêm ngày, Thêm bài hook ExerciseLibraryScreen) – done
- `assets/data/sample_plans.json` – Kế hoạch tập mẫu Full Body theo contract – done
- `lib/app.dart` – FitTrackApp cấu hình theme, locale, AuthGate điều hướng tự động (Splash/Login/MainShell) – done
- `lib/main.dart` – MultiProvider đăng ký đủ 7 Provider theo hợp đồng contract-v1 – done
- `lib/core/routes.dart` – Định tuyến AppRoutes và map route tới các màn hình (bổ sung planList, planEdit) – done
- `test/auth_test.dart` – Unit test AuthService & AuthProvider (SHA-256 + salt, login, register, duplicate email, deleteMyData) – done
- `test/widget_test.dart` – Widget test kiểm tra AuthGate hiển thị LoginScreen khi chưa đăng nhập và MainShell khi đã có phiên – done
- `test/workout_plan_test.dart` – 9 unit/widget tests kiểm tra toàn diện validation rules, CRUD 3 ngày, cascade deletion, sample plan copy, localization – done
- `test/models_test.dart` – Unit test 10 models pass 100% – done
- `test/repositories_test.dart` – Unit test DatabaseHelper & Repositories pass 100% – done

## 5. Quyết định kỹ thuật đã chốt

| Ngày | Quyết định | Lý do |
| --- | --- | --- |
| 2026-11-04 | Dùng SQLite (sqflite), KHÔNG Firebase/Firestore | Đề yêu cầu CSDL cục bộ, offline là chính |
| 2026-11-04 | State: provider; 4 tầng Presentation→State→Service→Data | Theo SAD |
| 2026-11-04 | Băm mật khẩu SHA-256 + salt (`crypto`) | Đủ cho app cục bộ, an toàn, không lưu mật khẩu rõ |
| 2026-11-04 | API dinh dưỡng: Open Food Facts, timeout 10s, cache vào `foods` | Theo SRS |
| 2026-11-04 | Dataset bài tập: hasaneyldrm/exercises-dataset, dùng tập con ~150–200 bài nhúng assets | Có GIF minh họa; ghi công © Gym visual |
| 2026-11-04 | Chia việc: A 70% (kiến trúc, DB, Auth, Plan, Workout, Nutrition), B 30% (Data bài tập, Tiến độ, Settings/Team, History) | Theo thỏa thuận nhóm 2 người |
| 2026-11-05 | Chuyển đổi sang quy trình 2 máy chuẩn (`FitTrack_Prompts`): A cũng làm trên nhánh `feature/a-*`, merge qua PR (Merge commit) | Tuân thủ tuyệt đối quy định không commit thẳng main |
| 2026-11-05 | Khôi phục phiên tự động qua AuthGate: đọc userId từ SharedPreferences, khôi phục User từ SQLite | Trải nghiệm mượt mà không bắt user đăng nhập lại mỗi khi mở app |
| 2026-11-05 | Quản lý bản thảo kế hoạch qua `PlanDraft` trong `PlanProvider`: hỗ trợ ReorderableListView theo ngày, lưu giữ trạng thái form khi validate lỗi | Tránh mất dữ liệu người dùng đang nhập dở |
| 2026-11-05 | An toàn bất đồng bộ trong `PlanProvider`: kiểm tra cờ `_disposed` trước khi `notifyListeners()` | Tránh lỗi assertion `used after being disposed` khi unmount màn hình |
| 2026-11-06 | Bổ sung getter `session => this` trên `WorkoutSession` | Đảm bảo tương thích ngược với unit test cũ mà vẫn đáp ứng chuẩn `contract-v2` (`Future<WorkoutSession?> getFull()`) |
| 2026-11-06 | `WorkoutProvider` quản lý song song timer buổi tập (elapsed) và đếm ngược nghỉ (rest countdown) kèm cờ an toàn `_disposed` | Tránh rò rỉ timer khi unmount màn hình, tự động cập nhật UI mượt mà |
| 2026-11-06 | Khi tích hợp code B: thay `ListTile` chứa `ElevatedButton` trailing bằng custom `Column` layout | `ListTile.trailing` không thể chứa widget rộng trên màn hình hẹp; custom layout cho phép button full-width |
| 2026-11-08 | UTF-8 decoding trong `OffApiClient` | Sử dụng `utf8.decode(response.bodyBytes)` thay vì `response.body` mặc định (Latin1) để xử lý chuẩn xác tên thực phẩm tiếng Việt và ký tự có dấu từ Open Food Facts |
| 2026-11-08 | Chiến lược bộ nhớ đệm (Cache-first) cho tra cứu thực phẩm | Tra cứu trong bảng `foods` SQLite cục bộ trước khi gọi API Open Food Facts v2 (timeout 10s), khi tải thành công tự động lưu vào `foods` giúp sử dụng offline và tăng tốc độ |
| 2026-11-08 | Đồng bộ mục tiêu dinh dưỡng với người dùng đăng nhập | `NutritionProvider` lắng nghe thay đổi qua `ChangeNotifierProxyProvider<AuthProvider, NutritionProvider>`, tự động tính calo mục tiêu (default 2000 kcal hoặc từ profile) và tải lại nhật ký ngày hiện tại |

## 6. Nhật ký bug & fix

| Ngày | Phase | Triệu chứng | Nguyên nhân | Cách sửa (file) | Trạng thái |
| --- | --- | --- | --- | --- | --- |
| 2026-11-04 | Phase 1 | `CardTheme` không tương thích `CardThemeData?` trong `ThemeData` | Flutter SDK hiện hành yêu cầu `CardThemeData` | Cập nhật `CardThemeData` trong `lib/core/theme.dart` | Đã sửa |
| 2026-11-04 | Phase 1 | Regex `validateEmail` không nhận email hợp lệ chứa dấu `+` | Regex ban đầu chỉ cho phép `[\w-\.]+` | Bổ sung ký tự chuẩn RFC-5322 trong `lib/core/validators.dart` | Đã sửa |
| 2026-11-05 | Phase 2 | `onGenerateRoute` lỗi `Not a constant expression: case settings:` | Tên tham số che khuất hằng số `AppRoutes.settings` | Đổi tên tham số thành `routeSettings` trong `lib/core/routes.dart` | Đã sửa |
| 2026-11-05 | Phase 2 | `Exercise.copyWith` lỗi biên dịch tham số `secondaryMuscles` | Tham số không cho phép null | Đổi thành `List<String>? secondaryMuscles` trong `lib/models/exercise.dart` | Đã sửa |
| 2026-11-05 | S01 | `.gitignore` che mất `docs/project_context.md` và `docs/memory/project_memory.md` | Dòng ignore cũ thiếu dấu gạch chéo đầu `/` | Thêm dấu `/` cho các file gốc trong `.gitignore` | Đã sửa |
| 2026-11-05 | S05 | Biên dịch `WorkoutPlan` báo lỗi không có trường `description` | Bảng `workout_plans` schema chuẩn chỉ gồm `id, user_id, name, created_at` | Bỏ `description` khỏi Model query, đồng bộ đúng schema trong `workout_service.dart`, `plan_provider.dart`, `plan_list_screen.dart` | Đã sửa |
| 2026-11-05 | S05 | Flutter deprecation warning với `onReorder` trong `ReorderableListView` | Flutter 3.41+ khuyến khích dùng `onReorderItem` | Cập nhật `onReorderItem` trong `plan_edit_screen.dart` | Đã sửa |
| 2026-11-05 | S05 | `test/widget_test.dart` lỗi `PlanProvider used after being disposed` | `loadPlans` gọi `notifyListeners()` trong finally sau khi widget đã dispose | Thêm cờ `_disposed` ghi đè `notifyListeners()` trong `PlanProvider` | Đã sửa |
| 2026-11-05 | S05 | `test/widget_test.dart` không tìm thấy `NavigationBar` khi test phiên đăng nhập | Key Prefs mock dùng sai chuỗi `fittrack_user_id` thay vì `pref_user_id` | Sử dụng hằng số chuẩn `AppConstants.prefKeyUserId` và bọc async setup trong `tester.runAsync` | Đã sửa |
| 2026-11-06 | S06 | `FOREIGN KEY constraint failed (code 787)` khi insert `set_logs` trong test | Bảng `exercises` trong in-memory database trống, khóa ngoại `exercise_id` không tìm thấy bài tập cha | Insert dữ liệu bài tập mẫu vào bảng `exercises` ở `setUp` trong `test/workout_session_test.dart` | Đã sửa |
| 2026-11-06 | S06 | Linter warning unused imports & multiple underscores `(_, __)` trong `workout_session_screen.dart` | Code thừa import và đặt tên tham số chưa chuẩn linter | Dọn dẹp import và đổi tên `(_, _)` trong `lib/screens/workout/workout_session_screen.dart` | Đã sửa |
| 2026-11-06 | Tích hợp B | Git merge conflict khi `git pull origin main` (PR #2 của B) | Conflict trên `assets/data/sample_plans.json` và `docs/memory/project_memory_partner.md` | Giữ nguyên nội dung B, staged và committed | Đã sửa |
| 2026-11-06 | Tích hợp B | `Member not found: 'ExerciseRepository._stripDiacritics'` trong `exercise_provider.dart` | Gọi private member `_stripDiacritics` từ file khác | Đổi thành public `stripDiacritics` trong `exercise_repository.dart` và cập nhật callers | Đã sửa |
| 2026-11-06 | Tích hợp B | Hero tag collision `<default FloatingActionButton tag>` gây cascade hàng trăm assertion errors | Nhiều FAB.extended trong `IndexedStack` dùng cùng hero tag mặc định | Gán `heroTag: 'plan_list_fab'` và `heroTag: 'progress_weight_fab'` | Đã sửa |
| 2026-11-06 | Tích hợp B | SQLite WASM lỗi `no such column: ""` trong `ExerciseRepository.distinctBodyParts()` | Dùng dấu nháy kép `""` thay vì nháy đơn `''` trong SQL | Đổi `body_part != ""` → `body_part != ''` và tương tự cho `equipment` | Đã sửa |
| 2026-11-06 | Tích hợp B | Pre-push hook chặn Máy A push lên `main` | Hook không phân biệt role A/B | Sửa điều kiện `if [[ "$ROLE" == "B" && "$rref" == "refs/heads/main" ]]` | Đã sửa |
| 2026-11-06 | Tích hợp B | `The getter 'targetMuscle' isn't defined for the type 'Exercise'` tại `history_detail_screen.dart:301` | Model `Exercise` dùng field `target`, không có `targetMuscle` | Đổi thành `exercise.target` với null check | Đã sửa |
| 2026-11-06 | Tích hợp B | `Trailing widget consumes entire tile width` crash layout tại `plan_list_screen.dart:221` | `ListTile` nhét `ElevatedButton` vào `trailing` quá rộng cho tile | Thay `ListTile` bằng custom `Column` layout với button full-width phía dưới | Đã sửa |
| 2026-11-08 | S07 | `OffApiException: Invalid argument (string): Contains invalid characters` khi phân tích phản hồi API | `http.Response` mặc định giải mã theo Latin1 nếu server không trả header charset | Dùng `utf8.decode(response.bodyBytes)` trong `off_api_client.dart` | Đã sửa |
| 2026-11-08 | S07 | `ProviderNotFoundException: Could not find Provider<ProgressProvider> above ProgressScreen` trong `test/widget_test.dart` | Màn hình `MainShell` sau khi tích hợp có các tab yêu cầu `ProgressProvider`, `ExerciseProvider`, `WorkoutProvider`, `NutritionProvider` | Bổ sung đầy đủ 7 provider vào `MultiProvider` của `test/widget_test.dart` | Đã sửa |
| 2026-11-08 | S07 | `SqfliteFfiException(1555): UNIQUE constraint failed: exercises.id` trong test | `ExerciseSeeder` đã seed 48 bài tập có ID 1..48 lúc tạo DB, test insert mock exercise trùng ID 1 | Thêm `conflictAlgorithm: ConflictAlgorithm.replace` trong `test/b/stats_test.dart` và `test/workout_session_test.dart` | Đã sửa |
| 2026-11-08 | S07 | Lỗi `A Timer is still pending` (sqflite 10s internal transaction timeout) trong `test/widget_test.dart` | `SqfliteDatabaseMixin` đặt timer 10s cho lock transaction | Thêm `await tester.pump(const Duration(seconds: 11))` để timer chạy hết trước khi kết thúc test | Đã sửa |
| 2026-11-08 | S07 | `test/workout_plan_test.dart` fail vì tên kế hoạch mẫu trả về không theo thứ tự cố định | File `sample_plans.json` có 3 kế hoạch, query order by id desc | Đổi assertion kiểm tra `any((p) => p.name.contains('Toàn thân'))` | Đã sửa |

## 7. Vấn đề mở / nợ kỹ thuật

- [x] Tạo đủ 10 bảng SQLite với quan hệ khóa ngoại ON DELETE CASCADE và SET NULL
- [x] Cài đặt Git hooks và cấu hình danh tính máy A
- [x] Hoàn thiện tầng Auth (Service, Provider, Screen, Gate, tests)
- [x] Hoàn thiện tầng Kế hoạch tập S05 (Service, Provider, ListScreen, EditScreen, Sample plans, 9 tests)
- [x] Hoàn thiện tầng Buổi tập S06 (Service, Provider, SessionScreen, SummaryScreen, RestTimer, contract-v2, 10 tests)
- [x] Chờ Máy B nộp PR0 & PR1 (dữ liệu bài tập & màn hình ExerciseLibraryScreen) để hoàn thiện luồng chọn bài tập thực tế ở S08
- [x] Tích hợp code Máy B (PR0–PR5): sửa 8 bug merge/compile/layout, app chạy ổn trên Chrome
- [x] Hoàn thiện tầng Dinh dưỡng S07 (Food diary, tìm kiếm thực phẩm, quét mã vạch Open Food Facts, 14 unit tests)
- [ ] Bước vào S08 (HomeScreen & Tích hợp hoàn thiện toàn app)
- [ ] Ảnh/GIF bài tập hiện là stub 1x1 pixel → cần thay bằng asset thật hoặc load từ URL

## 8. Việc ngoài code (nhóm tự làm, agent KHÔNG làm)

- [ ] Tự vẽ 7 loại biểu đồ bằng draw.io/StarUML/Visio + chụp màn hình quá trình vẽ
- [ ] Báo cáo docx + pdf, có link GitHub ở trang bìa
- [ ] Slide pptx + pdf (≤ 10 trang)
- [ ] Video demo ≤ 5 phút, ≤ 100 MB
- [ ] Thêm GV vào repo

## 9. Team

| Thành viên | MSSV | Vai trò | Mảng phụ trách | GitHub | Email Git |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Nguyễn Đức Thanh | (điền) | Máy A (Chủ repo) | Kiến trúc, DB, Auth, Plan, Workout, Nutrition, Tích hợp (~70%) | @ducthanh8386 | `thanhygqv9@gmail.com` |
| Lê Văn Sơn | (điền) | Máy B | Dữ liệu & Module Bài tập, Tiến độ, Settings/Team, Lịch sử (~30%) | (điền) | (điền) |

Repo: `https://github.com/ducthanh8386/fit-track.git`

## 10. Lịch sử session

| # | Ngày | Giai đoạn | Đã làm | Commit/PR |
| :--- | :--- | :--- | :--- | :--- |
| 8 | 2026-11-08 | S07 | Hoàn thành toàn diện module Dinh dưỡng (Nutrition): OffApiClient (Open Food Facts v2, timeout 10s, UTF-8, safe parsing, exception types), NutritionService (cache local foods, add/update/delete log entries, macro totals), NutritionProvider (quản lý nhật ký, 4 bữa ăn, macro live preview), 4 màn hình: BarcodeScanScreen (MobileScanner, flash, switch camera, debounce, retry), FoodDetailScreen (preview macro, chọn bữa, nhập gram), ManualFoodScreen (tạo món thủ công), FoodDiaryScreen (lịch ngày, tổng calo vs mục tiêu, 4 ExpansionTile bữa, sửa/xóa gram), 46 i18n keys EN/VI, test nutrition_test 14/14 pass (toàn app 83/83 tests pass 100%). | trên nhánh `feature/a-nutrition` |
| 7 | 2026-11-06 | Tích hợp B | Merge code Máy B (PR0–PR5) vào main, sửa 8 bug tích hợp: merge conflict, _stripDiacritics private, Hero tag collision, SQL WASM double quotes, pre-push hook, targetMuscle undefined getter, ListTile trailing overflow. App chạy ổn Chrome. | trên nhánh `main` |
| 6 | 2026-11-06 | S06 | Triển khai hoàn chỉnh module Buổi tập (Workout Session): WorkoutService (validate set reps>0, kg>=0, volume tổng, CRUD session), WorkoutProvider (active session, elapsed timer, rest countdown timer +/-15s, B4 History API), RestTimerBar, WorkoutSessionScreen (PopScope xác nhận thoát, log sets, điều hướng bài), WorkoutSummaryScreen, cập nhật CHANGELOG contract-v2, bộ unit test workout_session_test 10/10 pass (tổng 43/43 tests pass 100%) | `e99619e` |
| 5 | 2026-11-05 | S05 | Triển khai hoàn chỉnh module Kế hoạch tập (Workout Plan): WorkoutService (validate tên, ngày, set/rep; CRUD plan; seedSamplePlans ánh xạ source_id), PlanProvider (quản lý plans, PlanDraft thêm/xóa/sửa ngày, thêm/xóa/reorder bài tập), PlanListScreen (ListView, EmptyState, FAB, BottomSheet kế hoạch mẫu, AlertDialog xóa), PlanEditScreen (Form, ExpansionTile ngày, ReorderableListView, hook ExerciseLibraryScreen), i18n EN/VI, bộ unit test workout_plan_test pass 100% | (nhánh `feature/a-plan`) |
| 4 | 2026-11-05 | S04 | Triển khai hoàn chỉnh tầng Auth & Shell: AuthService (SHA-256 + salt ngẫu nhiên), AuthProvider (restoreSession, login, register, deleteMyData, logout), LoginScreen, RegisterScreen, MainShell 5 tab, AuthGate tự động điều hướng, hoàn thiện bộ unit test auth_test và widget_test | (nhánh `feature/a-repo-setup`) |
| 3 | 2026-11-05 | S01 | Thiết lập cấu trúc docs/, AGENTS.md, .github/, tools/git/, cài đặt hook, cập nhật README, chuẩn hóa .gitignore và chuyển đổi quy trình 2 máy | (nhánh `feature/a-repo-setup`) |
| 2 | 2026-11-05 | Phase 2 | Triển khai 10 models, DatabaseHelper, 5 Repositories của A, stubs hợp đồng cho B, unit tests pass 100% | `6674451` |
| 1 | 2026-11-04 | Phase 1 | Thêm dependencies, cấu hình l10n EN/VI, dựng cây thư mục 4 tầng, core theme/routes/validators, PrefsStore, SettingsProvider | `b531d7a` |
| 0 | 2026-11-04 | – | Viết SRS/SAD, project_context, project_memory, bộ prompt ban đầu | – |

---

## Quy tắc cập nhật (agent bắt buộc làm cuối session)

1. Sửa **Mục 1** và dòng "Last updated".
2. Tick **Mục 2, 3** chỉ khi đã chạy được và test thủ công.
3. Thêm/sửa dòng trong **Mục 4** cho mỗi file tạo mới hoặc đổi mục đích.
4. Bug đã sửa ghi vào **Mục 6**. Quyết định mới ghi vào **Mục 5**.
5. Thêm một dòng vào **Mục 10**.
6. Giữ file ngắn gọn, thực tế. Nếu code và tài liệu mâu thuẫn: **tin code**, sửa file này.
