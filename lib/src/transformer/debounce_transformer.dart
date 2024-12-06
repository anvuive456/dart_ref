import 'dart:async';

import 'package:ref/src/transformer/state_transformer.dart';

class DebounceTransformer<T> extends StateTransformer<T> {
  final Duration debounceDuration;
  Timer? _debounceTimer;

  DebounceTransformer(this.debounceDuration);

  @override
  void onUpdate(T state, Function(T) notify) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () => notify(state));
  }
}
