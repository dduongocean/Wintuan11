// Widget Test cho màn hình RealtimeTickerScreen

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('RealtimeTickerScreen loads initial Future data and streams updates', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Ban đầu hiển thị trạng thái đang nạp dữ liệu qua Future
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Đang nạp dữ liệu ban đầu qua Future...'), findsOneWidget);

    // Chờ Future initializeData (1000ms) hoàn tất
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump();
    // Chờ Stream phát nhịp đầu tiên (1200ms)
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('Ethereum'), findsOneWidget);

    // Kiểm tra giải phóng tài nguyên (dispose) không để sót Timer chạy ngầm
    await tester.pumpWidget(const SizedBox());
  });
}
