import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:ref/ref.dart';

typedef ReactiveWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T state,
);

class ReactiveWidget<T> extends StatefulWidget {
  ReactiveWidget({
    super.key,
    required this.ref,
    required this.builder,
  });

  final BaseRef<T> ref;
  final ReactiveWidgetBuilder<T> builder;

  @override
  // ignore: library_private_types_in_public_api
  _ReactiveState<T> createState() => _ReactiveState<T>();
}

class _ReactiveState<T> extends State<ReactiveWidget<T>> {
  late T _innerValue;
  late StreamSubscription<T> subscription;

  @override
  void initState() {
    _innerValue = widget.ref.state;

    subscription = widget.ref.changes.listen(
      (event) {
        setState(() {
          _innerValue = event;
        });
      },
    );

    super.initState();
  }

  @override
  dispose() {
    subscription.cancel();
    // widget.ref.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _innerValue,
      );
}
