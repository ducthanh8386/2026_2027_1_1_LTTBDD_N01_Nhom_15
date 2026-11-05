# QUY TRÌNH GIT CHO HAI MÁY

Đặt vào repo tại `docs/git_workflow.md`. GitHub là nơi duy nhất đồng bộ code và tài liệu.

```text
main ──●───────●(PR0 data)──●(PR1)──●────●(contract-v2)──●(PR..)────────▶
        \ tag contract-v1        ▲        ▲
 feature/a-*  ●──●──●────────────┘ (PR của A)
 feature/b-*        ●──●──●───────┘ (PR của B)
```

## 1. Danh tính Git (mỗi máy, một lần)
```bash
git config --local user.name  "Họ tên thật của người ngồi máy"
git config --local user.email "email đã gắn với tài khoản GitHub của người đó"
bash tools/git/install_hooks.sh <A|B> <email>
```
Hook chặn commit khi email lệch, chặn force-push, chặn B push thẳng `main`, và chặn B sửa file của A. Hook nằm trong `.git/hooks` nên **phải cài trên từng máy** và không đồng bộ qua Git. Agent không được dùng `--author`, `--reset-author`, `--no-verify`, `git config --global user.*` để đổi danh tính.

## 2. Nhánh
| Ai | Tên nhánh | Rẽ từ |
| --- | --- | --- |
| A | `feature/a-<giai-đoạn>` (vd `feature/a-database`) | `main` mới nhất |
| B | `feature/b-<cụm>` (vd `feature/b-exercise`) | `feature/b-exercise-data` (B01–B03): rẽ từ `main` sau A01, rồi `git merge contract-v1` trước PR0; các cụm sau: `main` mới nhất |
Mỗi giai đoạn/cụm một nhánh ngắn hạn, PR nhỏ, dễ review. Không dùng chung nhánh giữa hai máy.

## 3. Khi nào làm gì
| Sự kiện | Hành động |
| --- | --- |
| A xong một giai đoạn | A push nhánh, mở PR vào `main`, tự review theo checklist, merge (Merge commit), `git checkout main && git pull`, xóa nhánh; push tag nếu có; báo B "main đã có <giai đoạn>" |
| A đặt tag `contract-v1/v2/v1.x` | `git push origin main --tags` (bắt buộc push trước khi báo B) |
| B được báo main đổi | B: `git fetch origin && git merge origin/main` vào nhánh đang làm; `flutter pub get && flutter gen-l10n && flutter analyze` |
| B bắt đầu cụm mới | `git checkout main && git pull origin main && git checkout -b feature/b-<cụm>` |
| B xong cụm | merge origin/main → analyze/test → gỡ dữ liệu giả → push → mở PR (template) → báo A |
| A nhận PR của B | prompt `A_review_PR.md` → merge (Merge commit) → cập nhật `project_memory.md` |
| Cuối mỗi phiên (cả hai) | commit + push nhánh đang làm (nhánh push được tự do, kể cả dở dang) |
| Muốn đưa phần chưa xong cho người kia xem | push nhánh; người kia `git fetch` rồi đọc `git show origin/<nhánh>:<file>` (không merge) |

## 4. Tránh hai máy sửa cùng một file
1. Bảng quyền sở hữu `ownership.txt` + hook ở máy B.
2. `pubspec.yaml`, `main.dart`, `routes.dart`, `database_helper.dart`, `constants.dart`, `theme.dart` chỉ A sửa. B cần đổi → Issue `contract-change`.
3. `.arb`: B chèn key sau `"appName"`, A thêm cuối file; key B có tiền tố. File `app_localizations*.dart` là file sinh: không sửa tay.
4. Memory: A chỉ ghi `project_memory.md`; B chỉ ghi `project_memory_partner.md`.
5. A không sửa file của B trên nhánh của A. Nếu cần sửa gấp (bug chặn đường) → A mở Issue và để B sửa; chỉ khi B không phản hồi, A sửa trên nhánh riêng, ghi rõ trong PR và báo B.

## 5. Xung đột
1. `.arb`: giữ cả hai khối key, kiểm tra JSON hợp lệ (dấu phẩy), `flutter gen-l10n`, chạy app rồi mới commit.
2. File sinh `app_localizations*.dart`: bỏ bản xung đột, chạy `flutter gen-l10n`, `git add`.
3. File không thuộc quyền B: lấy bản của A (`git checkout origin/main -- <file>`), B làm lại phần cần qua A.
4. Xong: `flutter pub get && flutter analyze && flutter run`, rồi mới `git commit` (merge commit).
Dùng `merge`, không `rebase` nhánh đã push, không `--force`.

## 6. Commit trung thực và chuyên nghiệp
- Commit nhỏ ngay trong lúc làm (một việc một commit): `Add ExerciseRepository with search filter`, `Fix empty state in ProgressScreen`. Thì hiện tại, tiếng Anh, đúng nội dung.
- Không commit giả, không commit rỗng, không gán commit cho người khác.
- Có thể **tách lại** các thay đổi dở thành nhiều commit hợp lý bằng `git add -p` / `git reset --soft`, **chỉ khi chưa push** và mỗi commit trung gian vẫn build được. Kiểm tra: `bash tools/git/check_commits.sh origin/main` (thêm `--build` trước khi nộp). Đã push thì không viết lại lịch sử.
- Merge PR bằng **Merge commit** (không squash, không rebase merge) để giữ lịch sử từng người. Cài đặt GitHub: Settings → General → Pull Requests: chỉ bật "Allow merge commits".
- Không commit `build/`, `.dart_tool/`, `.env`, `local.properties`, dataset gốc, file keystore.

## 7. Cứu hộ
| Tình huống | Cách xử lý |
| --- | --- |
| Commit nhầm lên `main` (chưa push) | `git branch feature/<x>` giữ commit, rồi `git reset --hard origin/main` trên `main` (chỉ khi chưa push và đã chắc đã có nhánh giữ commit) |
| Commit sai email (chưa push) | `git commit --amend --reset-author` bằng đúng danh tính của mình; đã push thì báo A, không tự rewrite |
| Push bị từ chối | `git pull --no-rebase origin <nhánh>` rồi push; không `--force` |
| Lỡ sửa file của A | `git checkout origin/main -- <file>`, rồi mở Issue nếu thật sự cần đổi |
| analyze lỗi sau merge | sửa trước khi commit merge; lỗi ở file người kia → Issue `bug` |
