import 'package:flutter/foundation.dart';
import 'package:ref/ref.dart';
import 'package:ref/src/listener_manager/listener_manager.dart';
import 'package:ref/src/observer/global_observer_manager.dart';
import 'package:ref/src/observer/ref_observer_mixin.dart';

/// Lớp cơ sở cho tất cả các loại ref
///
/// [BaseRef] cung cấp các chức năng cơ bản để quản lý state:
/// - Lưu trữ và cập nhật state
/// - Thông báo cho các listener khi state thay đổi
/// - Hỗ trợ observer để theo dõi các thay đổi state
/// - Tự động dispose khi không còn listener nào
///
/// Ví dụ:
/// ```dart
/// final counter = Ref(0);
/// counter.addListener((state) {
///   print('Counter: $state');
/// });
/// counter.state = 1; // In ra: Counter: 1
/// ```
abstract class BaseRef<T> with RefObserverMixin {
  /// Quản lý các listener
  final _listenerManager = ListenerManager<T>();

  /// ID duy nhất cho ref này, được sử dụng khi đăng ký listener
  final _scopeId = Object().hashCode.toString();

  /// State hiện tại
  T _state;

  /// Khởi tạo ref với state ban đầu
  BaseRef(this._state);

  /// Tạo một ReadonlyRef từ Ref hiện tại với một selector
  ///
  /// Selector sẽ chọn một phần của state để lắng nghe, giúp tối ưu hiệu suất
  /// bằng cách chỉ cập nhật UI khi phần state được chọn thay đổi.
  ///
  /// Ví dụ:
  /// ```dart
  /// final userRef = ref({'name': 'John', 'age': 30});
  /// final nameRef = userRef.select((user) => user['name']);
  /// ```
  ReadonlyRef<R, T> select<R>(ReadonlyRefSelector<R, T> selector) =>
      ReadonlyRef<R, T>(this, selector);

  /// Kiểm tra xem có nên cập nhật state hay không
  ///
  /// Mặc định sẽ so sánh bằng toán tử !=
  /// Có thể override phương thức này để tùy chỉnh logic so sánh
  ///
  /// Ví dụ:
  /// ```dart
  /// @override
  /// bool shouldUpdate(User oldState, User newState) {
  ///   return oldState.id != newState.id || oldState.name != newState.name;
  /// }
  /// ```
  @protected
  bool shouldUpdate(T oldState, T newState) => oldState != newState;

  /// Lấy state hiện tại
  T get state => _state;

  /// Cập nhật state và thông báo cho các listener
  ///
  /// Chỉ thông báo khi state thực sự thay đổi (dựa trên [shouldUpdate])
  set state(T newState) {
    if (!shouldUpdate(_state, newState)) return;
    final oldState = _state;
    _state = newState;
    didNotifyStateChanged(runtimeType, oldState, newState);
    GlobalObserverManager().notifyStateChanged(runtimeType, oldState, newState);
    notify();
  }

  /// Thông báo cho tất cả các listener về state hiện tại
  void notify() {
    _listenerManager.notifyAll(state);
  }

  /// Đăng ký một listener để lắng nghe sự thay đổi state
  ///
  /// [func] là callback sẽ được gọi khi state thay đổi
  /// [name] là tên duy nhất cho listener, nếu null sẽ sử dụng scopeId
  ///
  /// Listener sẽ được gọi ngay lập tức với state hiện tại
  void addListener(
    ListenerFunc<T> func, {
    String? name,
  }) {
    _listenerManager.addListener(name ?? _scopeId, func);
    // Thông báo cho listener lần đầu tiên
    _listenerManager.notify(name ?? _scopeId, state);
    didAddListener(runtimeType, name ?? _scopeId);
  }

  /// Hủy đăng ký một listener
  ///
  /// [name] là tên của listener, nếu null sẽ sử dụng scopeId
  ///
  /// Tự động gọi [dispose] khi không còn listener nào
  void removeListener(String? name) {
    _listenerManager.removeListener(name ?? _scopeId);
    didRemoveListener(runtimeType, name ?? _scopeId);
    if (_listenerManager.isEmpty()) {
      dispose();
    }
  }

  /// Giải phóng tài nguyên khi ref không còn được sử dụng
  ///
  /// Được gọi tự động khi không còn listener nào
  /// Có thể override để thực hiện các tác vụ dọn dẹp bổ sung
  void dispose() {}
}
