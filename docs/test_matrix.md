# MA TRẬN KIỂM THỬ TOÀN DIỆN ỨNG DỤNG FITTRACK (TEST MATRIX)

> **Dự án:** FitTrack – Ứng dụng Theo dõi Tập luyện & Dinh dưỡng Cá nhân
> **Tài liệu tham chiếu:** SRS, SAD, `docs/project_context.md`, `docs/contracts/contract.md`
> **Ngày lập / Cập nhật:** 2026-11-11 · Phiên bản: 1.0 (Phase S09 QA)
> **Trạng thái kiểm thử:** 100% Hoàn thành (Automated + Manual)

---

## 1. Tổng quan kết quả kiểm thử

| Nhóm chức năng | Mã YC | Số kịch bản | Đạt (Pass) | Không đạt (Fail) | Tỷ lệ Đạt |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **Xác thực & Phiên làm việc (Auth)** | A01 – A06 | 6 | 6 | 0 | 100% |
| **Hồ sơ cá nhân & Mục tiêu (Profile)** | U01 – U02 | 4 | 4 | 0 | 100% |
| **Kế hoạch tập luyện (Plan)** | P01 – P05 | 8 | 8 | 0 | 100% |
| **Thực hiện buổi tập (Workout Session)** | L01 – L05 | 8 | 8 | 0 | 100% |
| **Tiến độ & Thống kê (Progress)** | T01 – T04 | 6 | 6 | 0 | 100% |
| **Dinh dưỡng & Quét mã vạch (Nutrition)** | N01 – N07 | 10 | 10 | 0 | 100% |
| **Cài đặt & Thông tin nhóm (Settings)** | S01 – S04 | 6 | 6 | 0 | 100% |
| **Trang chủ & Tích hợp (HomeScreen)** | H01 – H04 | 4 | 4 | 0 | 100% |
| **Yêu cầu phi chức năng (NFR)** | NFR01 – NFR07 | 7 | 7 | 0 | 100% |
| **TỔNG CỘNG** | **Tất cả** | **59** | **59** | **0** | **100%** |

---

## 2. Chi tiết Ma trận kiểm thử theo từng Module

### 2.1. Module Xác thực & Quản lý phiên (Auth: A01 – A06)

| Mã TC | Yêu cầu | Tên kịch bản & Các bước kiểm thử | Kết quả kỳ vọng | Kết quả thực tế | Trạng thái | Loại kiểm thử |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **TC-AUTH-01** | A01, A04 | **Đăng ký tài khoản mới hợp lệ**: Nhập họ tên, email mới, mật khẩu ≥ 6 ký tự, xác nhận mật khẩu khớp -> Nhấn Đăng ký. | Tài khoản được tạo trong SQLite; mật khẩu được băm SHA-256 + salt ngẫu nhiên; tự động chuyển sang MainShell. | Hoạt động chính xác, pass mã hóa salt+hash | **PASS** | Automated (`test/auth_test.dart`) |
| **TC-AUTH-02** | A01 | **Chặn đăng ký email trùng lặp**: Nhập email đã tồn tại trong CSDL -> Nhấn Đăng ký. | Hiển thị thông báo lỗi "Email đã được đăng ký"; không tạo bản ghi mới; không crash app. | Báo lỗi đúng, không duplicate | **PASS** | Automated (`test/auth_test.dart`) |
| **TC-AUTH-03** | A02 | **Kiểm tra tính hợp lệ dữ liệu đăng ký (Validation)**: Để trống trường, email sai định dạng, mật khẩu < 6 ký tự, xác nhận mật khẩu không khớp. | Hiển thị lỗi tương ứng ngay tại từng ô nhập liệu; nút Đăng ký bị chặn kích hoạt thành công. | Báo lỗi đỏ dưới từng ô nhập | **PASS** | Automated + Manual |
| **TC-AUTH-04** | A03 | **Đăng nhập với thông tin chính xác**: Nhập đúng email và mật khẩu đã đăng ký -> Nhấn Đăng nhập. | Đăng nhập thành công; lưu `userId` vào SharedPreferences; điều hướng vào MainShell. | Đăng nhập mượt mà, đúng user | **PASS** | Automated (`test/auth_test.dart`) |
| **TC-AUTH-05** | A03 | **Đăng nhập sai email hoặc sai mật khẩu**: Nhập email không tồn tại hoặc mật khẩu sai. | Hiển thị thông báo chung "Email hoặc mật khẩu không chính xác"; không tiết lộ email có tồn tại hay không. | Báo lỗi chung chuẩn bảo mật | **PASS** | Automated (`test/auth_test.dart`) |
| **TC-AUTH-06** | A05, A06 | **Tự động khôi phục phiên & Đăng xuất**: Đóng app mở lại -> Tự vào MainShell; Vào Cài đặt -> Nhấn Đăng xuất -> Xóa session, về màn hình Đăng nhập. | Phiên làm việc được duy trì sau khi khởi động lại; Đăng xuất xóa sạch SharedPreferences. | Hoạt động đúng yêu cầu | **PASS** | Automated (`test/widget_test.dart`) |

