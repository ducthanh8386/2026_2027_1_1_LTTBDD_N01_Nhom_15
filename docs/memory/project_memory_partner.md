# PROJECT_MEMORY_PARTNER – FitTrack (phần của người B)

> Đặt tại `docs/memory/project_memory_partner.md`. **Chỉ máy B ghi.** Máy A có `project_memory.md` riêng.
> Đọc kèm: `docs/project_context.md`, `docs/contracts/contract.md`, `docs/contracts/ownership.txt`.

Last updated: 2026-11-08 · by: Le Van Son (Partner B) · Session #7

## 1. Trạng thái hiện tại
- **Nhánh:** `chore/b-i18n-and-tests` (chuẩn bị merge vào `main`)
- **Giai đoạn/cụm đang làm:** B08 – Rà soát đa ngôn ngữ (i18n), kiểm thử máy thật & audit test suite (HOÀN THÀNH)
- **Việc tiếp theo:** B09 – Sửa lỗi giao diện/edge-cases & hoàn thiện bàn giao đồ án (Phase 6)
- **Chờ A:** Không bị chặn
- **Bị chặn bởi:** Không bị chặn

## 2. Checklist cụm việc
- [x] B01–B02 Dữ liệu bài tập (chọn, dịch, script, sample_plans)
- [x] B03 PR0: dữ liệu + asset vào repo
- [x] B04 Module bài tập → PR1
- [x] B05 Tiến độ (cân nặng, biểu đồ) → PR2
- [x] B06 Hồ sơ, cài đặt, thông tin nhóm → PR3
- [x] B07 Thống kê khối lượng + Lịch sử buổi tập → PR4, PR5
- [x] B08 Rà i18n, kiểm thử máy thật → PR6
- [ ] B09 Sửa lỗi theo báo cáo · B10 Bàn giao cuối

## 3. Yêu cầu truy vết phần B
[x] P01 [x] P02 [x] P05(dữ liệu) · [x] T01 [x] T02 [x] T03 [x] T04 · [x] U01 [x] U02 · [x] S03 [x] S04 · [x] L05(UI) · [x] NFR-02

## 4. File Index (file của B)
- `tools/curate_exercises.py` – Công cụ Python 3 kiểm tra, thống kê và validate dataset bài tập theo contract.md – done
- `tools/check_arb.py` – Tool Python 3 chuẩn kiểm tra đối xứng ARB giữa app_en.arb và app_vi.arb, placeholder và cú pháp JSON – done
- `assets/data/exercises_seed.json` – Bộ dữ liệu 48 bài tập chuẩn hóa song ngữ (EN/VI) phân bố đều theo nhóm cơ và dụng cụ – done
- `assets/data/sample_plans.json` – 3 kế hoạch tập mẫu (Full Body Starter, Push Pull Legs, Home Bodyweight Routine) – done
- `assets/exercises/images/*` – Ảnh thumbnail minh họa cho từng bài tập – done
- `assets/exercises/gifs/*` – File GIF hướng dẫn chuyển động bài tập – done
- `lib/data/seed/exercise_seed.dart` – Triển khai ExerciseSeeder.seedIfEmpty đọc assets nạp vào SQLite – done
- `lib/data/repositories/exercise_repository.dart` – Triển khai ExerciseRepository tìm kiếm đa năng, lọc nhóm cơ/dụng cụ – done
- `lib/data/repositories/weight_repository.dart` – Triển khai WeightRepository upsert UNIQUE(user_id, date), findRange, latest, delete – done
- `lib/data/repositories/stats_repository.dart` – Triển khai StatsRepository thống kê tổng hợp: volume theo buổi, max weight theo bài, weekly stats, kcal từ food log – done
- `lib/services/stats_service.dart` – Triển khai StatsService: StatsRange, WeightPoint, VolumePoint, WeeklySummary, volumeSeries, maxWeightSeries, weeklySummary – done
- `lib/services/profile_calc.dart` – Tiện ích tính toán thuần BMR (Mifflin-St Jeor 1990), TDEE, kcal mục tiêu, BMI – done
- `lib/providers/exercise_provider.dart` – ExerciseProvider quản lý state bài tập, debounce 250ms, cache byId O(1) – done
- `lib/providers/progress_provider.dart` – ProgressProvider quản lý state cân nặng, khối lượng tập, max weight bài tập và weeklySummary – done
- `lib/screens/plan/exercise_library_screen.dart` – Màn hình thư viện bài tập, tìm kiếm, FilterChip, selectMode – done
- `lib/screens/plan/exercise_detail_screen.dart` – Màn hình chi tiết bài tập: GIF động, chips, hướng dẫn đánh số – done
- `lib/screens/progress/progress_screen.dart` – Màn hình tiến độ: TabBar cân nặng / khối lượng, BarChart fl_chart, thẻ KPI khối lượng, weekly summary banner, max weight dropdown – done
- `lib/screens/progress/add_weight_sheet.dart` – Bottom sheet ghi nhận cân nặng, chọn ngày, validate 20-300 kg – done
- `lib/screens/workout/history_screen.dart` – Màn hình lịch sử buổi tập: nhóm theo ngày, tên kế hoạch hoặc "Buổi tập tự do", thời lượng, volume, số set, xóa kèm AlertDialog – done
- `lib/screens/workout/history_detail_screen.dart` – Màn hình chi tiết buổi tập: header tóm tắt, danh sách bài tập thứ tự, danh sách set logs (rep × kg) và volume từng bài – done
- `lib/screens/settings/profile_screen.dart` – Màn hình hồ sơ: cập nhật chỉ số, tính BMR/TDEE/Kcal tự động, lưu qua AuthProvider – done
- `lib/screens/settings/settings_screen.dart` – Màn hình cài đặt: theme sáng/tối, đổi ngôn ngữ EN/VI, xóa dữ liệu 2 bước, đăng xuất – done
- `lib/screens/settings/team_data.dart` – File hằng số tập trung thông tin dự án, giảng viên, thành viên và ghi công bản quyền – done
- `lib/screens/settings/team_info_screen.dart` – Màn hình thông tin nhóm: card thành viên, link GitHub mở url_launcher, ghi công dataset – done
- `test/b/exercise_module_test.dart` – 8 unit tests kiểm tra Seeder, ExerciseRepository, ExerciseProvider – done
- `test/b/progress_test.dart` – 7 unit tests kiểm tra WeightRepository, StatsService, ProgressProvider – done
- `test/b/profile_calc_test.dart` – 5 unit tests kiểm tra công thức BMR, TDEE, KcalTarget, BMI – done
- `test/b/stats_test.dart` – Unit tests kiểm tra StatsRepository, StatsService và WeeklySummary – done
- `test/b/i18n_module_test.dart` – Unit tests kiểm tra tính toàn vẹn và localization keys của module B – done
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

