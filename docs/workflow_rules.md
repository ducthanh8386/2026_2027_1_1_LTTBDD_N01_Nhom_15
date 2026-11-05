# QUY TẮC LÀM VIỆC CHUNG (A và B)

## 1. Nguyên tắc
1. Một vai trò, một phạm vi: máy A chủ trì kiến trúc, DB, tích hợp; máy B chỉ làm module được giao (`docs/contracts/ownership.txt`).
2. Hợp đồng là luật. Đổi hợp đồng chỉ qua `contract-change`.
3. Mỗi phiên chỉ một cụm việc. Không làm trước giai đoạn sau, không refactor ngoài phạm vi.
4. Mỗi commit build được; `flutter analyze` sạch trước khi commit.
5. Mọi file có đúng một người ghi; xem AGENTS.md mục Memory.

## 2. Vòng đời một phiên (bắt buộc)
**Bắt đầu**
1. Mở thư mục repo trong Antigravity. Dán prompt `A_start_session.md` hoặc `B_start_session.md` (mục "Prompt để dán").
2. `git fetch`, `git checkout <nhánh>`; nếu nhánh có bản mới trên origin: `git pull --ff-only`.
3. Dán prompt giai đoạn hiện tại.
**Kết thúc**
1. Chạy `flutter analyze` + `flutter test`.
2. Dán `A_end_session.md` / `B_end_session.md`: cập nhật memory, commit, push.
3. Nhắn máy kia theo mẫu BÀN GIAO (nhánh, commit, việc cần làm).

## 3. Cổng chuyển giai đoạn (gate)
Chỉ sang giai đoạn sau khi đủ: (1) điều kiện hoàn thành của prompt đạt, (2) `flutter pub get && flutter gen-l10n && flutter analyze && flutter test` sạch, (3) app chạy `flutter run`, (4) memory đã cập nhật và push, (5) với B: PR đã mở/merge theo bảng giai đoạn; với A: nhánh đã merge vào `main` và push tag nếu có.

## 4. Khi nào cập nhật tài liệu chung
| Sự kiện | Ai | Tài liệu |
| --- | --- | --- |
| Hết mỗi giai đoạn của A | A | `project_memory.md` (trạng thái, File Index, quyết định, bug) |
| Hết mỗi cụm của B | B | `project_memory_partner.md` |
| Đổi chữ ký/JSON/route/schema | A (sau Issue của B) | `contract.md`, `CHANGELOG.md`, tag mới |
| PR của B được merge | A | `project_memory.md`: ghi PR/commit đã tích hợp |
| Bug cross-module | người phát hiện mở GitHub Issue nhãn `bug` | A phân loại |

## 5. Kênh liên lạc có dấu vết
GitHub Issue/PR là kênh chính (nhãn: `contract-change`, `bug`, `blocked`, `question`). Tin nhắn ngoài GitHub chỉ để báo "đã push/đã merge".

## 6. Việc ngoài code (nhóm tự làm, agent KHÔNG làm)
Biểu đồ UML/kiến trúc/cây widget tự vẽ bằng draw.io/StarUML/Visio, có ảnh chụp quá trình vẽ; báo cáo bằng lời của nhóm; slide; video demo ≤ 5 phút; thêm giảng viên vào repo. Gợi ý: A vẽ use case, kiến trúc, component; B vẽ activity, sequence, class, cây widget.
