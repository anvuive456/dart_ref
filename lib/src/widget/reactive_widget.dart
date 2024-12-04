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
  late ValueNotifier<T> _valueNotifier;

  @override
  void initState() {
    _valueNotifier = ValueNotifier(widget.ref.state);

    widget.ref.changes.listen(
      (event) {
        _valueNotifier.value = event;
      },
    );

    super.initState();
  }

  @override
  dispose() {
    // widget.ref.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<T>(
        valueListenable: _valueNotifier,
        builder: (context, value, child) => widget.builder(
          context,
          value,
        ),
      );
}