---

### 2.2. Module Hồ sơ cá nhân & Tính toán Calo (Profile: U01 – U02)

| Mã TC | Yêu cầu | Tên kịch bản & Các bước kiểm thử | Kết quả kỳ vọng | Kết quả thực tế | Trạng thái | Loại kiểm thử |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **TC-PROF-01** | U01 | **Cập nhật chỉ số cơ thể**: Vào Cài đặt -> Hồ sơ -> Sửa chiều cao (175cm), cân nặng (70kg), tuổi (25), giới tính (Nam), mục tiêu (Tăng cơ). | Lưu thông tin vào bảng `users` SQLite; cập nhật thành công giao diện người dùng. | Dữ liệu lưu đúng vào DB | **PASS** | Automated (`test/auth_test.dart`) |
| **TC-PROF-02** | U02 | **Tính toán tự động BMR & TDEE (Mifflin-St Jeor)**: Thay đổi cân nặng, chiều cao, tuổi, giới tính và mức độ hoạt động. | Tính chính xác BMR theo công thức chuẩn Mifflin-St Jeor 1990; nhân hệ số hoạt động ra TDEE chuẩn. | Kết quả khớp với test toán học | **PASS** | Automated (`test/b/profile_calc_test.dart`) |
| **TC-PROF-03** | U02 | **Tính Calo mục tiêu theo mục tiêu thể hình**: Chọn Tăng cơ (+300-500 kcal), Giảm mỡ (-500 kcal), hoặc Giữ cân. | Calo mục tiêu tự động điền giá trị gợi ý; cho phép người dùng tùy chỉnh số calo theo ý muốn. | Tự động tính đúng mục tiêu | **PASS** | Automated (`test/b/profile_calc_test.dart`) |
| **TC-PROF-04** | U01, N05 | **Lan truyền Calo mục tiêu sang Nhật ký dinh dưỡng**: Đổi Calo mục tiêu từ 2000 -> 2400 kcal tại Profile. | `NutritionProvider` lập tức nhận giá trị 2400 kcal qua ProxyProvider; thanh tiến độ dinh dưỡng cập nhật mục tiêu mới. | Đồng bộ tức thì giữa 2 module | **PASS** | Automated (`test/home_integration_test.dart`) |

---

### 2.3. Module Kế hoạch tập luyện (Plan: P01 – P05)

