import 'package:ref/src/base/base_ref.dart';
import 'package:ref/src/transformer/state_transformer.dart';

class TransformRef<T> extends BaseRef<T> {
  final BaseRef<T> _source;
  final StateTransformer<T> _transformer;

  TransformRef(this._source, this._transformer) : super(_source.state) {
    _source.addListener((value) {
      state = value;
    });
  }

  @override
  set state(T newState) {
    _transformer.onUpdate(newState, (value) {
      super.state = value;
    });
  }
}

TransformRef transformRef<T>(
  BaseRef<T> source,
  StateTransformer<T> transformer,
) =>
    TransformRef(
      source,
      transformer,
    );
