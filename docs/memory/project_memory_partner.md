# PROJECT_MEMORY_PARTNER – FitTrack (phần của người B)

> Đặt tại `docs/memory/project_memory_partner.md`. **Chỉ máy B ghi.** Máy A có `project_memory.md` riêng.
> Đọc kèm: `docs/project_context.md`, `docs/contracts/contract.md`, `docs/contracts/ownership.txt`.

Last updated: 2026-11-11 · by: Le Van Son (Partner B) · Session #8

## 1. Trạng thái hiện tại
- **Nhánh:** `fix/b-ui-and-edge-cases` (sẵn sàng merge vào `main`)
- **Giai đoạn/cụm đang làm:** Bước 6.1 (B09 & B_handover) – Rà soát toàn diện UI overflow, màn hình nhỏ 320px, tránh bàn phím, xử lý empty-states, 100% đa ngôn ngữ (265 keys), kiểm thử & hoàn thiện bàn giao đồ án (HOÀN THÀNH TOÀN DIỆN).
- **Việc tiếp theo:** Bàn giao kỹ thuật cho Máy A, hoàn thiện slide báo cáo, vẽ sơ đồ UML và chuẩn bị bảo vệ đồ án trước giảng viên.
- **Chờ A:** Không bị chặn.
- **Bị chặn bởi:** Không bị chặn.

## 2. Checklist cụm việc
- [x] B01–B02 Dữ liệu bài tập (chọn, dịch, script, sample_plans)
- [x] B03 PR0: dữ liệu + asset vào repo
- [x] B04 Module bài tập → PR1
- [x] B05 Tiến độ (cân nặng, biểu đồ) → PR2
- [x] B06 Hồ sơ, cài đặt, thông tin nhóm → PR3
- [x] B07 Thống kê khối lượng + Lịch sử buổi tập → PR4, PR5
- [x] B08 Rà i18n, kiểm thử máy thật → PR6
- [x] B09 Sửa lỗi giao diện & edge-cases (Bước 6.1)
- [x] B10 Bàn giao cuối và tài liệu hướng dẫn bảo vệ

## 3. Yêu cầu truy vết phần B
[x] P01 [x] P02 [x] P05(dữ liệu) · [x] T01 [x] T02 [x] T03 [x] T04 · [x] U01 [x] U02 · [x] S03 [x] S04 · [x] L05(UI) · [x] NFR-02