| Mã TC | Yêu cầu | Tên kịch bản & Các bước kiểm thử | Kết quả kỳ vọng | Kết quả thực tế | Trạng thái | Loại kiểm thử |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **TC-PLAN-01** | P01 | **Thư viện bài tập & Bộ lọc**: Mở Thư viện bài tập -> Lọc theo nhóm cơ (Ngực, Lưng, Chân...) và Dụng cụ (Tạ đòn, Tạ đơn, Máy...). | Hiển thị đúng 48 bài tập đã được tuyển chọn; lọc chính xác theo tiêu chí; tìm kiếm không dấu / có dấu tiếng Việt mượt mà. | Lọc nhanh, không giật lag | **PASS** | Automated (`test/b/exercise_module_test.dart`) |
| **TC-PLAN-02** | P02 | **Chi tiết bài tập**: Bấm vào một bài tập bất kỳ trong danh sách. | Hiển thị ảnh GIF động hướng dẫn chuyển động, nhóm cơ chính, nhóm cơ phụ, dụng cụ và các bước thực hiện đánh số. | Hiển thị GIF và hướng dẫn chi tiết | **PASS** | Manual + Automated |
| **TC-PLAN-03** | P03 | **Tạo kế hoạch tập nhiều ngày**: Nhấn FAB Tạo kế hoạch -> Nhập tên kế hoạch -> Thêm 3 ngày tập -> Chọn bài tập từ thư viện cho mỗi ngày -> Nhập số set và số rep. | Kế hoạch được lưu nguyên tử trong Transaction (gồm `workout_plans`, `plan_days`, `plan_exercises`); hiển thị tại danh sách. | Lưu đủ ngày và bài tập | **PASS** | Automated (`test/workout_plan_test.dart`) |
| **TC-PLAN-04** | P03 | **Xác thực dữ liệu kế hoạch (Validation)**: Tạo kế hoạch không có tên, hoặc ngày không có bài tập, hoặc set/rep ≤ 0. | Báo lỗi tương ứng; không cho phép lưu dữ liệu không hợp lệ. | Báo lỗi đúng thông điệp | **PASS** | Automated (`test/workout_plan_test.dart`) |
| **TC-PLAN-05** | P03 | **Sắp xếp thứ tự bài tập (Reorder)**: Kéo thả đổi vị trí các bài tập trong một ngày tập. | Thứ tự `order_index` được cập nhật chính xác và lưu bền vững vào CSDL SQLite. | Kéo thả mượt mà | **PASS** | Automated (`test/workout_plan_test.dart`) |
| **TC-PLAN-06** | P04 | **Chỉnh sửa kế hoạch tập**: Sửa tên kế hoạch, thêm/bớt ngày tập, thêm/bớt bài tập. | Dữ liệu cũ được cập nhật sạch sẽ trong transaction; không sinh rác bản ghi mồ côi. | Cập nhật sạch sẽ | **PASS** | Automated (`test/workout_plan_test.dart`) |
| **TC-PLAN-07** | P04 | **Xóa kế hoạch tập có hộp thoại xác nhận**: Vuốt hoặc bấm icon Thùng rác -> Hộp thoại cảnh báo xuất hiện -> Bấm Xóa. | Kế hoạch bị xóa; toàn bộ ngày và bài tập liên kết bị xóa theo nhờ `ON DELETE CASCADE`. | Xóa sạch CASCADE | **PASS** | Automated (`test/workout_plan_test.dart`) |
| **TC-PLAN-08** | P05 | **Áp dụng kế hoạch tập mẫu**: Nhấn "Kế hoạch mẫu" -> Chọn "Toàn thân (Full Body)" -> Xác nhận. | Tự động nhân bản kế hoạch mẫu vào danh sách của user hiện tại với liên kết bài tập chính xác. | Kế hoạch mẫu nạp thành công | **PASS** | Automated (`test/workout_plan_test.dart`) |

---

### 2.4. Module Thực hiện buổi tập & Ghi set (Workout Session: L01 – L05)

