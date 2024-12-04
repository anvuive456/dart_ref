import 'dart:async';

import 'package:ref/ref.dart';
import 'package:rxdart/rxdart.dart';

typedef ReadonlyRefSelector<R, T> = R Function(T parent);

class ReadonlyRef<R, T> extends BaseRef<R> {
  final BaseRef<T> _base;
  final ReadonlyRefSelector<R, T> selector;
  late final StreamController<R> _streamController;
  late R _state;

  ReadonlyRef(
    this._base,
    this.selector,
  ) {
    _state = selector(_base.state);
    // Khởi tạo StreamController với giá trị ban đầu từ selector
    _streamController = BehaviorSubject.seeded(_state);

    // Lắng nghe sự thay đổi từ _base
    _base.changes.listen((event) {
      final newValue = selector(_base.state);
      if (newValue != _state) {
        _state = newValue;
        _streamController.add(_state);
      }
    });
  }

  @override
  Stream<R> get changes => _streamController.stream;

  @override
  R get state => _state;

  @override
  void dispose() {
    _streamController.close();
  }
}