## 4. File Index (file của B)
- `tools/curate_exercises.py` – Công cụ Python 3 kiểm tra, thống kê và validate dataset bài tập theo contract.md – done
- `tools/check_arb.py` – Tool Python 3 chuẩn kiểm tra đối xứng ARB giữa app_en.arb và app_vi.arb, placeholder và cú pháp JSON (265 keys) – done
- `tools/download_exercise_assets.py` – Tool Python 3 tải toàn bộ 48/48 file GIF thực tế chất lượng cao từ Gym Visual mirror – done
- `assets/data/exercises_seed.json` – Bộ dữ liệu 48 bài tập chuẩn hóa song ngữ (EN/VI) phân bố đều theo nhóm cơ và dụng cụ – done
- `assets/data/sample_plans.json` – 3 kế hoạch tập mẫu (Full Body Starter, Push Pull Legs, Home Bodyweight Routine) – done
- `assets/exercises/images/*` – Ảnh thumbnail minh họa cho từng bài tập – done
- `assets/exercises/gifs/*` – File GIF hoạt hình mô phỏng động tác thực tế – done
- `lib/data/seed/exercise_seed.dart` – Triển khai ExerciseSeeder.seedIfEmpty đọc assets nạp vào SQLite – done
- `lib/data/repositories/exercise_repository.dart` – Triển khai ExerciseRepository tìm kiếm đa năng, lọc nhóm cơ/dụng cụ – done
- `lib/data/repositories/weight_repository.dart` – Triển khai WeightRepository upsert UNIQUE(user_id, date), findRange, latest, delete – done
- `lib/data/repositories/stats_repository.dart` – Triển khai StatsRepository thống kê tổng hợp: volume theo buổi, max weight theo bài, weekly stats, kcal từ food log – done
- `lib/services/stats_service.dart` – Triển khai StatsService: StatsRange, WeightPoint, VolumePoint, WeeklySummary, volumeSeries, maxWeightSeries, weeklySummary – done
- `lib/services/profile_calc.dart` – Tiện ích tính toán thuần BMR (Mifflin-St Jeor 1990), TDEE, kcal mục tiêu, BMI – done
- `lib/providers/exercise_provider.dart` – ExerciseProvider quản lý state bài tập, debounce 250ms, cache byId O(1) – done
- `lib/providers/progress_provider.dart` – ProgressProvider quản lý state cân nặng, khối lượng tập, max weight bài tập và weeklySummary – done
- `lib/screens/plan/exercise_library_screen.dart` – Màn hình thư viện bài tập, tìm kiếm, FilterChip, selectMode – done
- `lib/screens/plan/exercise_detail_screen.dart` – Màn hình chi tiết bài tập: GIF động, chips, hướng dẫn đánh số, fallback đa ngôn ngữ – done
- `lib/screens/progress/progress_screen.dart` – Màn hình tiến độ: TabBar cân nặng / khối lượng, BarChart fl_chart, thẻ KPI khối lượng, weekly summary banner, max weight dropdown, co dãn FittedBox chống tràn – done
- `lib/screens/progress/add_weight_sheet.dart` – Bottom sheet ghi nhận cân nặng, chọn ngày, validate 20-300 kg, bọc SingleChildScrollView chống đè bàn phím – done
- `lib/screens/workout/history_screen.dart` – Màn hình lịch sử buổi tập: nhóm theo ngày, Wrap badges tránh overflow trên màn hình 320px, xóa kèm AlertDialog – done
- `lib/screens/workout/history_detail_screen.dart` – Màn hình chi tiết buổi tập: header tóm tắt, danh sách bài tập thứ tự, danh sách set logs (rep × kg) tự co dãn (Flexible/Expanded) – done
- `lib/screens/settings/profile_screen.dart` – Màn hình hồ sơ: cập nhật chỉ số, thẻ BMI/BMR responsive, tính tự động, 100% i18n – done
- `lib/screens/settings/settings_screen.dart` – Màn hình cài đặt: theme sáng/tối, đổi ngôn ngữ EN/VI, xóa dữ liệu 2 bước, đăng xuất, 100% i18n – done
- `lib/screens/settings/team_data.dart` – File hằng số tập trung thông tin dự án, giảng viên, thành viên và ghi công bản quyền – done
- `lib/screens/settings/team_info_screen.dart` – Màn hình thông tin nhóm: card thành viên, link GitHub mở url_launcher, ghi công dataset, 100% i18n – done
- `test/b/exercise_module_test.dart` – Unit tests kiểm tra Seeder, ExerciseRepository, ExerciseProvider – done
- `test/b/progress_test.dart` – Unit tests kiểm tra WeightRepository, StatsService, ProgressProvider – done
- `test/b/profile_calc_test.dart` – Unit tests kiểm tra công thức BMR, TDEE, KcalTarget, BMI – done
- `test/b/stats_test.dart` – Unit tests kiểm tra StatsRepository, StatsService và WeeklySummary – done
- `test/b/i18n_module_test.dart` – Unit tests kiểm tra tính toàn vẹn 265 keys localization của module B – done
- `docs/memory/project_memory_partner.md` – Nhật ký tiến độ làm việc của Máy B (Lê Văn Sơn) – done

## 5. Quyết định & số liệu
| Ngày | Nội dung |
| --- | --- |
| 2026-11-06 | Tuyển chọn 48 bài tập tiêu biểu bao phủ toàn bộ 7 nhóm cơ và 5 loại dụng cụ phổ biến. |
| 2026-11-06 | Ghi công bản quyền dữ liệu: "Exercise data and media: hasaneyldrm/exercises-dataset (MIT for data); media © Gym visual — https://gymvisual.com/" |
| 2026-11-06 | Xây dựng biểu đồ đường cân nặng fl_chart mượt mà, xử lý trường hợp rỗng, 1 điểm, và chuỗi ngày bất kỳ. |
| 2026-11-06 | Áp dụng công thức Mifflin-St Jeor (1990) chuẩn khoa học để tính BMR/TDEE trong profile_calc.dart. |
| 2026-11-06 | Thống kê khối lượng tập luyện thuần SQL GROUP BY kết hợp set_logs (reps * weight_kg), tuần tính từ thứ Hai, tích hợp tổng kcal từ food_log_entries. |
| 2026-11-06 | Thiết kế HistoryScreen độc lập chỉ tiêu thụ WorkoutProvider (loadHistory, history, deleteSession), hiển thị "Buổi tập tự do" khi plan bị xóa hoặc null. |
| 2026-11-08 | Hoàn tất audit i18n B08: 243/243 keys khớp 100% giữa EN và VI; loại bỏ toàn bộ chuỗi hardcode ở Profile, Settings, TeamInfo, History, Progress, Exercise screens. |
| 2026-11-09 | Tích hợp thành công toàn bộ 48/48 file media ảnh động GIF thực tế của bài tập từ kho Gym Visual (4.45 MB), phục vụ hiển thị chuyển động trực quan cho đồ án. |
| 2026-11-11 | Rà soát Bước 6.1: Nâng tổng số localization keys lên 265/265 (100% đồng bộ EN/VI); khắc phục triệt để nguy cơ tràn viền (RenderFlex overflow) trên màn hình siêu hẹp 320px và màn hình xoay ngang có bàn phím ảo. |

