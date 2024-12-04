import 'package:flutter/foundation.dart';
import 'package:ref/ref.dart';

abstract class BaseRef<T> {
  T get state;

  Stream<T> get changes;

  /// Generic select method for all Ref types.
  Ref<R> select<R>(R Function(T parent) selector) {
    final selectedValue = selector(state);
    final selectedRef = Ref<R>(selectedValue);

    changes.listen((parentValue) {
      final newState = selector(parentValue);
      if (newState != selectedRef.state) {
        selectedRef.state = newState;
      }
    });

    return selectedRef;
  }

  ValueNotifier<T> listenable() {
    final notifier = ValueNotifier(state);
    changes.listen((event) {
      notifier.value = event;
    });
    return notifier;
  }

  void dispose();
}
