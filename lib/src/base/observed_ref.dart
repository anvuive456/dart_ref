import 'dart:async';

import 'package:ref/ref.dart';
import 'package:ref/src/observer/base_observer.dart';

class ObservedRef<T> extends BaseRef<T> {
  final BaseRef<T> _source;
  final List<BaseObserver<T>> _observers;
  late T _lastState;

  // StreamController dùng để phát lại các sự kiện trạng thái
  final StreamController<T> _streamController = StreamController<T>.broadcast();

  ObservedRef(
    this._source,
    this._observers,
  ) : _lastState = _source.state;

  @override
  T get state => _source.state;

  @override
  Stream<T> get changes {
    _source.changes.listen((nextState) {
      _notifyStateChanged(_lastState, nextState);
      _lastState = nextState;
    });
    return _streamController.stream;
  }

  // void addObserver(BaseObserver<T> observer) {
  //   _observers.add(observer);
  //   observer.onStateChanged(
  //     _source.runtimeType,
  //     _lastState,
  //     _source.state,
  //   ); // Thông báo state hiện tại
  // }

  void _notifyStateChanged(T currentState, T nextState) {
    for (var observer in _observers) {
      observer.onStateChanged(
        _source.runtimeType,
        currentState,
        nextState,
      );
    }

    _streamController
        .add(nextState); // Phát lại trạng thái mới qua streamController
  }

  void _notifyDisposed() {
    for (var observer in _observers) {
      observer.onDisposed(
        _source.runtimeType,
      );
    }
  }

  @override
  void dispose() {
    _source.dispose();
    _notifyDisposed();
    _streamController.close(); // Đóng streamController khi Ref bị disposed
  }
}
