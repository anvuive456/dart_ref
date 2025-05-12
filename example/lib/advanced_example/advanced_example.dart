import 'package:flutter/material.dart';
import 'package:ref/ref.dart';

// Tạo một PersistentRef để lưu trữ counter
final persistentCounterRef = persistentRef<int>(
  'persistent_counter',
  0,
);

// Tạo một ReplayRef để hỗ trợ undo/redo
final replayCounterRef = replayRef<int>(
  0,
  historyLimit: 10,
);

// Tạo một TransformRef với middleware để kiểm soát giá trị counter
final middlewareCounterRef = transformRef<int>(
  ref(0),
  middlewareTransformer<int>([
    // Middleware 1: Ghi log
    (state, nextState, next) {
      print('Counter changing from $state to $nextState');
      next(nextState); // Cho phép state đi qua
      return null;
    },
    // Middleware 2: Giới hạn giá trị từ 0 đến 10
    (state, nextState, next) {
      if (nextState < 0) {
        print('Counter không thể nhỏ hơn 0');
        return 0; // Giới hạn giá trị nhỏ nhất là 0
      }
      if (nextState > 10) {
        print('Counter không thể lớn hơn 10');
        return 10; // Giới hạn giá trị lớn nhất là 10
      }
      next(nextState); // Cho phép state đi qua
      return null;
    },
  ]),
);

class AdvancedExample extends StatelessWidget {
  const AdvancedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PersistentRef Example
            const Text(
              'PersistentRef Example',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Counter được lưu vào SharedPreferences và sẽ được khôi phục khi khởi động lại ứng dụng',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ReactiveWidget(
                  ref: persistentCounterRef,
                  builder: (context, value) {
                    return Text(
                      'Persistent Counter: $value',
                      style: const TextStyle(fontSize: 16),
                    );
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    persistentCounterRef.state++;
                  },
                  child: const Text('Tăng'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    persistentCounterRef.state--;
                  },
                  child: const Text('Giảm'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await persistentCounterRef.clearPersistedState();
                    persistentCounterRef.state = 0;
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ReplayRef Example
            const Text(
              'ReplayRef Example',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Counter hỗ trợ undo/redo',
            ),
            const SizedBox(height: 8),
            ReactiveWidget(
              ref: replayCounterRef,
              builder: (context, value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Replay Counter: $value',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            replayCounterRef.state++;
                          },
                          child: const Text('Tăng'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            replayCounterRef.state--;
                          },
                          child: const Text('Giảm'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: replayCounterRef.canUndo
                              ? () {
                                  replayCounterRef.undo();
                                }
                              : null,
                          child: const Text('Undo'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: replayCounterRef.canRedo
                              ? () {
                                  replayCounterRef.redo();
                                }
                              : null,
                          child: const Text('Redo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'History: ${replayCounterRef.history.join(', ')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Current Index: ${replayCounterRef.currentIndex}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Middleware Example
            const Text(
              'Middleware Example',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Counter với middleware giới hạn giá trị từ 0 đến 10',
            ),
            const SizedBox(height: 8),
            ReactiveWidget(
              ref: middlewareCounterRef,
              builder: (context, value) {
                return Row(
                  children: [
                    Text(
                      'Middleware Counter: $value',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        middlewareCounterRef.state++;
                      },
                      child: const Text('Tăng'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        middlewareCounterRef.state--;
                      },
                      child: const Text('Giảm'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Thử vượt quá giới hạn
                        middlewareCounterRef.state = 20;
                      },
                      child: const Text('Set 20'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Thử vượt quá giới hạn
                        middlewareCounterRef.state = -5;
                      },
                      child: const Text('Set -5'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
