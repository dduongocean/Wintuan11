# BÁO CÁO CHUYÊN ĐỀ DART & FLUTTER
## CHỦ ĐỀ 02: LẬP TRÌNH BẤT ĐỒNG BỘ VỚI FUTURE & STREAM - XÂY DỰNG MODULE REACTIVE THỜI GIAN THỰC

> **Giảng viên hướng dẫn:** TS. Nguyễn Duy Nhật Viễn  
> **Khoa:** Điện tử - Viễn thông, Trường Đại học Bách Khoa - Đại học Đà Nẵng  

---

### 1. Phân công nhiệm vụ nhóm (WBS - 2 Thành viên)
| Thành viên | Vai trò | Nhiệm vụ đảm nhiệm |
|---|---|---|
| **Thành viên 1** | Backend Logic & Architecture | Xây dựng Service `TickerService`, quản lý `StreamController.broadcast()`, viết toán tử `Debounce` bằng `StreamTransformerBase`, giải thích cơ chế Event Loop. |
| **Thành viên 2** | UI Design & Presentation | Xây dựng giao diện `StreamBuilder`, xử lý vòng đời `dispose()` / hủy luồng Stream, tối ưu UX tìm kiếm, soạn Slide báo cáo. |

---

### 2. Cấu trúc Source Code (Tinh gọn, trực tiếp)
```text
lib/
├── models/
│   └── ticker_item.dart              # Model dữ liệu giá tài sản, tỉ lệ biến động
├── utils/
│   └── stream_transformers.dart      # Toán tử Debounce thuần Dart
├── services/
│   └── ticker_service.dart           # Xử lý Future (tải ban đầu) và StreamController (Realtime ticker)
├── views/
│   └── screens/
│       └── realtime_ticker_screen.dart # Màn hình theo dõi biến động giá & ô tìm kiếm Debounce
└── main.dart                         # Entry point khởi chạy ứng dụng
```

---

### 3. Các điểm kỹ thuật cốt lõi giải trình khi Báo cáo

#### A. Khác biệt giữa `Future` và `Stream`
- **Future:** Đại diện cho một giá trị bất đồng bộ đơn lẻ (Single async value) sẽ hoàn thành ở tương lai (Ví dụ: hàm `initializeData()` nạp danh mục coin khởi đầu).
- **Stream:** Đại diện cho một chuỗi dữ liệu bất đồng bộ liên tục theo thời gian (Continuous asynchronous events), hoạt động theo mô hình Reactive (Dữ liệu giá tự động đẩy đến giao diện).

#### B. Cơ chế `StreamController.broadcast()`
- Mặc định Stream là Single-subscription (chỉ 1 listener). Sử dụng `.broadcast()` cho phép nhiều Widget cùng đăng ký lắng nghe (Subscribe) song song mà không làm gián đoạn luồng dữ liệu.

#### C. Toán tử `Debounce` (Stream Transformer)
- Tự triển khai bằng `StreamTransformerBase` và `Timer` thuần Dart, giúp ứng dụng chỉ lọc dữ liệu tìm kiếm sau khi người dùng ngừng gõ phím 400ms, tiết kiệm CPU và tài nguyên xử lý.

#### D. Tránh rò rỉ bộ nhớ (Memory Leak)
- Trong phương thức `dispose()` của State, bắt buộc gọi:
  ```dart
  _searchSubscription?.cancel();
  _searchController.close();
  _searchCtrl.dispose();
  _tickerService.dispose();
  ```
  giúp hủy hoàn toàn Timer và giải phóng Controller khỏi bộ nhớ RAM khi người dùng thoát màn hình hoặc tạm dừng luồng.

#### E. Cơ chế Event Loop & Microtask Queue (Giải thích trên Slide)
- **Thứ tự thực thi của Dart Runtime:**
  1. Toàn bộ mã **Synchronous** trên Call Stack.
  2. Toàn bộ tác vụ trong **Microtask Queue** (`scheduleMicrotask`, `Future.microtask`).
  3. Từng sự kiện trong **Event Queue** (`Future()`, I/O, `Timer`).

---

### 4. Hướng dẫn chạy ứng dụng
```bash
flutter pub get
flutter run
```
