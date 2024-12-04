import 'dart:async';

import 'package:ref/src/base/base_ref.dart';

class TransformRef<T> extends BaseRef<T> {
  final BaseRef<T> _source;
  final StreamTransformer<T, T> _transformer;
  late Stream<T> _transformedStream;

  TransformRef(
    this._source,
    this._transformer,
  ) {
    _transformedStream = _source.changes.transform(
      _transformer,
    );
  }

  @override
  T get state => _source.state;

  @override
  Stream<T> get changes => _transformedStream;

  @override
  void dispose() {
    _source.dispose();
  }
}

TransformRef transformRef<T>(
  BaseRef<T> source,
  StreamTransformer<T, T> transformer,
) =>
    TransformRef(
      source,
      transformer,
    );
