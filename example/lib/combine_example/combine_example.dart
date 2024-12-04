import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ref/ref.dart';

final _ref = CombineRef<String>([
  ref(0),
  ref('I go second'),
  futureRef(
    () async {
      await Future.delayed(
        const Duration(
          seconds: 3,
        ),
      );
      return 'I go third';
    },
  ),
  CombineRef(
    [
      futureRef(() async {
        return 'I go fourth';
      }),
      transformRef<String>(
        Ref('HEHE'),
        debounceTransformer(
          const Duration(
            milliseconds: 500,
          ),
        ),
      )
    ],
    (ref) {
      return ref.join(',');
    },
  ),
], (ref) {
  return 'Combined ref: ${ref.join(',')}';
});

class CombineExample extends StatelessWidget {
  const CombineExample({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReactiveWidget<String>(
            ref: _ref,
            builder: (context, value) => Text(value),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text(
              'Update state',
            ),
          )
        ],
      ),
    );
  }
}
