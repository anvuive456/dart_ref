import 'package:ref/ref.dart';
import 'package:ref/src/base/base_ref.dart';

/// Một ref hỗ trợ undo/redo
///
/// [ReplayRef] lưu trữ lịch sử các state và cho phép undo/redo.
///
/// Ví dụ:
/// ```dart
/// final counterRef = replayRef(0, historyLimit: 10);
///
/// // Thay đổi state
/// counterRef.state = 1;
/// counterRef.state = 2;
///
/// // Undo về state trước đó
/// counterRef.undo(); // state = 1
///
/// // Redo về state sau đó
/// counterRef.redo(); // state = 2
/// ```
class ReplayRef<T> extends BaseRef<T> {
  /// Giới hạn số lượng state lưu trữ trong lịch sử
  final int historyLimit;

  /// Lịch sử các state
  final List<T> _history = [];

  /// Vị trí hiện tại trong lịch sử
  int _currentIndex = -1;

  /// Khởi tạo ReplayRef với giá trị ban đầu và giới hạn lịch sử
  ///
  /// [initialValue] là giá trị ban đầu của ref
  /// [historyLimit] là giới hạn số lượng state lưu trữ trong lịch sử
  ReplayRef(T initialValue, {this.historyLimit = 20}) : super(initialValue) {
    // Thêm state ban đầu vào lịch sử
    _addToHistory(initialValue);
  }

  /// Thêm một state vào lịch sử
  void _addToHistory(T state) {
    // Nếu đang ở giữa lịch sử, xóa tất cả các state sau vị trí hiện tại
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // Thêm state mới vào lịch sử
    _history.add(state);
    _currentIndex = _history.length - 1;

    // Nếu lịch sử vượt quá giới hạn, xóa state cũ nhất
    if (_history.length > historyLimit) {
      _history.removeAt(0);
      _currentIndex--;
    }
  }

  @override
  set state(T newState) {
    if (!shouldUpdate(state, newState)) return;

    // Thêm state mới vào lịch sử
    _addToHistory(newState);

    // Cập nhật state trong BaseRef
    super.state = newState;
  }

  /// Undo về state trước đó
  ///
  /// Trả về true nếu undo thành công, false nếu không thể undo
  bool undo() {
    if (_currentIndex <= 0) return false;

    _currentIndex--;
    final newState = _history[_currentIndex];

    // Cập nhật state trong BaseRef mà không gọi set state
    // để tránh thêm vào lịch sử
    super.state = newState;

    return true;
  }

  /// Redo về state sau đó
  ///
  /// Trả về true nếu redo thành công, false nếu không thể redo
  bool redo() {
    if (_currentIndex >= _history.length - 1) return false;

    _currentIndex++;
    final newState = _history[_currentIndex];

    // Cập nhật state trong BaseRef mà không gọi set state
    // để tránh thêm vào lịch sử
    super.state = newState;

    return true;
  }

  /// Kiểm tra xem có thể undo hay không
  bool get canUndo => _currentIndex > 0;

  /// Kiểm tra xem có thể redo hay không
  bool get canRedo => _currentIndex < _history.length - 1;

  /// Xóa toàn bộ lịch sử và đặt state hiện tại làm state duy nhất
  void clearHistory() {
    final currentState = state;
    _history.clear();
    _addToHistory(currentState);
  }

  /// Lấy toàn bộ lịch sử
  List<T> get history => List.unmodifiable(_history);

  /// Lấy vị trí hiện tại trong lịch sử
  int get currentIndex => _currentIndex;
}

/// Tạo một ReplayRef với giá trị ban đầu và giới hạn lịch sử
///
/// [initialValue] là giá trị ban đầu của ref
/// [historyLimit] là giới hạn số lượng state lưu trữ trong lịch sử
ReplayRef<T> replayRef<T>(
  T initialValue, {
  int historyLimit = 20,
}) {
  return ReplayRef<T>(
    initialValue,
    historyLimit: historyLimit,
  );
}
