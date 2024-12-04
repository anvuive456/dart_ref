import 'dart:async';

import 'package:ref/src/base/base_ref.dart';
import 'package:ref/src/observer/base_observer.dart';

/// A generic class to hold and manage the state.
class Ref<T> extends BaseRef<T> {
  T _value;
  final _streamController = StreamController<T>.broadcast();

  Ref(
    this._value,
  ) {
    // Emit first value
    _streamController.add(_value);
  }

  /// Getter for the current value.
  @override
  T get state => _value;

  /// Setter to update the value and notify listeners.
  set state(T newValue) {
    if (newValue == _value) {
      return;
    }

    _value = newValue;
    _streamController.add(_value);
  }

  /// Update the value using a function and notify listeners.
  void update(T Function(T prev) updater) {
    state = updater(_value);
  }

  /// Listen to changes to the state.
  @override
  Stream<T> get changes => _streamController.stream;

  /// Close the stream when the state is no longer needed.
  @override
  void dispose() {
    if (_streamController.isClosed) {
      return;
    }
    _streamController.close();
  }
}

/// A helper function to create a new state.
Ref<T> ref<T>(T initialValue, {List<BaseObserver<T>>? observers}) {
  return Ref<T>(initialValue);
}