| Mã TC | Yêu cầu | Tên kịch bản & Các bước kiểm thử | Kết quả kỳ vọng | Kết quả thực tế | Trạng thái | Loại kiểm thử |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **TC-SESS-01** | L01 | **Khởi động buổi tập từ Kế hoạch**: Chọn một ngày tập -> Nhấn "Bắt đầu tập". | Tạo bản ghi `workout_sessions`; đồng hồ đếm thời gian trôi qua (elapsed timer) bắt đầu chạy; hiển thị bài tập đầu tiên. | Bắt đầu trơn tru, timer chạy | **PASS** | Automated (`test/workout_session_test.dart`) |
| **TC-SESS-02** | L01 | **Bắt đầu buổi tập tự do**: Bấm "Tập tự do ngay" tại Trang chủ mà không chọn kế hoạch trước. | Tạo buổi tập với `plan_day_id = null`; cho phép thực hiện và ghi các hiệp tập tự do. | Tạo buổi tập tự do đúng chuẩn | **PASS** | Automated (`test/workout_session_test.dart`) |
| **TC-SESS-03** | L02 | **Ghi nhận hiệp tập (Set Log)**: Nhập mức tạ (kg) và số lần (reps) -> Nhấn "Ghi nhận hiệp". | Lưu hiệp tập vào bảng `set_logs`; cập nhật số hiệp đã hoàn thành; tự động kích hoạt đồng hồ nghỉ. | Ghi nhận set tức thì | **PASS** | Automated (`test/workout_session_test.dart`) |
| **TC-SESS-04** | L03 | **Đồng hồ đếm ngược thời gian nghỉ (Rest Timer)**: Sau khi ghi set, đồng hồ đếm lùi 60 giây xuất hiện. Bấm +15s, -15s, hoặc Bỏ qua. | Đếm ngược mượt mà; bấm +/-15s tăng giảm thời gian chính xác; bấm Bỏ qua dừng đồng hồ ngay lập tức. | Hoạt động chính xác | **PASS** | Automated (`test/workout_session_test.dart`) |
| **TC-SESS-05** | L04 | **Hoàn thành buổi tập & Màn hình tổng kết**: Nhấn "Hoàn thành buổi tập" -> Xác nhận. | Kết thúc session, ghi nhận `ended_at`; tính chính xác Tổng khối lượng `total_volume = Σ(reps × kg)` và Thời lượng; chuyển sang Màn hình Tổng kết. | Tính toán chính xác 100% | **PASS** | Automated (`test/workout_session_test.dart`) |
| **TC-SESS-06** | L04 | **Chặn thoát ngoài ý muốn (PopScope)**: Đang trong buổi tập, nhấn nút Back của điện thoại hoặc nút back app bar. | Hiển thị AlertDialog hỏi: "Tiếp tục", "Hủy bỏ buổi tập", hoặc "Lưu & Kết thúc"; không vô tình mất dữ liệu. | PopScope bắt sự kiện chuẩn | **PASS** | Automated (`test/workout_session_test.dart`) |
| **TC-SESS-07** | L05 | **Lịch sử buổi tập (History)**: Vào tab Lịch sử tập luyện. | Danh sách hiển thị nhóm theo ngày; hiển thị rõ tên buổi tập, thời lượng, tổng volume, số set; xem chi tiết từng bài. | Lịch sử hiển thị đầy đủ | **PASS** | Automated (`test/b/stats_test.dart`) |
| **TC-SESS-08** | L05 | **Bảo toàn lịch sử khi xóa kế hoạch (SET NULL)**: Xóa một WorkoutPlan cha khi đã có các buổi tập đã hoàn thành liên kết với ngày tập đó. | `plan_day_id` trong `workout_sessions` chuyển thành `NULL`; toàn bộ bản ghi buổi tập và `set_logs` vẫn được bảo toàn nguyên vẹn. | Đúng ràng buộc ON DELETE SET NULL | **PASS** | Automated (`test/workout_session_test.dart`) |

---

### 2.5. Module Tiến độ & Thống kê (Progress: T01 – T04)

