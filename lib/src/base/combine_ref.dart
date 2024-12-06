import 'package:ref/src/base/base_ref.dart';

class CombineRef<T> extends BaseRef<T> {
  final List<BaseRef> _refs;
  final T Function(Iterable<dynamic> ref) _combiner;

  CombineRef(
    this._refs,
    this._combiner,
  ) : super(
          _combiner(
            _refs.map((e) => e.state),
          ),
        ) {
    for (final ref in _refs) {
      ref.addListener(
        (value) {
          state = _combiner(_refs.map((e) => e.state));
        },
      );
    }
  }

  @override
  void dispose() {
    for (var ref in _refs) {
      ref.removeListener(null);
    }
  }
}

CombineRef combineRef<T>(
  List<BaseRef> refs,
  T Function(Iterable<dynamic> ref) combiner,
) {
  final combinedRef = CombineRef(
    refs,
    combiner,
  );

  return combinedRef;
}
