import 'package:flutter/widgets.dart';
import 'package:ref/ref.dart';

/// Một Provider để cung cấp ref cho widget tree
class RefProvider<T> extends InheritedWidget {
  final BaseRef<T> ref;

  const RefProvider({
    super.key,
    required this.ref,
    required super.child,
  });

  /// Lấy ref từ context
  static BaseRef<T> of<T>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RefProvider<T>>();
    if (provider == null) {
      throw Exception('No RefProvider<$T> found in context');
    }
    return provider.ref;
  }

  /// Lấy ref từ context mà không đăng ký dependency
  static BaseRef<T>? maybeOf<T>(BuildContext context) {
    final provider = context.getInheritedWidgetOfExactType<RefProvider<T>>();
    return provider?.ref;
  }

  @override
  bool updateShouldNotify(RefProvider<T> oldWidget) {
    return ref != oldWidget.ref;
  }
}

/// Một Consumer để tiêu thụ ref từ widget tree
class RefConsumer<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T state) builder;
  final void Function(T state)? listener;

  const RefConsumer({
    super.key,
    required this.builder,
    this.listener,
  });

  @override
  Widget build(BuildContext context) {
    final ref = RefProvider.of<T>(context);
    return ReactiveWidget<T>(
      ref: ref,
      builder: builder,
      listener: listener,
    );
  }
}

/// Một widget để cung cấp nhiều ref cho widget tree
class MultiRefProvider extends StatelessWidget {
  final List<SingleChildWidget> providers;
  final Widget child;

  const MultiRefProvider({
    super.key,
    required this.providers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    for (final provider in providers.reversed) {
      result = provider.buildWithChild(result);
    }
    return result;
  }
}

/// Interface cho các widget có thể build với một child
abstract class SingleChildWidget implements Widget {
  Widget buildWithChild(Widget child);
}

/// Một Provider có thể được sử dụng trong MultiRefProvider
class SingleRefProvider<T> extends StatelessWidget implements SingleChildWidget {
  final BaseRef<T> ref;
  final Widget? child;

  const SingleRefProvider({
    super.key,
    required this.ref,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefProvider<T>(
      ref: ref,
      child: child!,
    );
  }

  @override
  Widget buildWithChild(Widget child) {
    return RefProvider<T>(
      ref: ref,
      child: child,
    );
  }
}
