# FitTrack — Ứng dụng theo dõi Tập gym & Dinh dưỡng

Ứng dụng di động theo dõi tập luyện thể hình (gym) và nhật ký dinh dưỡng hàng ngày, hoạt động **offline là chính** với CSDL SQLite cục bộ (`sqflite`), quản lý trạng thái bằng `provider`. Dự án môn Lập trình thiết bị di động — Đại học Phenikaa (GV: TS. Nguyễn Xuân Quế).

---

## 👥 Bảng phân công thành viên

| Vai trò | Thành viên | Tài khoản GitHub | Email Git | Nhiệm vụ chính (~% đóng góp) |
| :--- | :--- | :--- | :--- | :--- |
| **Máy A (Chủ repo)** | Nguyễn Đức Thanh | [@ducthanh8386](https://github.com/ducthanh8386) | `thanhygqv9@gmail.com` | Kiến trúc 4 tầng, SQLite, Auth & MainShell, Kế hoạch tập, Buổi tập, Dinh dưỡng (OFF API), Tích hợp & QA (~70%) |
| **Máy B** | Lê Văn Sơn | [@zackcutee] | `lson44554@gmail.com` | Dữ liệu & Thư viện bài tập, Tiến độ cân nặng (fl_chart), Hồ sơ & Cài đặt, Thông tin nhóm, Lịch sử buổi tập (~30%) |

---

## 🚀 Công nghệ & Kiến trúc

- **Framework:** Flutter (Dart)
- **Kiến trúc:** 4 tầng phân tách độc lập (Presentation $\rightarrow$ State/Provider $\rightarrow$ Service/Domain $\rightarrow$ Data/Repository)
- **CSDL:** SQLite cục bộ (`sqflite`) với 10 bảng quan hệ, `PRAGMA foreign_keys = ON`, không dùng Firebase/Firestore
- **State Management:** `provider` (`ChangeNotifier`, `ProxyProvider`)
- **Quản lý cài đặt:** `shared_preferences`
- **Quét mã vạch:** `mobile_scanner`
- **Biểu đồ:** `fl_chart`
- **Đa ngôn ngữ:** `flutter_localizations` + `intl` (.arb file cho Tiếng Việt và Tiếng Anh)
- **Dinh dưỡng:** Tra cứu Open Food Facts API (timeout 10s, cache local SQLite)

---

## 🛠️ Hướng dẫn cài đặt & Chạy ứng dụng

### Yêu cầu môi trường
- Flutter SDK (phiên bản ổn định $\ge$ 3.0.0)
- Android Studio / VS Code
- Thiết bị Android hoặc giả lập Android (API 24+)

### Các bước chạy
```bash
# 1. Clone repository
git clone https://github.com/ducthanh8386/fit-track.git
cd fit-track

# 2. Cài đặt dependencies
flutter pub get

# 3. Sinh mã đa ngôn ngữ (Localization)
flutter gen-l10n

# 4. Kiểm tra mã nguồn & unit test
flutter analyze
flutter test

# 5. Khởi chạy ứng dụng
flutter run
```

---

## 🔗 Repository & Hợp đồng phát triển

- **GitHub Repository:** [https://github.com/ducthanh8386/fit-track](https://github.com/ducthanh8386/fit-track)
- **Ma trận kiểm thử toàn diện (QA Matrix):** `docs/test_matrix.md` (59 kịch bản test 100% PASS)
- **Hợp đồng giao tiếp (Contract A $\leftrightarrow$ B):** `docs/contracts/contract.md`
- **Quyền sở hữu file:** `docs/contracts/ownership.txt`
- **Quy trình Git 2 máy:** `docs/git_workflow.md`

---

## 📜 Ghi công dữ liệu (Attributions)

- **Exercise data and media:** [hasaneyldrm/exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset) (MIT License cho dữ liệu); media © Gym visual — [https://gymvisual.com/](https://gymvisual.com/)
- **Food database:** [Open Food Facts](https://world.openfoodfacts.org/) (Open Database License - ODbL)