Số liệu: số bài = 48 · dung lượng assets/exercises = 4.45 MB (48/48 GIF thực tế) · số bài đã dịch VN = 48/48 (100%) · tổng localization keys = 265 (100% EN/VI match)

## 6. Nhật ký bug & fix (Bước 6.1)
- **Tránh tràn bàn phím tại AddWeightSheet:** Bọc Form bằng `SingleChildScrollView` kết hợp `EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset)` giúp không bị RenderFlex overflow khi mở bàn phím ảo trên điện thoại nhỏ hoặc chế độ nằm ngang.
- **Tránh tràn chip trên màn hình 320px tại HistoryScreen:** Thay thế `Row` bằng `Wrap(spacing: 8, runSpacing: 6)` cho 3 chip chỉ số (Thời lượng, Khối lượng, Số hiệp), tự động xuống hàng khi không đủ chiều ngang.
- **Tránh tràn hàng Set log tại HistoryDetailScreen:** Thay thế `Spacer()` bằng `Expanded` kết hợp `TextOverflow.ellipsis` và căn phải cho cột hiệp đấu, đảm bảo hiển thị hoàn hảo từ màn hình 320px đến tablet.
- **Co dãn số liệu thẻ KPI tại ProgressScreen & ProfileScreen:** Bọc các chuỗi số liệu (Current, Change, Min/Max, BMI, BMR, TDEE) trong `FittedBox(fit: BoxFit.scaleDown)` và điều chỉnh padding ngang, tránh vỡ layout khi chỉ số lớn.
- **Loại bỏ 100% chuỗi hardcode còn sót:** Thêm 22 cặp keys mới vào `app_en.arb` và `app_vi.arb` cho Profile (Body Info, Age, Height, Formula footnote), Settings (Appearance, Account data, Wipe data), TeamInfo (University, Course, Instructor, Attributions) và ExerciseDetail (No instructions message).

## 7. Việc chờ A / nợ kỹ thuật
- Không có bất kỳ nợ kỹ thuật nào. Tất cả contract, module, cơ sở dữ liệu và giao diện thuộc phần B đã hoàn thiện 100%, sẵn sàng cho đồ án.

## 8. Hướng dẫn trình bày & Bảo vệ đồ án (Dành riêng cho Lê Văn Sơn)

### A. Kiến trúc 4 tầng của các module Máy B phụ trách
1. **Data Seed & Storage (Tầng 1):**
   - File seed: `assets/data/exercises_seed.json` (48 bài tập chuẩn hóa song ngữ) và `assets/data/sample_plans.json` (3 giáo án mẫu).
   - Nạp dữ liệu: `ExerciseSeeder.seedIfEmpty()` kiểm tra bảng rỗng mới nạp qua transaction, không bao giờ ghi đè dữ liệu người dùng.
   - Thư mục media: `assets/exercises/gifs/` và `images/` lưu trữ offline, nạp ngay tức thì không cần kết nối mạng.
2. **Repositories (Tầng 2):**
   - `ExerciseRepository`: Tìm kiếm bài tập theo từ khóa tiếng Việt / tiếng Anh, lọc theo bodyPart và equipment.
   - `WeightRepository`: Quản lý cân nặng với ràng buộc `UNIQUE(user_id, date)`, hỗ trợ upsert (`conflictAlgorithm: ConflictAlgorithm.replace`), truy vấn theo khoảng ngày.
   - `StatsRepository`: Tính toán tổng hợp qua câu lệnh SQL tối ưu:
     - Volume theo ngày: `SELECT substr(s.started_at, 1, 10), SUM(l.reps * l.weight_kg) ... GROUP BY ...`
     - Kỷ lục tạ tối đa (Max Weight) theo bài tập: `SELECT MAX(l.weight_kg) ... WHERE exercise_id = ? ... GROUP BY date`.
     - Tóm tắt tuần: Số buổi tập và tổng khối lượng trong tuần bắt đầu từ thứ Hai, kèm tổng calo ăn vào từ `food_log_entries`.
3. **Services & Utilities (Tầng 3):**
   - `StatsService`: Chuyển đổi dữ liệu thô từ repository sang danh sách `WeightPoint`, `VolumePoint`, xử lý lấp đầy khoảng trắng thời gian (StatsRange 7 ngày, 30 ngày, Tất cả).
   - `ProfileCalc`: Áp dụng công thức khoa học chuẩn **Mifflin-St Jeor (1990)** để tính tỷ lệ trao đổi chất cơ bản (BMR), nhân hệ số hoạt động ra TDEE, và tính mục tiêu thâm hụt calo (-500 kcal cho giảm mỡ, +300 kcal cho tăng cơ).
