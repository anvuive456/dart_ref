import 'dart:async';

import 'package:ref/src/transformer/state_transformer.dart';

class ThrottleTransformer<T> extends StateTransformer<T> {
  final Duration throttleDuration;
  bool _canNotify = true;

  ThrottleTransformer(
    this.throttleDuration,
  );

  @override
  void onUpdate(T state, Function(T newState) notify) {
    if (_canNotify) {
      notify(state);
      _canNotify = false;
      Timer(throttleDuration, () {
        _canNotify = true;
      });
    }
  }
}
