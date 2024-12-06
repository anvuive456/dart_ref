# **State Management Library for Dart/Flutter**

## **Overview**

This library provides a small and efficient state management solution for Dart and Flutter applications. It enables developers to handle application states with precision, offering features such as `Ref`, `TransformRef`, `CombineRef`, `ReadonlyRef`, and more. It also integrates a robust observer mechanism for tracking state changes globally or locally.

---

## **Features**

### **Core Features**
- **BaseRef**: A foundational class for state management, offering listeners and state tracking.
- **TransformRef**: Allows transformation of state change notifications using custom transformers.
- **CombineRef**: Combines multiple `Ref` objects and computes a new state based on their changes.
- **ReadonlyRef**: Enables derived states without modifying the original state.
- **FutureRef**: Handles asynchronous operations with built-in state tracking (`AsyncLoading`, `AsyncSuccess`, `AsyncError`).

### **Observer Mechanism**
- **Local Observers**: Track changes in individual `Ref` objects.
- **Global Observers**: Monitor all `Ref` instances across the application for debugging or analytics purposes.

### **Advanced State Transformations**
- Supports state transformations like debounce, throttle, and replay through `TransformRef`.
- Flexible transformer class design for custom state management logic.

---

## **Installation**

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  ref:
    git:
      path: https://github.com/anvuive456/dart_ref
```

Then, run:

```bash
flutter pub get
```

---

## **Usage**

### **1. Basic Ref**

```dart
final counter = Ref(0);

counter.addListener((state) {
  print('Counter updated: $state');
});

counter.state = 1; // Notify listener: "Counter updated: 1"
```

### **2. TransformRef with Debounce**

```dart
final counter = Ref(0);
final debounceRef = TransformRef<int>(
  counter,
  transformer: DebounceTransformer(delay: Duration(milliseconds: 500)),
);

debounceRef.addListener((state) {
  print('Debounced counter: $state');
});

counter.state = 1; // After 500ms: "Debounced counter: 1"
```

### **3. CombineRef**

```dart
final refA = Ref(1);
final refB = Ref(2);

final combined = CombineRef<int>(
  [refA, refB],
  (refs) => refs[0] + refs[1], // Combines refA and refB states
);

combined.addListener((state) {
  print('Combined state: $state'); // Outputs: "Combined state: 3"
});

refA.state = 3; // Outputs: "Combined state: 5"
```

### **4. Global Observer**

```dart
class MyGlobalObserver<T> extends BaseObserver<T> {
  @override
  void onStateChanged(Type refType, T currentState, T nextState) {
    print('Global: $refType changed from $currentState to $nextState');
  }

  @override
  void onDisposed(Type refType) {
    print('Global: $refType disposed');
  }
}

void main() {
  GlobalObserverManager().addObserver(observer);

  runApp(MyApp());
}
```
### **5. ReactiveWidget**
The `ReactiveWidget` rebuilds automatically when the associated `BaseRef` changes. It's perfect for binding your UI to reactive state without manually managing listeners.

```dart
import 'package:flutter/material.dart';

// Define a Ref for counter state
final counterRef = Ref<int>(0);

class ReactiveWidgetExample extends StatelessWidget {
  const ReactiveWidgetExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReactiveWidget Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Automatically rebuild when counterRef changes
            ReactiveWidget<int>(
              ref: counterRef,
              builder: (context, value) {
                return Text(
                  'Counter: $value',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Increment the counter value
                counterRef.update((prev) => prev + 1);
              },
              child: const Text('Increment'),
            ),
            ElevatedButton(
              onPressed: () {
                // Reset the counter value
                counterRef.update((_) => 0);
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
```
---

## **Testing**

The library provides test utilities to validate its state management capabilities.

Example test:

```dart
test('should transition from AsyncLoading to AsyncSuccess', () async {
  final ref = FutureRef<String>(() async {
    await Future.delayed(Duration(milliseconds: 100));
    return 'Hello, world!';
  });

  final List<AsyncValue<String>> states = [];
  ref.addListener((state) => states.add(state));

  expect(
    states,
    [
      isA<AsyncLoading<String>>(),
      isA<AsyncSuccess<String>>()
          .having((s) => s.data, 'data', 'Hello, world!'),
    ],
  );

  expect(ref.state, isA<AsyncSuccess<String>>());
  expect(ref.state.data, equals('Hello, world!'));
});
```

---

## **Contributing**

1. Fork the repository.
2. Create a new branch: `git checkout -b feature/my-feature`.
3. Make your changes and commit them: `git commit -m "Add my feature"`.
4. Push to the branch: `git push origin feature/my-feature`.
5. Open a pull request.

---

## **License**

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## **Contact**

For issues or feature requests, please open an issue on the repository.
