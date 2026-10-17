import 'package:flutter/material.dart';
import 'views/screens/realtime_ticker_screen.dart';

/// 1. Điểm khởi đầu (Entry Point) của toàn bộ ứng dụng Flutter.
/// Bất kỳ ứng dụng Flutter nào cũng bắt đầu thực thi từ hàm main().
void main() {
  // Đảm bảo các dịch vụ lõi của Flutter Engine (như kết nối kênh giao tiếp, render) 
  // đã sẵn sàng trước khi nạp giao diện.
  WidgetsFlutterBinding.ensureInitialized();

  // runApp() nhận vào một Widget gốc và gắn nó vào Widget Tree của ứng dụng.
  runApp(const MyApp());
}

/// 2. Widget Gốc (Root Widget) của toàn bộ ứng dụng.
/// Sử dụng StatelessWidget vì trạng thái cấu hình của ứng dụng (theme, title)
/// không cần thay đổi nội tại trong suốt vòng đời của widget này.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp bọc toàn bộ hệ thống định vị (navigator), theme, và phong cách Material Design.
    return MaterialApp(
      // Tiêu đề ứng dụng (hiển thị trên tab trình duyệt hoặc task manager)
      title: 'Chuyên đề 02 - Future & Stream Realtime',

      // Tắt dải banner "DEBUG" màu đỏ ở góc trên màn hình khi chạy thử nghiệm
      debugShowCheckedModeBanner: false,

      // Cấu hình giao diện tổng thể (Theme) với Material 3
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Màn hình chính chạy trực tiếp Module 1: Bảng giá thị trường thời gian thực
      home: const RealtimeTickerScreen(),
    );
  }
}
