import 'package:flutter/foundation.dart';
import 'package:ref/ref.dart';

typedef ReadonlyRefSelector<R, T> = R Function(T parent);

class ReadonlyRef<R, T> extends BaseRef<R> {
  final BaseRef<T> _base;
  final ReadonlyRefSelector<R, T> selector;
  final _scopeId = Object().hashCode.toString();

  ReadonlyRef(
    this._base,
    this.selector,
  ) : super(selector(_base.state)) {
    // Listen to _base and notify.
    _base.addListener(
      (parentState) {
        final newSelectedState = selector(parentState);
        if (shouldUpdate(state, newSelectedState)) {
          state = newSelectedState;
        }
      },
      name: _scopeId,
    );
  }

  @override
  bool shouldUpdate(R oldState, R newState) {
    // Sử dụng toán tử == để so sánh giá trị được chọn
    return oldState != newState;
  }

  @override
  void dispose() {
    _base.removeListener(_scopeId);
  }
}
