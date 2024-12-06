import 'package:ref/src/base/base_ref.dart';
import 'package:ref/src/observer/base_observer.dart';

/// A generic class to hold and manage the state.
class Ref<T> extends BaseRef<T> {
  Ref(
    super._state,
  );

  /// Update the value using a function and notify listeners.
  void update(T Function(T prev) updater) {
    state = updater(state);
  }
}

/// A helper function to create a new state.
Ref<T> ref<T>(T initialValue, {List<BaseObserver<T>>? observers}) {
  return Ref<T>(initialValue);
}
