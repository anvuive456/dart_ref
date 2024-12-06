import 'package:flutter/material.dart';
import 'package:ref/ref.dart';

final count = ref(0);

class BasicExample extends StatelessWidget {
  const BasicExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ReactiveWidget(
              ref: count,
              builder: (context, state) => Text('Count: $state'),
            ),
            ElevatedButton(
                child: const Text('Increase count'),
                onPressed: () {
                  count.state++;
                }),
            ElevatedButton(
                child: const Text('Decrease count'),
                onPressed: () {
                  count.state--;
                }),
          ],
        ),
      ),
    );
  }
}