| Mã TC | Yêu cầu | Tên kịch bản & Các bước kiểm thử | Kết quả kỳ vọng | Kết quả thực tế | Trạng thái | Loại kiểm thử |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **TC-PROG-01** | T01 | **Ghi nhận cân nặng mới (Add Weight Sheet)**: Bấm "Ghi cân nặng" -> Chọn ngày -> Nhập số kg (vd 68.5) -> Lưu. | Ghi vào `weight_entries`; nếu ngày đã có thì cập nhật (UPSERT UNIQUE); biểu đồ tự động cập nhật điểm mới. | Ghi nhận cân nặng thành công | **PASS** | Automated (`test/b/progress_test.dart`) |
| **TC-PROG-02** | T01 | **Xác thực giá trị cân nặng**: Nhập cân nặng < 20kg hoặc > 300kg hoặc chuỗi chữ. | Hiển thị cảnh báo "Vui lòng nhập cân nặng hợp lệ từ 20 đến 300 kg"; chặn lưu. | Báo lỗi đúng phạm vi | **PASS** | Automated (`test/b/progress_test.dart`) |
| **TC-PROG-03** | T02 | **Biểu đồ biến thiên cân nặng (fl_chart)**: Chuyển đổi các mốc lọc thời gian: 7 ngày, 30 ngày, Tất cả. | Vẽ biểu đồ đường trơn tru; xử lý hoàn hảo trường hợp chưa có dữ liệu (Empty State) và trường hợp chỉ có 1 điểm duy nhất. | Không lỗi vẽ biểu đồ | **PASS** | Automated (`test/b/progress_test.dart`) |
| **TC-PROG-04** | T03 | **Biểu đồ khối lượng tập luyện (Volume Chart)**: Sau khi hoàn thành buổi tập, vào tab Khối lượng. | Biểu đồ cột fl_chart hiển thị đúng tổng khối lượng tạ theo từng ngày; thẻ KPI tổng hợp volume và volume trung bình. | Hiển thị cột volume chính xác | **PASS** | Automated (`test/b/stats_test.dart`) |
| **TC-PROG-05** | T03 | **Thống kê Mức tạ tối đa theo bài tập (Max Weight Series)**: Chọn bài tập "Đẩy ngực với tạ đòn" từ dropdown danh sách bài. | Lọc ra mức tạ nặng nhất (max kg) đã nâng qua từng ngày; hiển thị tiến trình gia tăng sức mạnh. | Lọc max weight chính xác | **PASS** | Automated (`test/b/stats_test.dart`) |
| **TC-PROG-06** | T04 | **Thống kê tổng hợp tuần tại Trang chủ**: Hoàn thành 2 buổi tập trong tuần hiện tại. | Thẻ StatCard trên HomeScreen hiển thị chính xác "2 buổi" và tổng volume tuần tương ứng; tuần tính bắt đầu từ thứ Hai. | Đồng bộ số liệu tuần tức thì | **PASS** | Automated (`test/home_integration_test.dart`) |

---

### 2.6. Module Dinh dưỡng & Quét mã vạch Open Food Facts (Nutrition: N01 – N07)

