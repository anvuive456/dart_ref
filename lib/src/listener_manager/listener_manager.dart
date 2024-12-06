typedef ListenerFunc<T> = void Function(T value);

class ListenerManager<T> {
  /// store listeners
  final Map<String, ListenerFunc<T>> _listeners = {};

  void addListener(
    String name,
    ListenerFunc<T> func,
  ) {
    _listeners[name] = func;
  }

  void removeListener(
    String name,
  ) {
    _listeners.remove(name);
  }

  void notify(
    String name,
    T value,
  ) {
    _listeners[name]?.call(
      value,
    );
  }

  void notifyAll(
    T value,
  ) {
    for (final listener in _listeners.values) {
      listener(
        value,
      );
    }
  }

  void clearListeners() {
    _listeners.clear();
  }

  bool isEmpty() {
    return _listeners.isEmpty;
  }
}
