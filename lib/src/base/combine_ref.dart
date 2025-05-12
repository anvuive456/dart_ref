import 'package:flutter/foundation.dart';
import 'package:ref/src/base/base_ref.dart';

/// Một class để kết hợp nhiều ref thành một ref mới
class CombineRef<T> extends BaseRef<T> {
  final List<BaseRef> _refs;
  final T Function(List<dynamic> states) _combiner;
  final Map<BaseRef, String> _scopeIds = {};

  CombineRef(
    this._refs,
    this._combiner,
  ) : super(
          _combiner(
            _refs.map((e) => e.state).toList(),
          ),
        ) {
    // Đăng ký listener cho mỗi ref
    for (final ref in _refs) {
      final scopeId = Object().hashCode.toString();
      _scopeIds[ref] = scopeId;

      ref.addListener(
        (value) {
          // Tính toán state mới khi bất kỳ ref nào thay đổi
          final newState = _combiner(
            _refs.map((e) => e.state).toList(),
          );

          // Chỉ cập nhật nếu state thực sự thay đổi
          if (shouldUpdate(state, newState)) {
            state = newState;
          }
        },
        name: scopeId,
      );
    }
  }

  @override
  bool shouldUpdate(T oldState, T newState) {
    // Sử dụng toán tử == để so sánh state
    return oldState != newState;
  }

  @override
  void dispose() {
    // Hủy đăng ký listener cho mỗi ref
    for (final entry in _scopeIds.entries) {
      entry.key.removeListener(entry.value);
    }
    _scopeIds.clear();
    super.dispose();
  }
}

/// Tạo một CombineRef từ danh sách các ref
///
/// Ví dụ:
/// ```dart
/// final nameRef = ref('John');
/// final ageRef = ref(30);
///
/// final personRef = combineRef(
///   [nameRef, ageRef],
///   (states) => {'name': states[0], 'age': states[1]},
/// );
/// ```
CombineRef<T> combineRef<T>(
  List<BaseRef> refs,
  T Function(List<dynamic> states) combiner,
) {
  return CombineRef<T>(
    refs,
    combiner,
  );
}

/// Tạo một CombineRef từ 2 ref
CombineRef<R> combine2Refs<A, B, R>(
  BaseRef<A> refA,
  BaseRef<B> refB,
  R Function(A a, B b) combiner,
) {
  return CombineRef<R>(
    [refA, refB],
    (states) => combiner(states[0] as A, states[1] as B),
  );
}

/// Tạo một CombineRef từ 3 ref
CombineRef<R> combine3Refs<A, B, C, R>(
  BaseRef<A> refA,
  BaseRef<B> refB,
  BaseRef<C> refC,
  R Function(A a, B b, C c) combiner,
) {
  return CombineRef<R>(
    [refA, refB, refC],
    (states) => combiner(
      states[0] as A,
      states[1] as B,
      states[2] as C,
    ),
  );
}
