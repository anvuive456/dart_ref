abstract class BaseObserver<T> {
  /// Lắng nghe sự thay đổi giữa `currentState` và `nextState`.
  void onStateChanged(
    Type refType,
    T currentState,
    T nextState,
  );

  /// Lắng nghe khi một Ref bị disposed.
  void onDisposed(
    Type refType,
  );

  /// Lắng nghe khi một listener mới được thêm vào.
  void onListenerAdded(
    Type refType,
    String listenerName,
  );

  /// Listen to a listener when cleared.
  void onListenerRemoved(
    Type refType,
    String listenerName,
  );

  /// Listen when all listeners are cleared.
  void onListenersCleared(
    Type refType,
  );
}
