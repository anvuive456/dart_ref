import 'package:flutter/material.dart';
import 'package:ref/ref.dart';

final idRef = familyRef<String, AsyncValue<String>>(
  (key) => futureRef<String>(
    () async {
      return await Future.delayed(
        const Duration(seconds: 3),
        () => 'Hello: $key',
      );
    },
  ),
);

class FamilyExample extends StatelessWidget {
  const FamilyExample({
    super.key,
    required this.id,
  });
  final String id;

  @override
  Widget build(BuildContext context) {
    return ReactiveWidget(
        ref: idRef(id),
        builder: (context, state) {
          if (state.isLoading) return const Text('Wait for it...');
          return Text(state.data!);
        });
  }
}