Số liệu: số bài = 48 · dung lượng assets/exercises = 12 KB · số bài đã dịch VN = 48/48 (100%) · tổng localization keys = 243 (100% EN/VI match)

## 6. Nhật ký bug & fix
- Đã khắc phục các chuỗi hardcode tiếng Việt tại ProfileScreen (giới tính, mục tiêu, thông báo), SettingsScreen (hộp thoại xác nhận xóa dữ liệu 2 bước, đăng xuất), TeamInfoScreen (thông báo lỗi mở link) và HistoryScreen.
- Bổ sung `tools/check_arb.py` để tự động hóa kiểm tra tính nhất quán giữa `app_en.arb` và `app_vi.arb`.

## 7. Việc chờ A / nợ kỹ thuật
- Không có. B08 hoàn tất xuất sắc và toàn bộ các module của B đã sẵn sàng cho Phase 6 (Fix Bug & QA).

## 8. Việc ngoài code của B
- [ ] Vẽ biểu đồ được giao (activity, sequence, class, cây widget) + ảnh chụp quá trình vẽ
- [ ] Viết phần báo cáo của mình
- [ ] Hiểu và trình bày được toàn bộ ứng dụng

## 9. Lịch sử session
| # | Ngày | Cụm | Đã làm | Commit/PR |
| --- | --- | --- | --- | --- |
| 7 | 2026-11-08 | B08 | Tạo tools/check_arb.py (243 keys), rà soát loại bỏ hardcode tại Profile, Settings, History, Progress, Exercise; thêm test/b/i18n_module_test.dart | `chore(i18n)` |
| 6 | 2026-11-06 | B07 | Triển khai StatsRepository, StatsService, ProgressScreen (BarChart & Max Weight), HistoryScreen, HistoryDetailScreen, test/b/stats_test.dart | `feat(stats)` |
| 5 | 2026-11-06 | B06 | Triển khai ProfileScreen, SettingsScreen, TeamInfoScreen, TeamData, profile_calc.dart, 5 unit tests pass 100% | `9d44399` |
| 4 | 2026-11-06 | B05 | Triển khai WeightRepository, StatsService, ProgressProvider, ProgressScreen (fl_chart), AddWeightSheet, 7 unit tests pass 100% | `6221fc2` |
| 3 | 2026-11-06 | B04 | Triển khai ExerciseDetailScreen (GIF media, chips, hướng dẫn), hoàn tất module bài tập B04 | `3cb4fc3` |
| 2 | 2026-11-06 | B04 | Triển khai Seeder, ExerciseRepository, ExerciseProvider, ExerciseLibraryScreen, i18n, unit test 8/8 pass | `73a251d` |
| 1 | 2026-11-06 | B00–B03 | Khởi tạo dataset bài tập, kế hoạch mẫu, công cụ curate, merge PR0 vào main | `4ae6631`, `3a39056` |

## Quy tắc cập nhật (cuối mỗi session)
1. Sửa Mục 1 và "Last updated". 2. Tick Mục 2–3 chỉ khi đã chạy và test thủ công. 3. Cập nhật Mục 4–7. 4. Thêm một dòng Mục 9; giữ file ngắn. 5. Code và file mâu thuẫn → tin code, sửa file.
