import 'package:example/select_example/select_example.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ref/ref.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

final _routeRef = ref('/');

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(),
      routerConfig: GoRouter(
        refreshListenable: _routeRef.listenable(),
        redirect: (context, state) {
          return _routeRef.state;
        },
        routes: [
          GoRoute(
              path: '/',
              builder: (context, state) {
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        child: const Text('Select Example'),
                        onPressed: () {
                          context.go('/select_example');
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Select Example'),
                        onPressed: () {
                          context.go('/select_example');
                        },
                      ),
                    ],
                  ),
                );
              }),
          GoRoute(
              path: '/select_example',
              builder: (context, state) => const SelectExample())
        ],
      ),
    );
  }
}
