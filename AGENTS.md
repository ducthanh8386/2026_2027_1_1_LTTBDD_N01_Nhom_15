# AGENTS.md – FitTrack (quy tắc luôn bật cho mọi phiên Antigravity)

Dự án: app Flutter gym + dinh dưỡng, offline là chính. Stack cố định: Flutter, `provider`, `sqflite`, `shared_preferences`, `http`, `mobile_scanner`, `fl_chart`, `crypto`, `url_launcher`, `intl`.
**KHÔNG dùng Firebase/Firestore. KHÔNG đổi công nghệ.** Nhóm 2 người, 2 máy: **A** (chủ repo, ~70%) và **B** (~30%). Cả hai máy dùng chung một tài khoản Antigravity, nên tránh chạy tác vụ agent dài cùng lúc.

## Đầu MỖI phiên (bắt buộc, chưa viết code)
1. Xác định vai trò: đọc `.agents/rules/00_machine_role.md`. Không có file đó → hỏi người dùng "máy A hay máy B?".
2. Chạy và báo kết quả: `git config user.name`, `git config user.email`, `git branch --show-current`, `git status --short`, `git config --local fittrack.expectedEmail`. Email khác expectedEmail → DỪNG, không commit.
3. `git fetch origin`. Đọc theo thứ tự: `docs/project_context.md` → `docs/contracts/contract.md` → `docs/contracts/ownership.txt` → memory của máy này (A: `docs/memory/project_memory.md`; B: `docs/memory/project_memory_partner.md`) → file prompt phase đang làm.
4. Tóm tắt 3–5 dòng: giai đoạn, việc kế tiếp, rủi ro. Đợi người dùng xác nhận nếu có điểm mơ hồ (tối đa 3 câu hỏi ngắn).

## Kiến trúc 4 tầng (không phá)
Screen/Widget → Provider (ChangeNotifier, có `isLoading`, `error`) → Service (nghiệp vụ, không SQL/HTTP) → Repository/DatabaseHelper/OffApiClient/PrefsStore (không nghiệp vụ). Mọi SQL chỉ nằm trong `lib/data/`. Không query DB trong `build()`.

## Quy tắc code
- Không hardcode chuỗi hiển thị: mọi text qua `.arb` (EN + VI, cùng bộ key). Key của B có tiền tố `exercise…/progress…/profile…/team…/history…` và chèn ngay SAU dòng `"appName"`; key của A thêm CUỐI file. File sinh `lib/l10n/app_localizations*.dart` không sửa tay, không merge tay: xung đột thì chạy lại `flutter gen-l10n`.
- Sau mỗi `await` kiểm tra `mounted` trước khi dùng `BuildContext`. Hủy Timer/controller khi dispose. Dùng `PopScope`, không `WillPopScope`.
- Trước khi dùng API của một gói, kiểm tra phiên bản và cú pháp hiện hành, không đoán.
- Chỉ đọc file cần cho task; không quét cả dự án.

## Git (không thương lượng)
- Không commit trực tiếp lên `main` (cả A lẫn B). A làm trên `feature/a-<tên>`, B làm trên `feature/b-<tên>`, gộp vào `main` bằng Pull Request, kiểu **Merge commit** (không squash).
- Không `push --force`, không `reset --hard` trên nhánh đã push, không rewrite lịch sử đã push, không `--no-verify`, không `--author`, không `--reset-author` thay người khác. Mỗi commit dùng đúng danh tính Git của máy này.
- Commit nhỏ, mỗi commit build được; message tiếng Anh, thì hiện tại, nêu đúng việc đã làm (vd `Add ExerciseRepository with search filter`). Không tạo commit giả. Không commit `build/`, `.env`, `local.properties`.
- Trước khi commit: `flutter analyze` sạch. Trước khi push/PR: `git fetch && git merge origin/main`, `flutter pub get`, `flutter analyze`, `flutter test`.

## Quyền sở hữu file và hợp đồng
- Danh sách file B được sửa: `docs/contracts/ownership.txt`. Mọi file khác thuộc A. Máy B không sửa file của A; cần đổi → mở GitHub Issue nhãn `contract-change` hoặc báo người dùng để báo A.
- Không đổi chữ ký hàm, route, JSON, schema trong `docs/contracts/contract.md` khi chưa có `contract-change` được A duyệt và ghi vào `docs/contracts/CHANGELOG.md`.
- Nếu code và tài liệu mâu thuẫn: tin code, rồi sửa tài liệu (máy A sửa tài liệu chung; máy B sửa memory của B và báo A).

## Memory (mỗi file đúng một người ghi)
- A ghi: `docs/memory/project_memory.md`, `docs/contracts/*`, `docs/project_context.md`.
- B ghi: `docs/memory/project_memory_partner.md`. Máy A không sửa file này; máy B không sửa `project_memory.md`.
- Chỉ tick checklist mục đã chạy và test thủ công.

## Cuối MỖI phiên
Cập nhật memory của máy này, commit, push nhánh hiện tại, rồi in "BÀN GIAO": nhánh, commit cuối, việc dở, việc kế tiếp, điều máy còn lại cần làm (pull/merge/review).
