import 'package:flutter/widgets.dart';
import 'package:ref/ref.dart';

typedef ReactiveWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T state,
);

typedef ReactiveWidgetListener<T> = void Function(
  T state,
);

class ReactiveWidget<T> extends StatefulWidget {
  ReactiveWidget({
    super.key,
    required this.ref,
    required this.builder,
    this.listener,
  });

  final BaseRef<T> ref;
  final ReactiveWidgetBuilder<T> builder;
  final ReactiveWidgetListener<T>? listener;

  @override
  // ignore: library_private_types_in_public_api
  _ReactiveState<T> createState() => _ReactiveState<T>();
}

class _ReactiveState<T> extends State<ReactiveWidget<T>> {
  late T value;

  /// unique name
  final _scopeId = Object().hashCode.toString();

  @override
  void initState() {
    value = widget.ref.state;

    widget.ref.addListener(
      (event) {
        widget.listener?.call(event);
        setState(() {
          value = event;
        });
      },
      name: _scopeId,
    );

    super.initState();
  }

  @override
  dispose() {
    widget.ref.removeListener(_scopeId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        value,
      );
}
