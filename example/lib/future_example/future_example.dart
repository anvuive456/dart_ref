import 'package:flutter/material.dart';
import 'package:ref/ref.dart';

class FutureExample extends StatelessWidget {
  const FutureExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ReactiveWidget(
      ref: futureRef(() async => Future.delayed(
            const Duration(seconds: 3),
            () {
              return 'Hello world';
            },
          )),
      builder: (context, state) {
        if (state.isLoading) {
          return const Text(
            'Please wait...',
          );
        }

        return Text(
          state.data!,
        );
      },
    );
  }
}
