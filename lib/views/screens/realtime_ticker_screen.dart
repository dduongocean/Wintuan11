import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../models/ticker_item.dart';
import '../../services/ticker_service.dart';
import '../../utils/stream_transformers.dart';

/// MÀN HÌNH BẢNG GIÁ THỜI GIAN THỰC (REAL-TIME REACTIVE MARKET SCREEN)
/// 
/// Thể hiện đầy đủ các yêu cầu cốt lõi của Chủ đề 02:
/// 1. Tải dữ liệu ban đầu bằng Future.
/// 2. Lắng nghe và hiển thị biến động giá thời gian thực bằng StreamBuilder.
/// 3. Thanh tìm kiếm áp dụng toán tử Debounce (Stream Transformer) thuần Dart.
/// 4. Hủy luồng an toàn (Cancellation & Dispose) khi thoát màn hình.
class RealtimeTickerScreen extends StatefulWidget {
  const RealtimeTickerScreen({super.key});

  @override
  State<RealtimeTickerScreen> createState() => _RealtimeTickerScreenState();
}

class _RealtimeTickerScreenState extends State<RealtimeTickerScreen> {
  // Khởi tạo đối tượng Service quản lý dữ liệu và luồng phát giá
  final TickerService _tickerService = TickerService();

  // Controller điều khiển text trong ô nhập liệu tìm kiếm
  final TextEditingController _searchCtrl = TextEditingController();
  
  // StreamController cục bộ quản lý chuỗi ký tự người dùng gõ vào
  final StreamController<String> _searchController = StreamController<String>();

  // Subscription dùng để quản lý việc lắng nghe luồng tìm kiếm (để hủy khi dispose)
  StreamSubscription<String>? _searchSubscription;

  String _filterKeyword = ''; // Từ khóa tìm kiếm hiện tại
  bool _isInitLoading = true; // Trạng thái đang tải dữ liệu ban đầu từ Future
  List<TickerItem> _initialItems = const []; // Dữ liệu nạp từ Future ban đầu

  @override
  void initState() {
    super.initState();
    // 1. Nạp danh mục khởi đầu qua Future
    _setupInitialData();
    // 2. Thiết lập cơ chế lọc tìm kiếm qua Stream có Debounce
    _bindSearchStream();
  }

  /// Thiết lập lắng nghe Stream tìm kiếm kết hợp toán tử Debounce 400ms:
  /// Giúp giao diện chỉ lọc danh sách khi người dùng đã dừng gõ phím ít nhất 400ms
  void _bindSearchStream() {
    _searchSubscription = _searchController.stream
        .transform(Debounce(const Duration(milliseconds: 400)))
        .listen((keyword) {
      if (mounted) {
        setState(() {
          _filterKeyword = keyword.trim().toLowerCase();
        });
      }
    });
  }

  /// Nạp dữ liệu ban đầu bằng Future:
  /// Nhận danh sách ban đầu, bàn giao cho UI và kích hoạt Stream định kỳ
  Future<void> _setupInitialData() async {
    final initialData = await _tickerService.initializeData();
    if (mounted) {
      setState(() {
        _initialItems = initialData;
        _isInitLoading = false;
      });
      // Kích hoạt phát giá định kỳ qua StreamController
      _tickerService.start();
    }
  }

  /// HỦY LUỒNG VÀ GIẢI PHÓNG BỘ NHỚ KHI THOÁT MÀN HÌNH:
  /// Đảm bảo dọn dẹp các StreamController và Timer để tránh rò rỉ bộ nhớ (Memory Leak)
  @override
  void dispose() {
    // Hủy đăng ký lắng nghe sự kiện tìm kiếm
    _searchSubscription?.cancel();
    // Đóng StreamController của ô tìm kiếm
    _searchController.close();
    // Giải phóng bộ nhớ của TextEditingController
    _searchCtrl.dispose();
    // Dừng Timer và đóng StreamController phát giá trong Service
    _tickerService.dispose();

    developer.log('Đã hủy StreamSubscription và đóng Controller an toàn khi rời màn hình.', name: 'ScreenDispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Reactive Market'),
        actions: [
          // Nút bấm cho phép người dùng chủ động Tạm dừng hoặc Tiếp tục luồng phát giá
          IconButton(
            tooltip: _tickerService.isActive ? 'Tạm dừng luồng' : 'Tiếp tục luồng',
            icon: Icon(
              _tickerService.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                final isRunning = _tickerService.isActive;
                isRunning ? _tickerService.pause() : _tickerService.start();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isRunning ? 'Đã tạm ngưng luồng Stream.' : 'Đã kích hoạt lại luồng Stream.'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              });
            },
          ),
        ],
      ),
      // Nếu Future ban đầu chưa xong -> Hiển thị vòng xoay tiến trình Loading
      body: _isInitLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang nạp dữ liệu ban đầu qua Future...'),
                ],
              ),
            )
          : Column(
              children: [
                // KHUNG TÌM KIẾM ÁP DỤNG STREAM DEBOUNCE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchCtrl,
                    // Mỗi khi gõ 1 ký tự, đẩy ký tự đó vào Sink của _searchController
                    onChanged: (val) => _searchController.add(val),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Tìm kiếm mã (Debounce 400ms)...',
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                _searchController.add('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

                // WIDGET STREAMBUILDER: TỰ ĐỘNG LẮNG NGHE VÀ VẼ LẠI KHI CÓ DỮ LIỆU STREAM MỚI
                Expanded(
                  child: StreamBuilder<List<TickerItem>>(
                    stream: _tickerService.stream, // Lắng nghe luồng phát từ Service
                    initialData: _initialItems, // Dữ liệu nạp từ Future ban đầu
                    builder: (context, snapshot) {
                      // 1. Kiểm tra trạng thái đang kết nối ban đầu
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // 2. Trường hợp luồng gặp lỗi
                      if (snapshot.hasError) {
                        return Center(child: Text('Lỗi: ${snapshot.error}'));
                      }
                      // 3. Trường hợp chưa có dữ liệu
                      if (!snapshot.hasData) {
                        return const Center(child: Text('Đang đợi luồng dữ liệu...'));
                      }

                      // 4. Có dữ liệu mới: Thực hiện lọc theo từ khóa debounce
                      final items = snapshot.data!;
                      final filtered = items.where((item) {
                        return item.name.toLowerCase().contains(_filterKeyword) ||
                            item.symbol.toLowerCase().contains(_filterKeyword);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(child: Text('Không có mã nào khớp với từ khóa.'));
                      }

                      // 5. Hiển thị danh sách các mã tiền số (tối ưu hóa bằng ListTile)
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final coin = filtered[index];
                          final isUp = coin.isGaining;
                          final color = isUp ? Colors.green : Colors.red;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.15),
                                child: Text(
                                  coin.symbol,
                                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              title: Text(coin.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(coin.symbol, style: const TextStyle(color: Colors.grey)),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${coin.currentPrice.toStringAsFixed(2)}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: color, size: 18),
                                      Text(
                                        '${coin.changeRate >= 0 ? '+' : ''}${coin.changeRate.toStringAsFixed(2)}%',
                                        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
