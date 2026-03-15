import 'package:ref/src/base/base_ref.dart';
import 'package:ref/src/base/tracking_context.dart';

/// Một ref tự động tính toán giá trị từ các ref khác (dependency).
///
/// [ComputedRef] theo dõi tất cả các ref được truy cập trong hàm [compute].
/// Khi bất kỳ dependency nào thay đổi, [ComputedRef] sẽ tự động tính lại giá trị.
///
/// Không cần khai báo dependency thủ công — chúng được phát hiện tự động
/// thông qua [RefTrackingContext] khi hàm compute chạy.
///
/// Ví dụ:
/// ```dart
/// final firstName = ref('John');
/// final lastName = ref('Doe');
///
/// // Tự động phát hiện dependency vào firstName và lastName
/// final fullName = computedRef(() => '${firstName.state} ${lastName.state}');
///
/// firstName.state = 'Jane';
/// print(fullName.state); // 'Jane Doe'
/// ```
///
/// Hỗ trợ conditional dependency — nếu hàm compute có nhánh điều kiện,
/// chỉ những ref thực sự được truy cập mới được đăng ký:
/// ```dart
/// final showAge = ref(true);
/// final age = ref(25);
/// final name = ref('Alice');
///
/// final label = computedRef(() {
///   if (showAge.state) return '${name.state}, age ${age.state}';
///   return name.state;
/// });
/// ```
class ComputedRef<T> extends BaseRef<T> {
  final T Function() _compute;

  /// Lưu các dependency và scopeId tương ứng để removeListener khi cần
  final Map<BaseRef, String> _deps = {};

  /// Guard tránh recompute đệ quy khi addListener gọi callback ngay lập tức
  bool _isTracking = false;

  ComputedRef(this._compute) : super(_compute()) {
    _track();
  }

  /// Chạy hàm compute với tracking bật để phát hiện và đăng ký dependencies.
  void _track() {
    _isTracking = true;

    // Xóa các dependency cũ
    for (final entry in _deps.entries) {
      entry.key.removeListener(entry.value);
    }
    _deps.clear();

    // Bật tracking và chạy compute
    final previous = RefTrackingContext.onAccess;
    RefTrackingContext.onAccess = _onDepAccessed;
    _compute(); // kết quả bỏ qua — chỉ dùng để phát hiện deps
    RefTrackingContext.onAccess = previous;

    _isTracking = false;
  }

  /// Được gọi khi một BaseRef có state được đọc trong quá trình tracking.
  void _onDepAccessed(Object dep) {
    if (dep is! BaseRef || _deps.containsKey(dep)) return;
    final scopeId = Object().hashCode.toString();
    _deps[dep] = scopeId;
    dep.addListener(
      // _isTracking guard ngăn callback ngay lập tức (do addListener notify ngay)
      (_) { if (!_isTracking) _recompute(); },
      name: scopeId,
    );
  }

  /// Tính lại giá trị và cập nhật dependency khi có dep thay đổi.
  void _recompute() {
    _isTracking = true;

    // Xóa dependency cũ
    for (final entry in _deps.entries) {
      entry.key.removeListener(entry.value);
    }
    _deps.clear();

    // Re-track với hàm compute (xử lý conditional dependency)
    final previous = RefTrackingContext.onAccess;
    RefTrackingContext.onAccess = _onDepAccessed;
    final result = _compute();
    RefTrackingContext.onAccess = previous;

    _isTracking = false;

    // Cập nhật state sau khi đã xong tracking (tránh recursive)
    super.state = result;
  }

  @override
  void dispose() {
    for (final entry in _deps.entries) {
      entry.key.removeListener(entry.value);
    }
    _deps.clear();
    super.dispose();
  }
}

/// Tạo một [ComputedRef] từ hàm compute.
///
/// Hàm [compute] sẽ được chạy ngay lập tức và mỗi khi có dependency thay đổi.
/// Các dependency được phát hiện tự động — bất kỳ ref nào có `.state` được
/// đọc bên trong hàm compute đều trở thành dependency.
///
/// Ví dụ:
/// ```dart
/// final count = ref(0);
/// final doubled = computedRef(() => count.state * 2);
///
/// count.state = 5;
/// print(doubled.state); // 10
/// ```
ComputedRef<T> computedRef<T>(T Function() compute) => ComputedRef<T>(compute);
