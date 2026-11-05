# ANTIGRAVITY TRÊN HAI MÁY (một tài khoản dùng chung)

> Căn cứ: trang tài liệu chính thức *Plans* và *Rules* của Antigravity (kiểm tra lại khi bắt đầu, vì giới hạn có thể đổi). Chỗ nào ghi "chưa xác nhận" nghĩa là không có tài liệu nói rõ.

## 1. Tài khoản
- Antigravity đăng nhập bằng tài khoản Google. Đăng nhập cùng tài khoản trên hai máy: không thấy tài liệu cấm (chưa xác nhận giới hạn số thiết bị).
- Bạn đã chọn dùng chung một tài khoản. Hệ quả:
  - **Quota có khả năng dùng chung một túi** (tài liệu nói hạn mức theo gói Google AI; không nói rõ theo tài khoản hay theo máy → coi là theo tài khoản). Gói Pro/Ultra làm mới mỗi 5 giờ; không có gói thì làm mới theo tuần. Hạn mức tính theo khối lượng việc của agent, không theo số prompt.
  - Cách giảm rủi ro cạn quota: không chạy tác vụ agent dài ở hai máy cùng lúc; báo nhau "tôi đang chạy A06" trước khi chạy giai đoạn nặng (phase buổi tập, dinh dưỡng); xem mức dùng ở Settings của Antigravity; tận dụng prompt ngắn, đọc file có chọn lọc.
  - Có báo cáo của người dùng trên diễn đàn Google về khóa quota bất thường khi nhiều phiên/tài khoản dùng cùng lúc; Google chưa xác nhận nguyên nhân. Đừng dựa vào đó, chỉ nên tránh chạy song song nặng.
  - Quyền riêng tư: đăng nhập tài khoản chung lên máy B nghĩa là B có quyền truy cập vào tài khoản Google đó trong Antigravity/trình duyệt của máy B. Dùng tài khoản Google **dành riêng cho đồ án**, bật xác minh 2 bước, không đăng nhập Gmail/Drive cá nhân vào cùng profile trình duyệt.
  - Nếu sau này cạn quota thường xuyên: tạo thêm tài khoản cho B; không cần đổi gì trong bộ prompt.
- Tài khoản Antigravity (Google) ≠ danh tính Git (`user.name/email`) ≠ tài khoản GitHub. Ba thứ độc lập. Commit luôn mang danh tính Git của người ngồi máy, bất kể tài khoản Antigravity.

## 2. Workspace
- Mỗi máy tự `git clone` repo vào thư mục riêng và mở thư mục đó trong Antigravity. Antigravity không lưu hộ mã nguồn.
- Mỗi máy có nhánh làm việc riêng (A: `feature/a-*`, B: `feature/b-*`). Hai máy không cùng checkout một nhánh.

## 3. Rules (cách agent biết quy tắc)
Theo tài liệu Rules của Antigravity:
- Quy tắc workspace: `AGENTS.md` hoặc `GEMINI.md` ở thư mục workspace/gốc repo (luôn bật, không cần frontmatter) và `.agents/rules/*.md` (tên cũ `.agent/rules/*.md` vẫn chạy). File trong `rules/` cần frontmatter `trigger:` (`always_on`, `model_decision`, `glob`, `manual`); thiếu hoặc sai frontmatter thì bị bỏ qua im lặng.
- Giới hạn: mỗi file tối đa 24.000 byte; tổng các rule luôn bật tối đa 20.000 token. Vì vậy `AGENTS.md` giữ ngắn (~4–5 KB), phần dài để ở `docs/` và bảo agent đọc đầu phiên.
- Bộ này dùng 2 lớp:
  1. `AGENTS.md` (commit vào repo, cả hai máy cùng đọc): quy tắc chung.
  2. `.agents/rules/00_machine_role.md` (KHÔNG commit, thêm vào `.git/info/exclude`): nói máy này là A hay B. Không đồng bộ giữa hai máy.
- Phòng hờ: prompt `*_start_session.md` tự khai báo vai trò, nên nếu bản Antigravity của bạn không nạp rule như mô tả thì phiên vẫn đúng.
- Workflows (`.agent/workflows`): bộ này không dùng.

## 4. Quyền chạy lệnh và an toàn
- Đặt chế độ chạy lệnh terminal ở mức **hỏi/duyệt** (tên tùy chọn có thể khác theo phiên bản), đừng bật tự chạy mọi lệnh. Nếu có danh sách chặn (deny list): `git push --force`, `git push -f`, `git reset --hard`, `git clean -fd`, `rm -rf`, `git config --global`, `--no-verify`.
- Luôn tự đọc lệnh `git push`, `git merge`, `git tag` trước khi duyệt.
- Khi agent đề nghị Firebase/đổi gói/đổi kiến trúc → từ chối.

## 5. Cái gì KHÔNG tự đồng bộ giữa hai máy
File chưa commit · nhánh chưa push · tag chưa push · hook Git (`.git/hooks`) · rule cục bộ (`00_machine_role.md`, `~/.gemini/*`) · cấu hình/MCP của Antigravity · `local.properties`, `.env`, keystore · thư mục `build/`, `.dart_tool/` · dữ liệu emulator/máy thật (DB SQLite, SharedPreferences) · lịch sử hội thoại của agent (chưa xác nhận có đồng bộ qua tài khoản hay không; cứ coi là không). **Mọi thứ cần giữ phải nằm trong Git** (code, `docs/memory/*`, `docs/contracts/*`).
