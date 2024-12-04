import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ref/ref.dart';

final _ref = ref(
  {
    'Hello': 'Wolrd',
    'foo': 'bar',
  },
);

class SelectExample extends StatelessWidget {
  const SelectExample({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ReactiveWidget(
                ref: _ref,
                builder: (context, value) {
                  return Text(value.toString());
                }),
            ReactiveWidget(
                ref: _ref.select((value) => value['Hello']),
                builder: (context, value) {
                  return Text(value.toString());
                }),
            ReactiveWidget(
                ref: _ref.select((value) => value['foo']),
                builder: (context, value) {
                  return Text(value.toString());
                }),
            ElevatedButton(
              onPressed: () {
                _ref.update((prev) => {
                      ...prev,
                      'Hello': Random.secure().nextDouble().toString(),
                    });
              },
              child: const Text('Change Hello only'),
            ),
            ElevatedButton(
              onPressed: () {
                _ref.update((prev) => {
                      ...prev,
                      'foo': Random.secure().nextDouble().toString(),
                    });
              },
              child: const Text('Change foo only'),
            ),
          ],
        ),
      ),
    );
  }
}
