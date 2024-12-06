import 'package:example/basic_example/basic_example.dart';
import 'package:example/custom_example/custom_example.dart';
import 'package:example/future_example/future_example.dart';
import 'package:example/select_example/select_example.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ref/ref.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalObserverManager().addObserver(LogObserver());
  runApp(const MyApp());
}

final goRouter = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text('Basic Example'),
                    onPressed: () {
                      context.push('/basic_example');
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Select Example'),
                    onPressed: () {
                      context.push('/select_example');
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Future Example'),
                    onPressed: () {
                      context.push('/future_example');
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Custom Example'),
                    onPressed: () {
                      context.push('/custom_example');
                    },
                  ),
                ],
              ),
            ),
          );
        }),
    GoRoute(
      path: '/select_example',
      builder: (context, state) => const SelectExample(),
    ),
    GoRoute(
      path: '/basic_example',
      builder: (context, state) => const BasicExample(),
    ),
    GoRoute(
      path: '/future_example',
      builder: (context, state) => const FutureExample(),
    ),
    GoRoute(
      path: '/custom_example',
      builder: (context, state) => const CustomRefExample(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(),
      routerConfig: goRouter,
    );
  }
}
