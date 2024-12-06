abstract class StateTransformer<T> {
  void onUpdate(T state, Function(T newState) notify);
}
