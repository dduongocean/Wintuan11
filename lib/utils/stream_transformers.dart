import 'dart:async';

/// TOÁN TỬ BIẾN ĐỔI STREAM (STREAM TRANSFORMER) - KỸ THUẬT DEBOUNCE
/// 
/// Mục đích: Tránh tình trạng lọc/tìm kiếm liên tục mỗi khi người dùng gõ từng phím.
/// Nguyên lý: Mỗi khi có một sự kiện mới phát sinh, hệ thống sẽ hoãn lại việc xử lý
/// trong một khoảng thời gian [duration]. Nếu trước khi hết thời gian đó mà có sự kiện
/// mới tiếp tục tới, sự kiện cũ sẽ bị hủy bỏ và bộ đếm thời gian được đặt lại từ đầu.
class Debounce<T> extends StreamTransformerBase<T, T> {
  final Duration duration; // Khoảng thời gian chờ (ví dụ: 400ms)

  Debounce(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    // Biến đổi dòng sự kiện gốc thông qua _DebounceSink
    return Stream<T>.eventTransformed(
      stream,
      (EventSink<T> sink) => _DebounceSink<T>(sink, duration),
    );
  }
}

/// Lớp Sink nội bộ quản lý việc trì hoãn sự kiện bằng Timer
class _DebounceSink<T> implements EventSink<T> {
  final EventSink<T> _targetSink; // Cổng phát dữ liệu ra ngoài cho Widget nhận
  final Duration _duration; // Thời gian chờ
  Timer? _activeTimer; // Bộ đếm thời gian đang hoạt động

  _DebounceSink(this._targetSink, this._duration);

  @override
  void add(T data) {
    // 1. Khi người dùng gõ phím mới, Timer của ký tự trước lập tức bị hủy bỏ
    _activeTimer?.cancel();

    // 2. Khởi tạo một Timer mới đếm ngược
    _activeTimer = Timer(_duration, () {
      // Chỉ khi người dùng dừng tay đủ khoảng thời gian _duration,
      // dữ liệu mới chính thức được đẩy ra ngoài qua sink
      _targetSink.add(data);
    });
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // Chuyển tiếp lỗi nếu có phát sinh trong luồng
    _targetSink.addError(error, stackTrace);
  }

  @override
  void close() {
    // Dọn dẹp Timer và đóng sink an toàn khi luồng kết thúc
    _activeTimer?.cancel();
    _targetSink.close();
  }
}