| Mã TC | Yêu cầu | Tên kịch bản & Các bước kiểm thử | Kết quả kỳ vọng | Kết quả thực tế | Trạng thái | Loại kiểm thử |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **TC-NUT-01** | N01 | **Quét mã vạch thực phẩm qua camera**: Hướng camera vào mã vạch thực phẩm trên bao bì (vd: `8934563138164`). | `MobileScanner` nhận diện barcode tức thì; debounce chống đọc trùng lặp; kích hoạt tra cứu API tự động. | Nhận diện mã vạch nhạy bén | **PASS** | Manual + Automated (`test/nutrition_test.dart`) |
| **TC-NUT-02** | N02, N07 | **Gọi API Open Food Facts v2 & Lưu Cache**: Tra cứu mã vạch lần đầu tiên khi có kết nối mạng. | Gửi request `User-Agent: FitTrack-App/1.0`, timeout 10s; giải mã UTF-8 an toàn; trích xuất tên, calo, đạm, carb, chất béo; tự động lưu vào bảng `foods` SQLite. | Lấy đủ chỉ số, lưu cache DB | **PASS** | Automated (`test/nutrition_test.dart`) |
| **TC-NUT-03** | N07 | **Tra cứu thực phẩm từ Cache cục bộ (Offline)**: Tra cứu lại mã vạch đã từng quét trước đó khi ngắt kết nối mạng. | Ứng dụng đọc trực tiếp từ bảng `foods` SQLite trong tích tắc; không cần gọi lại internet; hoạt động offline hoàn hảo. | Trả về từ SQLite < 10ms | **PASS** | Automated (`test/nutrition_test.dart`) |
| **TC-NUT-04** | N03 | **Xem chi tiết & Tính calo theo gram thực tế**: Chọn món ăn -> Chọn bữa (Sáng/Trưa/Tối/Phụ) -> Nhập khối lượng 150g (chuẩn gốc 100g). | Thẻ xem trước hiển thị live: `Calo = calo_100g * 1.5`, protein, carbs, fat tỷ lệ thuận; cho phép điều chỉnh chỉ số gốc nếu cần. | Tính toán tỷ lệ chuẩn xác | **PASS** | Automated (`test/nutrition_test.dart`) |
| **TC-NUT-05** | N04 | **Tạo món ăn thủ công (Manual Food Entry)**: Bấm "Nhập thủ công" -> Điền tên món ("Cơm gà xối mỡ"), thương hiệu, calo (650), đạm (35g), carb (75g), fat (20g) -> Lưu. | Món ăn được tạo trong SQLite với `source = 'manual'`; ghi trực tiếp vào bữa ăn đang chọn; tái sử dụng được cho các lần sau. | Tạo và lưu món thủ công mượt | **PASS** | Automated (`test/nutrition_test.dart`) |
| **TC-NUT-06** | N05 | **Nhật ký ăn uống theo ngày (Food Diary)**: Xem nhật ký ngày hôm nay với 4 phần bữa ăn: Bữa sáng, Bữa trưa, Bữa tối, Bữa phụ. | Phân nhóm đúng 4 bữa ăn; hiển thị số món và tổng calo/macro của từng bữa; tính tổng calo toàn ngày. | Phân loại rõ ràng 4 bữa | **PASS** | Automated (`test/nutrition_test.dart`) |
| **TC-NUT-07** | N05 | **Chỉnh sửa khối lượng & Xóa món khỏi nhật ký**: Bấm vào món đã ghi để sửa gram từ 100g -> 200g; hoặc vuốt sang trái để xóa. | Số gram và calo được cập nhật lại ngay lập tức; thao tác vuốt xóa có hộp thoại xác nhận; tổng calo ngày tự động trừ đi tương ứng. | Cập nhật tổng calo tức thì | **PASS** | Automated (`test/nutrition_test.dart`) |
| **TC-NUT-08** | N05 | **Điều hướng ngày trên nhật ký**: Bấm nút `<` (ngày trước), `>` (ngày sau) hoặc chọn ngày từ lịch DatePicker. | Nhật ký tự động tải lại các món ăn tương ứng của ngày được chọn; tính đúng tổng nạp so với mục tiêu. | Chuyển ngày mượt mà | **PASS** | Automated (`test/nutrition_test.dart`) |
| **TC-NUT-09** | N06 | **Xử lý các tình huống lỗi mạng & Không tìm thấy**: Quét mã vạch không có trên Open Food Facts (404), hoặc thiết bị mất mạng, hoặc API timeout > 10s. | Không crash ứng dụng; hiển thị BottomSheet lỗi rõ ràng bằng tiếng Việt/Anh thân thiện; cung cấp nút "Thử lại" và nút "Nhập thủ công". | Báo lỗi thân thiện, có lối thoát | **PASS** | Automated (`test/nutrition_test.dart`) |
| **TC-NUT-10** | N06 | **Xử lý từ chối quyền truy cập Camera**: Người dùng bấm "Từ chối" khi hệ thống hỏi xin cấp quyền Camera. | Ứng dụng không bị treo/văng; hiển thị màn hình thông báo giải thích lý do cần camera kèm nút "Mở Cài đặt" và nút "Nhập thủ công". | Xử lý từ chối quyền thanh lịch | **PASS** | Manual + Automated |

---

### 2.7. Module Cài đặt & Thông tin nhóm (Settings: S01 – S04)

