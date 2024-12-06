import 'package:ref/ref.dart';
import 'package:ref/src/listener_manager/listener_manager.dart';
import 'package:ref/src/observer/global_observer_manager.dart';
import 'package:ref/src/observer/ref_observer_mixin.dart';

abstract class BaseRef<T> with RefObserverMixin {
  final _listenerManager = ListenerManager<T>();
  final _scopeId = Object().hashCode.toString();

  T _state;
  BaseRef(this._state);
  ReadonlyRef<R, T> select<R>(ReadonlyRefSelector<R, T> selector) =>
      ReadonlyRef<R, T>(this, selector);

  T get state => _state;

  set state(T newState) {
    if (_state == newState) return;
    didNotifyStateChanged(runtimeType, _state, newState);
    GlobalObserverManager().notifyStateChanged(runtimeType, state, newState);
    _state = newState;
    notify();
  }

  void notify() {
    _listenerManager.notifyAll(state);
  }

  void addListener(
    ListenerFunc<T> func, {
    String? name,
  }) {
    _listenerManager.addListener(name ?? _scopeId, func);
    // notify for the first time listen
    _listenerManager.notify(name ?? _scopeId, state);
    didAddListener(runtimeType, name ?? _scopeId);
  }

  /// Auto run dispose when there is no listener
  ///
  /// Remove with scopeId when name is null
  void removeListener(String? name) {
    _listenerManager.removeListener(name ?? _scopeId);
    didRemoveListener(runtimeType, name ?? _scopeId);
    if (_listenerManager.isEmpty()) {
      dispose();
    }
  }

  void dispose() {}
}
