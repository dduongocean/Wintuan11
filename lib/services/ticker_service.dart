import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import '../models/ticker_item.dart';

/// DỊCH VỤ QUẢN LÝ DÒNG DỮ LIỆU THỜI GIAN THỰC (REACTIVE TICKER SERVICE)
/// 
/// Đây là phần trọng tâm nghiệp vụ của Chủ đề 02, kết hợp cả hai mô hình:
/// 1. Future: Tải dữ liệu ban đầu từ nguồn (Single asynchronous value).
/// 2. Stream: Phát liên tục dòng dữ liệu biến động giá theo thời gian (Continuous events).
class TickerService {
  final Random _random = Random();
  Timer? _generatorTimer; // Bộ đếm thời gian phát sinh dữ liệu định kỳ

  // Danh mục dữ liệu gốc mô phỏng lưu trong bộ nhớ RAM
  final List<TickerItem> _items = [
    const TickerItem(symbol: 'BTC', name: 'Bitcoin', currentPrice: 67200.0, previousPrice: 67200.0, changeRate: 0.0),
    const TickerItem(symbol: 'ETH', name: 'Ethereum', currentPrice: 3450.0, previousPrice: 3450.0, changeRate: 0.0),
    const TickerItem(symbol: 'SOL', name: 'Solana', currentPrice: 152.0, previousPrice: 152.0, changeRate: 0.0),
    const TickerItem(symbol: 'ADA', name: 'Cardano', currentPrice: 0.48, previousPrice: 0.48, changeRate: 0.0),
    const TickerItem(symbol: 'DOT', name: 'Polkadot', currentPrice: 7.20, previousPrice: 7.20, changeRate: 0.0),
  ];

  // Khởi tạo StreamController dạng Broadcast ngay từ đầu:
  // Đảm bảo Stream luôn sẵn sàng nhận sự kiện mà không bị null ở nhịp phát đầu tiên.
  final StreamController<List<TickerItem>> _controller = 
      StreamController<List<TickerItem>>.broadcast();

  bool _isActive = false;
  bool get isActive => _isActive; // Trạng thái luồng đang chạy hay đang tạm dừng

  /// Cung cấp Stream công khai để các Widget UI đăng ký lắng nghe (Subscribe)
  Stream<List<TickerItem>> get stream => _controller.stream;

  /// 1. MINH HỌA FUTURE:
  /// Giả lập một tác vụ mạng bất đồng bộ nạp danh sách coin ban đầu với độ trễ 1 giây (1000ms).
  Future<List<TickerItem>> initializeData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return List.unmodifiable(_items);
  }

  /// 2. MINH HỌA STREAM REAL-TIME:
  /// Bắt đầu kích hoạt dòng dữ liệu định kỳ bằng Timer.periodic mỗi 1.2 giây (1200ms).
  void start() {
    if (_isActive) return;
    _isActive = true;

    // Phát giá trị hiện tại ngay lập tức vào Stream Sink khi vừa bấm bắt đầu
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_items));
    }

    _generatorTimer?.cancel();
    _generatorTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (_controller.isClosed) return;

      // Sinh biến động giá ngẫu nhiên trong biên độ (-1.5% đến +1.5%)
      for (int i = 0; i < _items.length; i++) {
        final current = _items[i];
        final deltaRate = (_random.nextDouble() * 0.03) - 0.015;
        final nextPrice = double.parse((current.currentPrice * (1 + deltaRate)).toStringAsFixed(2));
        _items[i] = current.updatePrice(nextPrice);
      }

      // Đẩy danh sách đã cập nhật giá vào Sink của Stream
      _controller.add(List.unmodifiable(_items));
    });
  }

  /// Tạm ngưng phát dữ liệu (hủy Timer định kỳ)
  void pause() {
    _generatorTimer?.cancel();
    _generatorTimer = null;
    _isActive = false;
  }

  /// 3. HỦY LUỒNG VÀ GIẢI PHÓNG BỘ NHỚ:
  /// Đóng StreamController và dừng Timer để tránh rò rỉ bộ nhớ (Memory Leak).
  void dispose() {
    pause();
    _controller.close();
    developer.log('StreamController đã đóng thành công, giải phóng tài nguyên.', name: 'TickerService');
  }
}
