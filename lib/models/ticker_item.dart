/// Model đại diện cho một đồng tiền số hoặc cổ phiếu trong hệ thống theo dõi giá.
/// Sử dụng các trường dữ liệu 'final' để đảm bảo tính bất biến (Immutability).
class TickerItem {
  final String symbol; // Ký hiệu viết tắt (ví dụ: 'BTC', 'ETH')
  final String name; // Tên đầy đủ (ví dụ: 'Bitcoin', 'Ethereum')
  final double currentPrice; // Giá thị trường ở thời điểm hiện tại
  final double previousPrice; // Giá ở nhịp cập nhật liền trước
  final double changeRate; // Tỉ lệ % biến động giá

  const TickerItem({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.previousPrice,
    required this.changeRate,
  });

  /// Getter xác định xu hướng giá:
  /// Trả về true (giá tăng hoặc giữ nguyên -> hiển thị màu xanh)
  /// Trả về false (giá giảm -> hiển thị màu đỏ)
  bool get isGaining => currentPrice >= previousPrice;

  /// Phương thức cập nhật giá mới:
  /// Thay vì chỉnh sửa trực tiếp giá trị của đối tượng cũ, phương thức này
  /// tính toán tỉ lệ % chênh lệch và tạo ra một đối tượng TickerItem mới hoàn toàn.
  /// Đây là nguyên tắc chuẩn trong lập trình phản ứng (Reactive Programming).
  TickerItem updatePrice(double newPrice) {
    final diff = newPrice - currentPrice;
    final rate = currentPrice == 0 ? 0.0 : (diff / currentPrice) * 100;
    return TickerItem(
      symbol: symbol,
      name: name,
      currentPrice: newPrice,
      previousPrice: currentPrice,
      changeRate: rate,
    );
  }
}
