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
        state = selector(parentState);
      },
      name: _scopeId,
    );
  }

  @override
  void dispose() {
    _base.removeListener(_scopeId);
  }
}
