abstract class BaseObserver<T> {
  // Lắng nghe sự thay đổi giữa currentState và nextState
  void onStateChanged(
    Type refType,
    T currentState,
    T nextState,
  );

  // Lắng nghe khi Ref bị disposed
  void onDisposed(
    Type refType,
  );
}
