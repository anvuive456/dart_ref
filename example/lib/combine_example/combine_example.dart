import 'package:flutter/material.dart';
import 'package:ref/ref.dart';

final _countRef = ref(0);
final _prefixRef = ref('Result');

// computedRef tự động phát hiện dependency vào _countRef và _prefixRef
final _labelRef = computedRef<String>(
  () => '${_prefixRef.state}: ${_countRef.state}',
);

class ComputedExample extends StatelessWidget {
  const ComputedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Computed Example')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReactiveWidget<String>(
            ref: _labelRef,
            builder: (context, value) => Text(
              value,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _countRef.update((v) => v - 1),
                child: const Text('-'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _countRef.update((v) => v + 1),
                child: const Text('+'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              _prefixRef.state =
                  _prefixRef.state == 'Result' ? 'Count' : 'Result';
            },
            child: const Text('Toggle Prefix'),
          ),
        ],
      ),
    );
  }
}
