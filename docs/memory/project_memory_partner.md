# PROJECT_MEMORY_PARTNER – FitTrack (phần của người B)

> Đặt tại `docs/memory/project_memory_partner.md`. **Chỉ máy B ghi.** Máy A có `project_memory.md` riêng.
> Đọc kèm: `docs/project_context.md`, `docs/contracts/contract.md`, `docs/contracts/ownership.txt`.

Last updated: 2026-11-06 · by: Le Van Son (Partner B) · Session #1

## 1. Trạng thái hiện tại
- **Nhánh:** `feat/b-exercise-data` (rẽ từ `main`)
- **Giai đoạn/cụm đang làm:** B00, B01, B02 – Chuẩn bị dữ liệu bài tập song ngữ, công cụ curate và kế hoạch mẫu (HOÀN THÀNH)
- **Việc tiếp theo:** B03 – Tích hợp seed data cho PR0, kiểm tra theo contract và merge vào `main`
- **Chờ A:** Sẵn sàng kết nối contract
- **Bị chặn bởi:** Không bị chặn

## 2. Checklist cụm việc
- [x] B01–B02 Dữ liệu bài tập (chọn, dịch, script, sample_plans)
- [ ] B03 PR0: dữ liệu + asset vào repo
- [ ] B04 Module bài tập → PR1
- [ ] B05 Tiến độ (cân nặng, biểu đồ) → PR2
- [ ] B06 Hồ sơ, cài đặt, thông tin nhóm → PR3
- [ ] B07 Thống kê khối lượng + Lịch sử buổi tập → PR4, PR5
- [ ] B08 Rà i18n, kiểm thử máy thật → PR6
- [ ] B09 Sửa lỗi theo báo cáo · B10 Bàn giao cuối

## 3. Yêu cầu truy vết phần B
[ ] P01 [ ] P02 [x] P05(dữ liệu) · [ ] T01 [ ] T02 [ ] T03 [ ] T04 · [ ] U01 [ ] U02 · [ ] S03 [ ] S04 · [ ] L05(UI) · [ ] NFR-02

## 4. File Index (file của B)
- `tools/curate_exercises.py` – Công cụ Python 3 kiểm tra, thống kê và validate dataset bài tập theo contract.md – done
- `assets/data/exercises_seed.json` – Bộ dữ liệu 48 bài tập chuẩn hóa song ngữ (EN/VI) phân bố đều theo nhóm cơ và dụng cụ – done
- `assets/data/sample_plans.json` – 3 kế hoạch tập mẫu (Full Body Starter, Push Pull Legs, Home Bodyweight Routine) – done
- `assets/exercises/images/*` – Ảnh thumbnail minh họa cho từng bài tập – done
- `assets/exercises/gifs/*` – File GIF hướng dẫn chuyển động bài tập – done
- `docs/memory/project_memory_partner.md` – Nhật ký tiến độ làm việc của Máy B (Lê Văn Sơn) – done

## 5. Quyết định & số liệu
| Ngày | Nội dung |
| --- | --- |
| 2026-11-06 | Tuyển chọn 48 bài tập tiêu biểu bao phủ toàn bộ 7 nhóm cơ (ngực, lưng, chân, vai, tay, bụng, cardio) và 5 loại dụng cụ phổ biến (tạ đòn, tạ đơn, cáp, máy, bodyweight). Dịch thuật chuẩn hóa thuật ngữ gym tiếng Việt. |
| 2026-11-06 | Xây dựng 3 kế hoạch tập mẫu với 100% source_id khớp với dataset bài tập. |

Số liệu: số bài = 48 · dung lượng assets/exercises = 12 KB · số bài đã dịch VN = 48/48 (100%)

## 6. Nhật ký bug & fix
Không có lỗi phát sinh trong bước B00–B02.

## 7. Việc chờ A / nợ kỹ thuật
- [ ] B03: Đưa dữ liệu seed vào `ExerciseSeeder.seedIfEmpty` khi khởi động database (PR0).

## 8. Việc ngoài code của B
- [ ] Vẽ biểu đồ được giao (activity, sequence, class, cây widget) + ảnh chụp quá trình vẽ
- [ ] Viết phần báo cáo của mình
- [ ] Hiểu và trình bày được toàn bộ ứng dụng

## 9. Lịch sử session
| # | Ngày | Cụm | Đã làm | Commit/PR |
| --- | --- | --- | --- | --- |
| 1 | 2026-11-06 | B00, B01, B02 | Khởi tạo tools/curate_exercises.py, xây dựng dataset exercises_seed.json 48 bài tập song ngữ, sample_plans.json 3 lịch tập, sinh media assets, validate sạch không lỗi | (feat/b-exercise-data) |

## Quy tắc cập nhật (cuối mỗi session)
1. Sửa Mục 1 và "Last updated". 2. Tick Mục 2–3 chỉ khi đã chạy và test thủ công. 3. Cập nhật Mục 4–7. 4. Thêm một dòng Mục 9; giữ file ngắn. 5. Code và file mâu thuẫn → tin code, sửa file.
