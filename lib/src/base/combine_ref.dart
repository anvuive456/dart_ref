import 'dart:async';

import 'package:async/async.dart';
import 'package:ref/src/base/base_ref.dart';
import 'package:ref/src/base/observed_ref.dart';
import 'package:ref/src/observer/base_observer.dart';
import 'package:rxdart/rxdart.dart';

class CombineRef<T> extends BaseRef<T> {
  final List<BaseRef> _refs;
  final T Function(List<dynamic> ref) _combiner;
  late final StreamController<T> _controller;
  late final StreamSubscription _subscription;

  CombineRef(
    this._refs,
    this._combiner,
  ) {
    // Init controller and group
    _controller = BehaviorSubject.seeded(_combiner(
      _refs.map((ref) => ref.state).toList(),
    ));

    _subscription = StreamGroup.merge(
      _refs.map(
        (e) => e.changes,
      ),
    ).listen((_) {
      print('merge data: $_');
      final combinedState = _combiner(
        _refs.map((ref) => ref.state).toList(),
      );
      _controller.add(combinedState);
    });
  }

  @override
  T get state => _combiner(_refs
      .map(
        (ref) => ref.state,
      )
      .toList());

  @override
  Stream<T> get changes => _controller.stream;

  @override
  void dispose() {
    _subscription.cancel();
    _controller.close();
    for (var ref in _refs) {
      ref.dispose();
    }
  }
}

BaseRef combineRef<T>(
  List<BaseRef> refs,
  T Function(List<dynamic> ref) combiner, {
  List<BaseObserver>? observers,
}) {
  final combinedRef = CombineRef(
    refs,
    combiner,
  );
  if (observers != null) {
    return ObservedRef(
      combinedRef,
      observers,
    );
  }
  return combinedRef;
}
