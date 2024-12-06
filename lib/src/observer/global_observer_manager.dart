import 'package:ref/src/observer/base_observer.dart';

/// A singleton for registering global ref observers
class GlobalObserverManager {
  static final _instance = GlobalObserverManager._internal();

  GlobalObserverManager._internal();

  factory GlobalObserverManager() => _instance;

  final List<BaseObserver> _observers = [];

  void addObserver(BaseObserver observer) {
    _observers.add(observer);
  }

  void removeObserver(BaseObserver observer) {
    _observers.remove(observer);
  }

  void notifyStateChanged<T>(Type refType, T currentState, T nextState) {
    for (final observer in _observers) {
      observer.onStateChanged(refType, currentState, nextState);
    }
  }

  void notifyDisposed(Type refType) {
    for (final observer in _observers) {
      observer.onDisposed(refType);
    }
  }
}
