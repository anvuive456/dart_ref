import 'package:ref/src/observer/base_observer.dart';

mixin RefObserverMixin<T> {
  final List<BaseObserver<T>> _observers = [];

  /// Add observer to list
  void addObserver(BaseObserver<T> observer) {
    _observers.add(observer);
  }

  /// Remove observer out of list
  void removeObserver(BaseObserver<T> observer) {
    _observers.remove(observer);
  }

  /// Call `onStateChanged` for all obervers
  void didNotifyStateChanged(Type refType, T currentState, T nextState) {
    for (final observer in _observers) {
      observer.onStateChanged(refType, currentState, nextState);
    }
  }

  /// Call `onDisposed` for all obervers
  void didDiposed(Type refType) {
    for (final observer in _observers) {
      observer.onDisposed(refType);
    }
  }

  void didAddListener(Type refType, String listenerName) {
    for (final observer in _observers) {
      observer.onListenerAdded(refType, listenerName);
    }
  }

  void didRemoveListener(Type refType, String listenerName) {
    for (final observer in _observers) {
      observer.onListenerRemoved(refType, listenerName);
    }
  }

  void didRemoveAllListener(Type refType) {
    for (final observer in _observers) {
      observer.onListenersCleared(refType);
    }
  }
}
