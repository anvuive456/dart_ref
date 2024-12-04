import 'package:example/custom_example/custom_controller.dart';
import 'package:flutter/material.dart';
import 'package:ref/ref.dart';

class CustomRefExample extends StatelessWidget {
  const CustomRefExample({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveWidget(
      ref: customController,
      builder: (BuildContext context, CustomState value) {
        return Column(
          children: [
            TextButton(
              onPressed: value.loading
                  ? null
                  : () {
                      customController.increase();
                    },
              child: Text('Click to increase: ${value.value}'),
            ),
          ],
        );
      },
    );
  }
}
