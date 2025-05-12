import 'package:ref/src/transformer/state_transformer.dart';

/// Định nghĩa kiểu dữ liệu cho middleware
typedef Middleware<T> = T? Function(T state, T nextState, void Function(T state) next);

/// Một transformer để áp dụng middleware cho state
///
/// Middleware có thể:
/// - Chặn cập nhật state bằng cách trả về null
/// - Sửa đổi state bằng cách trả về state mới
/// - Cho phép state đi qua bằng cách gọi next(state)
///
/// Ví dụ:
/// ```dart
/// final middlewareTransformer = MiddlewareTransformer<int>([
///   // Middleware 1: Ghi log
///   (state, nextState, next) {
///     print('State changing from $state to $nextState');
///     next(nextState); // Cho phép state đi qua
///     return null;
///   },
///   // Middleware 2: Chỉ cho phép số dương
///   (state, nextState, next) {
///     if (nextState < 0) {
///       print('Negative value not allowed');
///       return null; // Chặn cập nhật state
///     }
///     next(nextState); // Cho phép state đi qua
///     return null;
///   },
///   // Middleware 3: Làm tròn số
///   (state, nextState, next) {
///     final roundedState = nextState.round();
///     next(roundedState); // Sửa đổi state
///     return null;
///   },
/// ]);
/// ```
class MiddlewareTransformer<T> extends StateTransformer<T> {
  /// Danh sách các middleware
  final List<Middleware<T>> _middlewares;

  /// Khởi tạo MiddlewareTransformer với danh sách các middleware
  ///
  /// Các middleware sẽ được áp dụng theo thứ tự trong danh sách
  MiddlewareTransformer(this._middlewares);

  @override
  void onUpdate(T state, Function(T newState) notify) {
    // Tạo một bản sao của state để truyền qua các middleware
    T currentState = state;
    
    // Biến để kiểm tra xem state có bị chặn hay không
    bool blocked = false;
    
    // Áp dụng các middleware theo thứ tự
    for (final middleware in _middlewares) {
      // Gọi middleware với state hiện tại và state tiếp theo
      final result = middleware(
        currentState,
        state,
        (T modifiedState) {
          // Cập nhật state hiện tại
          currentState = modifiedState;
        },
      );
      
      // Nếu middleware trả về một giá trị không null, sử dụng giá trị đó làm state mới
      if (result != null) {
        currentState = result;
      }
      
      // Nếu middleware trả về null và không gọi next, coi như state bị chặn
      if (result == null && currentState == state) {
        blocked = true;
        break;
      }
    }
    
    // Nếu state không bị chặn, thông báo cho listeners
    if (!blocked) {
      notify(currentState);
    }
  }
}

/// Tạo một MiddlewareTransformer với danh sách các middleware
///
/// Các middleware sẽ được áp dụng theo thứ tự trong danh sách
StateTransformer<T> middlewareTransformer<T>(List<Middleware<T>> middlewares) {
  return MiddlewareTransformer<T>(middlewares);
}
