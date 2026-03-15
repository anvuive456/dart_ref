/// Context nội bộ dùng bởi [ComputedRef] để tự động phát hiện dependency.
///
/// Khi [ComputedRef] chạy hàm compute, nó set [onAccess] để nhận thông báo
/// mỗi khi một [BaseRef] nào đó được đọc state, từ đó xác định dependency.
class RefTrackingContext {
  RefTrackingContext._();

  /// Callback được gọi khi một BaseRef có state được đọc trong quá trình tracking.
  /// Null khi không có ComputedRef nào đang chạy.
  static void Function(Object dep)? onAccess;
}