4. **Providers & UI Presentation (Tầng 4):**
   - `ExerciseProvider`: Quản lý danh sách bài tập, tích hợp bộ tìm kiếm debounce 250ms tránh lag UI, bộ nhớ đệm `_exerciseMap` tìm bài theo ID với độ phức tạp $O(1)$.
   - `ProgressProvider`: Tự động đồng bộ cân nặng, khối lượng tập luyện và kỷ lục bài tập theo người dùng hiện tại (`currentUser.id`).
   - Giao diện: Thiết kế theo chuẩn Material 3, hỗ trợ cả Light/Dark theme, chuyển đổi tức thì giữa Tiếng Việt và Tiếng Anh (265 keys), vẽ biểu đồ sắc nét bằng `fl_chart`.

### B. Các câu hỏi giảng viên thường hỏi và cách trả lời:
- *Q: Làm sao ứng dụng hoạt động hoàn toàn offline?*
  - **Trả lời:** Toàn bộ dữ liệu 48 bài tập, 3 giáo án mẫu cùng toàn bộ ảnh và file GIF chuyển động đều được bundle trực tiếp trong thư mục `assets/`. Cơ sở dữ liệu SQLite cục bộ được khởi tạo khi mở ứng dụng lần đầu.
- *Q: Biểu đồ cân nặng và khối lượng tập được xử lý như thế nào nếu người dùng chỉ mới tập 1 ngày hoặc chưa ghi nhận cân nặng?*
  - **Trả lời:** Em đã xử lý các edge-cases: khi danh sách rỗng, màn hình hiển thị Empty State trực quan kèm nút bấm hướng dẫn. Khi chỉ có 1 điểm dữ liệu, thuộc tính `maxX` của `LineChartData` được gán tối thiểu bằng 2 để đường biểu diễn không bị sập hay lỗi chia cho 0.
- *Q: Tính năng đa ngôn ngữ được tổ chức như thế nào?*
  - **Trả lời:** Dự án sử dụng hệ thống ARB chuẩn của Flutter (`app_en.arb`, `app_vi.arb`). Nhóm em đã viết riêng script Python `tools/check_arb.py` để audit tự động 100% key parity và đối xứng tham số.

### C. Việc ngoài code cần hoàn thiện trước ngày bảo vệ:
- [ ] Vẽ sơ đồ Activity Diagram cho luồng "Xem thư viện bài tập & Tra cứu chỉ số tiến độ".
- [ ] Vẽ sơ đồ Sequence Diagram cho luồng "Người dùng ghi nhận cân nặng và cập nhật biểu đồ".
- [ ] Chuẩn bị slide phần thuyết trình của Lê Văn Sơn (Tập trung vào Thư viện bài tập, Tiến độ fl_chart, Hồ sơ Mifflin-St Jeor và Lịch sử buổi tập).

## 9. Lịch sử session
| # | Ngày | Cụm | Đã làm | Commit/PR |
| --- | --- | --- | --- | --- |
| 8 | 2026-11-11 | B09 & B_handover | Bước 6.1: Rà soát toàn bộ UI overflow, màn hình nhỏ 320px, SingleChildScrollView bàn phím, Wrap badges, 265 keys i18n, tài liệu bảo vệ | `fix(b-modules)` |
| 7 | 2026-11-08 | B08 | Tạo tools/check_arb.py (243 keys), rà soát loại bỏ hardcode tại Profile, Settings, History, Progress, Exercise; thêm test/b/i18n_module_test.dart | `chore(i18n)` |
| 6 | 2026-11-06 | B07 | Triển khai StatsRepository, StatsService, ProgressScreen (BarChart & Max Weight), HistoryScreen, HistoryDetailScreen, test/b/stats_test.dart | `feat(stats)` |
| 5 | 2026-11-06 | B06 | Triển khai ProfileScreen, SettingsScreen, TeamInfoScreen, TeamData, profile_calc.dart, 5 unit tests pass 100% | `9d44399` |
| 4 | 2026-11-06 | B05 | Triển khai WeightRepository, StatsService, ProgressProvider, ProgressScreen (fl_chart), AddWeightSheet, 7 unit tests pass 100% | `6221fc2` |
| 3 | 2026-11-06 | B04 | Triển khai ExerciseDetailScreen (GIF media, chips, hướng dẫn), hoàn tất module bài tập B04 | `3cb4fc3` |
| 2 | 2026-11-06 | B04 | Triển khai Seeder, ExerciseRepository, ExerciseProvider, ExerciseLibraryScreen, i18n, unit test 8/8 pass | `73a251d` |
| 1 | 2026-11-06 | B00–B03 | Khởi tạo dataset bài tập, kế hoạch mẫu, công cụ curate, merge PR0 vào main | `4ae6631`, `3a39056` |
