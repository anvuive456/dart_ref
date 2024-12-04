import 'dart:async';

import 'package:ref/src/async_value/async_value.dart';
import 'package:ref/src/base/base_ref.dart';
import 'package:rxdart/rxdart.dart';

class FutureRef<T> extends BaseRef<AsyncValue<T>> {
  AsyncValue<T> _state;
  // use replay for make sure the loading is emitted
  final _streamController = ReplaySubject<AsyncValue<T>>(maxSize: 1);

  FutureRef(
    Future<T> Function() future,
  ) : _state = AsyncLoading() {
    _streamController.add(_state);
    _loadFuture(future);
  }

  Future<void> _loadFuture(
    Future<T> Function() future,
  ) async {
    future().then((value) {
      _state = AsyncSuccess(value);
      _streamController.add(_state);
    }).catchError((error, stackTrace) {
      _state = AsyncError(error, stackTrace);
      _streamController.add(_state);
    });
  }

  @override
  AsyncValue<T> get state => _state;

  @override
  Stream<AsyncValue<T>> get changes => _streamController.stream;

  @override
  void dispose() {
    _streamController.close();
  }
}

FutureRef<T> futureRef<T>(Future<T> Function() future) {
  return FutureRef<T>(future);
}