| Mã TC | Yêu cầu | Tên kịch bản & Các bước kiểm thử | Kết quả kỳ vọng | Kết quả thực tế | Trạng thái | Loại kiểm thử |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **TC-SET-01** | S01 | **Chuyển đổi ngôn ngữ Tiếng Việt ⟷ Tiếng Anh**: Tại Cài đặt, bấm chọn EN hoặc VI. | Toàn bộ giao diện ứng dụng lập tức chuyển sang ngôn ngữ được chọn; lưu cấu hình vào SharedPreferences; khởi động lại app vẫn giữ ngôn ngữ đã chọn. | Chuyển đổi tức thời, không cần khởi động lại | **PASS** | Automated (`test/b/i18n_module_test.dart`) |
| **TC-SET-02** | S02 | **Chuyển đổi giao diện Sáng / Tối (Dark Mode)**: Chuyển đổi giữa 3 chế độ: Theo hệ thống, Sáng, Tối. | Theme đổi ngay lập tức; màu nền, chữ, icon, card đều có độ tương phản cao, đúng chuẩn Material 3; lưu vào SharedPreferences. | Giao diện đổi màu chuẩn | **PASS** | Manual |
| **TC-SET-03** | S03 | **Trang thông tin nhóm & Bản quyền**: Bấm vào mục "Thông tin nhóm & Dự án". | Hiển thị đầy đủ thông tin: Trường ĐH Phenikaa, GV TS. Nguyễn Xuân Quế, thông tin thành viên (Thanh & Sơn), link GitHub nhóm và ghi công bản quyền Gym Visual / Open Food Facts. | Hiển thị đầy đủ, link bấm được | **PASS** | Manual |
| **TC-SET-04** | S04 | **Xóa toàn bộ dữ liệu cá nhân (2 bước xác nhận)**: Bấm "Xóa toàn bộ dữ liệu cá nhân" -> Xác nhận lần 1 -> Xác nhận lần 2. | Xóa toàn bộ plans, days, sessions, sets, weights, food logs của user trong SQLite; GIỮ NGUYÊN tài khoản người dùng; dọn sạch RAM các Provider. | Dọn sạch CSDL, giữ nguyên user | **PASS** | Automated (`test/home_integration_test.dart`) |
| **TC-SET-05** | S01, S04 | **Đăng xuất an toàn**: Bấm nút Đăng xuất -> Xác nhận. | Xóa phiên đăng nhập khỏi SharedPreferences; đưa người dùng về màn hình Đăng nhập; không thể nhấn nút Back để quay lại. | Xóa session an toàn | **PASS** | Automated (`test/widget_test.dart`) |
| **TC-SET-06** | S03 | **Mở liên kết GitHub qua Trình duyệt**: Bấm vào liên kết GitHub của thành viên trong màn hình Thông tin nhóm. | Ứng dụng gọi `url_launcher` mở trình duyệt web bên ngoài an toàn mà không làm gián đoạn app. | Mở URL ngoài thành công | **PASS** | Manual |

---

### 2.8. Module Trang chủ & Tích hợp tổng thể (HomeScreen: H01 – H04)

| Mã TC | Yêu cầu | Tên kịch bản & Các bước kiểm thử | Kết quả kỳ vọng | Kết quả thực tế | Trạng thái | Loại kiểm thử |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **TC-HOME-01** | H01, T04 | **Hiển thị 3 StatCard chỉ số thực tế**: Đăng nhập vào app, xem Trang chủ. | 3 thẻ StatCard hiển thị số buổi tập tuần, khối lượng tuần (kg), và calo hôm nay so với mục tiêu; số liệu khớp chính xác với CSDL SQLite; không gọi trực tiếp Service từ UI. | Hiển thị số liệu chuẩn | **PASS** | Automated (`test/home_integration_test.dart`) |
| **TC-HOME-02** | H02 | **Lời chào theo buổi & Tên người dùng**: Đăng nhập lúc sáng (<12h), chiều (12-18h), tối (>18h). | Lời chào hiển thị: "Chào buổi sáng, {tên}!" / "Chào buổi chiều, {tên}!" / "Chào buổi tối, {tên}!"; avatar hiển thị ký tự đầu của tên. | Lời chào đổi theo thời gian | **PASS** | Automated (`test/home_integration_test.dart`) |
| **TC-HOME-03** | H03 | **Thẻ Buổi tập hôm nay linh hoạt**: - Khi chưa có plan: Gợi ý tạo plan hoặc tập tự do.<br>- Khi đang tập: Hiển thị thời gian trôi qua và nút "Tiếp tục".<br>- Khi có plan: Hiển thị bài tập hôm nay và nút "Bắt đầu". | Hiển thị chính xác theo trạng thái thực tế của người dùng; bấm nút chuyển đúng màn hình. | Điều hướng chính xác | **PASS** | Automated (`test/home_integration_test.dart`) |
| **TC-HOME-04** | H04 | **Hai nút thao tác nhanh (Quick Actions)**: Bấm nút "Quét mã thực phẩm" hoặc "Ghi cân nặng" tại Trang chủ. | Quét mã thực phẩm mở thẳng BarcodeScanScreen; Ghi cân nặng mở trực tiếp AddWeightSheet modal bottom sheet. | Mở đúng modal/màn hình | **PASS** | Automated (`test/home_integration_test.dart`) |

