import 'package:flutter/foundation.dart';
import 'package:ref/ref.dart';

abstract class BaseRef<T> {
  T get state;

  Stream<T> get changes;

  /// Generic select method for all Ref types.
  ReadonlyRef<R, T> select<R>(ReadonlyRefSelector<R, T> selector) =>
      ReadonlyRef<R, T>(this, selector);

  ValueNotifier<T> listenable() {
    final notifier = ValueNotifier(state);
    changes.listen((event) {
      notifier.value = event;
    });
    return notifier;
  }

  void dispose();
}
