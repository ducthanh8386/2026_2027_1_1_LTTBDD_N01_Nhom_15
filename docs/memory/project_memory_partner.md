# PROJECT_MEMORY_PARTNER – FitTrack (phần của người B)

> Đặt tại `docs/memory/project_memory_partner.md`. **Chỉ máy B ghi.** Máy A có `project_memory.md` riêng.
> Đọc kèm: `docs/project_context.md`, `docs/contracts/contract.md`, `docs/contracts/ownership.txt`.

Last updated: 2026-11-06 · by: Le Van Son (Partner B) · Session #4

## 1. Trạng thái hiện tại
- **Nhánh:** `feat/b-progress-weight` (chuẩn bị merge vào `main`)
- **Giai đoạn/cụm đang làm:** B05 – Module Tiến độ & Cân nặng (HOÀN THÀNH)
- **Việc tiếp theo:** B06 – Hồ sơ người dùng, Cài đặt và Thông tin nhóm
- **Chờ A:** Không bị chặn
- **Bị chặn bởi:** Không bị chặn

## 2. Checklist cụm việc
- [x] B01–B02 Dữ liệu bài tập (chọn, dịch, script, sample_plans)
- [x] B03 PR0: dữ liệu + asset vào repo
- [x] B04 Module bài tập → PR1
- [x] B05 Tiến độ (cân nặng, biểu đồ) → PR2
- [ ] B06 Hồ sơ, cài đặt, thông tin nhóm → PR3
- [ ] B07 Thống kê khối lượng + Lịch sử buổi tập → PR4, PR5
- [ ] B08 Rà i18n, kiểm thử máy thật → PR6
- [ ] B09 Sửa lỗi theo báo cáo · B10 Bàn giao cuối

## 3. Yêu cầu truy vết phần B
[x] P01 [x] P02 [x] P05(dữ liệu) · [x] T01 [x] T02 [ ] T03 [ ] T04 · [ ] U01 [ ] U02 · [ ] S03 [ ] S04 · [ ] L05(UI) · [ ] NFR-02

## 4. File Index (file của B)
- `tools/curate_exercises.py` – Công cụ Python 3 kiểm tra, thống kê và validate dataset bài tập theo contract.md – done
- `assets/data/exercises_seed.json` – Bộ dữ liệu 48 bài tập chuẩn hóa song ngữ (EN/VI) phân bố đều theo nhóm cơ và dụng cụ – done
- `assets/data/sample_plans.json` – 3 kế hoạch tập mẫu (Full Body Starter, Push Pull Legs, Home Bodyweight Routine) – done
- `assets/exercises/images/*` – Ảnh thumbnail minh họa cho từng bài tập – done
- `assets/exercises/gifs/*` – File GIF hướng dẫn chuyển động bài tập – done
- `lib/data/seed/exercise_seed.dart` – Triển khai ExerciseSeeder.seedIfEmpty đọc assets nạp vào SQLite – done
- `lib/data/repositories/exercise_repository.dart` – Triển khai ExerciseRepository tìm kiếm đa năng, lọc nhóm cơ/dụng cụ – done
- `lib/data/repositories/weight_repository.dart` – Triển khai WeightRepository upsert UNIQUE(user_id, date), findRange, latest, delete – done
- `lib/data/repositories/stats_repository.dart` – Khung lớp StatsRepository cho thống kê tổng hợp – done
- `lib/services/stats_service.dart` – Triển khai StatsService: StatsRange, WeightPoint, VolumePoint, WeeklySummary, weightSeries, upsertWeight – done
- `lib/providers/exercise_provider.dart` – ExerciseProvider quản lý state bài tập, debounce 250ms, cache byId O(1) – done
- `lib/providers/progress_provider.dart` – ProgressProvider quản lý state cân nặng, cập nhật user bất đồng bộ an toàn – done
- `lib/screens/plan/exercise_library_screen.dart` – Màn hình thư viện bài tập, tìm kiếm, FilterChip, selectMode – done
- `lib/screens/plan/exercise_detail_screen.dart` – Màn hình chi tiết bài tập: GIF động, chips, hướng dẫn đánh số – done
- `lib/screens/progress/progress_screen.dart` – Màn hình tiến độ: TabBar cân nặng/khối lượng, SegmentedButton (7/30/Tất cả), biểu đồ fl_chart, thẻ KPI – done
- `lib/screens/progress/add_weight_sheet.dart` – Bottom sheet ghi nhận cân nặng, chọn ngày, validate 20-300 kg – done
- `test/b/exercise_module_test.dart` – 8 unit tests kiểm tra Seeder, ExerciseRepository, ExerciseProvider – done
- `test/b/progress_test.dart` – 7 unit tests kiểm tra WeightRepository, StatsService, ProgressProvider – done
- `docs/memory/project_memory_partner.md` – Nhật ký tiến độ làm việc của Máy B (Lê Văn Sơn) – done

## 5. Quyết định & số liệu
| Ngày | Nội dung |
| --- | --- |
| 2026-11-06 | Tuyển chọn 48 bài tập tiêu biểu bao phủ toàn bộ 7 nhóm cơ và 5 loại dụng cụ phổ biến. |
| 2026-11-06 | Ghi công bản quyền dữ liệu: "Exercise data and media: hasaneyldrm/exercises-dataset (MIT for data); media © Gym visual — https://gymvisual.com/" |
| 2026-11-06 | Xây dựng biểu đồ đường cân nặng fl_chart mượt mà, xử lý trường hợp rỗng, 1 điểm, và chuỗi ngày bất kỳ. |

Số liệu: số bài = 48 · dung lượng assets/exercises = 12 KB · số bài đã dịch VN = 48/48 (100%)

## 6. Nhật ký bug & fix
Không có lỗi phát sinh trong bước B05.

## 7. Việc chờ A / nợ kỹ thuật
- [ ] B06: Bắt đầu module Hồ sơ, Cài đặt & Thông tin nhóm.

## 8. Việc ngoài code của B
- [ ] Vẽ biểu đồ được giao (activity, sequence, class, cây widget) + ảnh chụp quá trình vẽ
- [ ] Viết phần báo cáo của mình
- [ ] Hiểu và trình bày được toàn bộ ứng dụng

## 9. Lịch sử session
| # | Ngày | Cụm | Đã làm | Commit/PR |
| --- | --- | --- | --- | --- |
| 4 | 2026-11-06 | B05 | Triển khai WeightRepository, StatsService, ProgressProvider, ProgressScreen (fl_chart), AddWeightSheet, 7 unit tests pass 100% | (feat/b-progress-weight) |
| 3 | 2026-11-06 | B04 | Triển khai ExerciseDetailScreen (GIF media, chips, hướng dẫn), hoàn tất module bài tập B04 | `3cb4fc3` |
| 2 | 2026-11-06 | B04 | Triển khai Seeder, ExerciseRepository, ExerciseProvider, ExerciseLibraryScreen, i18n, unit test 8/8 pass | `73a251d` |
| 1 | 2026-11-06 | B00–B03 | Khởi tạo dataset bài tập, kế hoạch mẫu, công cụ curate, merge PR0 vào main | `4ae6631`, `3a39056` |

## Quy tắc cập nhật (cuối mỗi session)
1. Sửa Mục 1 và "Last updated". 2. Tick Mục 2–3 chỉ khi đã chạy và test thủ công. 3. Cập nhật Mục 4–7. 4. Thêm một dòng Mục 9; giữ file ngắn. 5. Code và file mâu thuẫn → tin code, sửa file.
