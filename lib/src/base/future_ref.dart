import 'dart:async';

import 'package:ref/src/async_value/async_value.dart';
import 'package:ref/src/base/base_ref.dart';

class FutureRef<T> extends BaseRef<AsyncValue<T>> {
  FutureRef(
    Future<T> Function() future,
  ) : super(AsyncLoading()) {
    _loadFuture(future);
  }

  Future<void> _loadFuture(
    Future<T> Function() future,
  ) async {
    future().then((value) {
      state = AsyncSuccess(value);
    }).catchError((error, stackTrace) {
      state = AsyncError(error, stackTrace);
    });
  }
}

FutureRef<T> futureRef<T>(Future<T> Function() future) {
  return FutureRef<T>(future);
}