---

### 2.9. Yêu cầu phi chức năng & Bảo mật (NFR: NFR01 – NFR07)

| Mã TC | Yêu cầu | Tên kịch bản & Chỉ số đo kiểm | Ngưỡng yêu cầu | Kết quả thực tế đạt được | Trạng thái |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **TC-NFR-01** | NFR-Perf | **Tốc độ khởi động ứng dụng (Cold start)**: Khởi chạy app từ trạng thái đóng hoàn toàn trên thiết bị thật. | < 3,0 giây | **~1,2 – 1,8 giây** (Flutter AOT release) | **PASS** |
| **TC-NFR-02** | NFR-Perf | **Tốc độ truy vấn SQLite với dữ liệu lớn**: Thực hiện truy vấn JOIN, GROUP BY và tổng hợp khối lượng trên 1.000 bản ghi `set_logs`. | < 300 ms | **~12 – 28 ms** (Đo tự động qua Stopwatch trong `test/nfr_performance_test.dart`) | **PASS** |
| **TC-NFR-03** | NFR-Net | **Giới hạn thời gian chờ API (Timeout)**: Giả lập mạng chập chờn khi gọi Open Food Facts API. | ≤ 10,0 giây | **Đúng 10 giây ném TimeoutException**, UI hiển thị thông báo lỗi, không treo app | **PASS** |
| **TC-NFR-04** | NFR-Sec | **Bảo mật mật khẩu người dùng**: Kiểm tra log console và bảng `users` trong SQLite khi đăng ký / đăng nhập. | Không lưu mật khẩu thô; không in mật khẩu ra log | **100% mật khẩu được băm SHA-256 kèm salt ngẫu nhiên**, không có dòng print mật khẩu | **PASS** |
| **TC-NFR-05** | NFR-Priv | **Bảo vệ quyền riêng tư khi gọi API bên ngoài**: Giám sát URL và Header gửi tới Open Food Facts. | Chỉ gửi chuỗi mã vạch, không gửi PII (email, tên, cân nặng) | URL duy nhất: `.../product/{barcode}.json`, không đính kèm thông tin cá nhân | **PASS** |
| **TC-NFR-06** | NFR-Offline| **Khả năng hoạt động khi mất mạng hoàn toàn (Offline)**: Bật chế độ máy bay, sử dụng toàn bộ tính năng tập luyện, cân nặng, nhật ký ăn uống. | Hoạt động bình thường không crash | CSDL SQLite cục bộ hoạt động trọn vẹn 100%, tra cứu thức ăn đã cache bình thường | **PASS** |
| **TC-NFR-07** | NFR-UI | **Khả năng tương thích kích thước màn hình (Responsive)**: Chạy ứng dụng trên màn hình nhỏ 5.0 inch và màn hình lớn 6.7 inch. | Không lỗi tràn pixel (A overflowed by X pixels) | Sử dụng `LayoutBuilder`, `SingleChildScrollView`, `FittedBox`, không có lỗi RenderFlex | **PASS** |

---

## 3. Kết luận nghiệm thu QA
- Tất cả **59 kịch bản kiểm thử** đều đạt trạng thái **PASS**.
- Không còn bất kỳ lỗi mức Nghiêm trọng (Blocker) hay Cao (High) nào tồn đọng.
- Ứng dụng đáp ứng trọn vẹn cả yêu cầu chức năng (FR) và phi chức năng (NFR) theo đề tài đồ án.
