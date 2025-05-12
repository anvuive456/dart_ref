# **State Management Library for Dart/Flutter**

## **Tổng quan**

Thư viện này cung cấp một giải pháp quản lý state nhỏ gọn và hiệu quả cho các ứng dụng Dart và Flutter. Nó cho phép các nhà phát triển xử lý trạng thái ứng dụng một cách chính xác, cung cấp các tính năng như `Ref`, `TransformRef`, `CombineRef`, `ReadonlyRef`, `PersistentRef`, `ReplayRef` và nhiều hơn nữa. Nó cũng tích hợp cơ chế observer mạnh mẽ để theo dõi các thay đổi state toàn cục hoặc cục bộ.

---

## **Tính năng**

### **Tính năng cốt lõi**

- **BaseRef**: Lớp nền tảng cho quản lý state, cung cấp listeners và theo dõi state.
- **TransformRef**: Cho phép biến đổi thông báo thay đổi state bằng các transformer tùy chỉnh.
- **CombineRef**: Kết hợp nhiều đối tượng `Ref` và tính toán state mới dựa trên sự thay đổi của chúng.
- **ReadonlyRef**: Cho phép tạo ra các state dẫn xuất mà không sửa đổi state gốc.
- **FutureRef**: Xử lý các hoạt động bất đồng bộ với theo dõi state tích hợp (`AsyncLoading`, `AsyncSuccess`, `AsyncError`).
- **PersistentRef**: Tự động lưu state vào local storage và khôi phục khi khởi động lại ứng dụng.
- **ReplayRef**: Lưu trữ lịch sử các state và cho phép undo/redo.

### **Cơ chế Observer**

- **Local Observers**: Theo dõi các thay đổi trong các đối tượng `Ref` riêng lẻ.
- **Global Observers**: Giám sát tất cả các instance `Ref` trong toàn bộ ứng dụng để debug hoặc phân tích.

### **Biến đổi State nâng cao**

- Hỗ trợ các biến đổi state như debounce, throttle, middleware và replay thông qua `TransformRef`.
- Thiết kế lớp transformer linh hoạt cho logic quản lý state tùy chỉnh.

### **Provider Pattern**

- **RefProvider**: Cung cấp ref cho widget tree.
- **RefConsumer**: Tiêu thụ ref từ widget tree.
- **MultiRefProvider**: Cung cấp nhiều ref cho widget tree.

### **Side Effects**

- **EffectRef**: Xử lý side effects khi state thay đổi.
- **Effect Extension**: Thêm effect vào bất kỳ ref nào.

---

## **Cài đặt**

Thêm package vào file `pubspec.yaml` của bạn:

```yaml
dependencies:
  ref:
    git:
      url: https://github.com/anvuive456/dart_ref
```

Sau đó, chạy:

```bash
flutter pub get
```

---

## **Sử dụng**

### **1. Basic Ref**

```dart
final counter = ref(0);

counter.addListener((state) {
  print('Counter updated: $state');
});

counter.state = 1; // Notify listener: "Counter updated: 1"
```

### **2. TransformRef với Debounce**

```dart
final counter = ref(0);
final debounceRef = transformRef<int>(
  counter,
  debounceTransformer(Duration(milliseconds: 500)),
);

debounceRef.addListener((state) {
  print('Debounced counter: $state');
});

counter.state = 1; // Sau 500ms: "Debounced counter: 1"
```

### **3. CombineRef**

```dart
final nameRef = ref('John');
final ageRef = ref(30);

final personRef = combine2Refs<String, int, Map<String, dynamic>>(
  nameRef,
  ageRef,
  (name, age) => {'name': name, 'age': age},
);

personRef.addListener((state) {
  print('Person: $state'); // Outputs: "Person: {name: John, age: 30}"
});

nameRef.state = 'Alice'; // Outputs: "Person: {name: Alice, age: 30}"
```

### **4. PersistentRef**

```dart
final counterRef = persistentRef<int>(
  'counter',
  0,
);

// State sẽ được lưu vào SharedPreferences khi thay đổi
counterRef.state = 1;

// State sẽ được khôi phục khi khởi động lại ứng dụng
```

### **5. ReplayRef**

```dart
final counterRef = replayRef(0, historyLimit: 10);

// Thay đổi state
counterRef.state = 1;
counterRef.state = 2;

// Undo về state trước đó
counterRef.undo(); // state = 1

// Redo về state sau đó
counterRef.redo(); // state = 2
```

### **6. TransformRef với Middleware**

```dart
final counterRef = transformRef<int>(
  ref(0),
  middlewareTransformer<int>([
    // Middleware 1: Ghi log
    (state, nextState, next) {
      print('State changing from $state to $nextState');
      next(nextState); // Cho phép state đi qua
      return null;
    },
    // Middleware 2: Chỉ cho phép số dương
    (state, nextState, next) {
      if (nextState < 0) {
        print('Negative value not allowed');
        return 0; // Giới hạn giá trị nhỏ nhất là 0
      }
      next(nextState); // Cho phép state đi qua
      return null;
    },
  ]),
);

counterRef.state = 1; // OK
counterRef.state = -1; // Sẽ bị giới hạn thành 0
```

### **7. Effect**

```dart
final counterRef = ref(0);

// Đăng ký effect
final disposeEffect = counterRef.effect((state) {
  print('Counter changed: $state');
  // Có thể thực hiện các side effect khác ở đây
  // Ví dụ: lưu vào local storage, gọi API, v.v.
});

counterRef.state = 1; // In ra: "Counter changed: 1"

// Hủy effect khi không cần nữa
disposeEffect();
```

### **8. Provider Pattern**

```dart
// Trong widget tree
return RefProvider<int>(
  ref: counterRef,
  child: Builder(
    builder: (context) {
      // Sử dụng RefConsumer để tiêu thụ ref
      return RefConsumer<int>(
        builder: (context, state) {
          return Text('Counter: $state');
        },
      );
    },
  ),
);
```

### **9. Global Observer**

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
  GlobalObserverManager().addObserver(MyGlobalObserver());

  runApp(MyApp());
}
```

### **10. ReactiveWidget**

`ReactiveWidget` tự động rebuild khi `BaseRef` liên kết thay đổi. Nó hoàn hảo để liên kết UI với state mà không cần quản lý listeners thủ công.

```dart
import 'package:flutter/material.dart';

// Định nghĩa một Ref cho state counter
final counterRef = ref(0);

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
            // Tự động rebuild khi counterRef thay đổi
            ReactiveWidget<int>(
              ref: counterRef,
              builder: (context, value) {
                return Text(
                  'Counter: $value',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Tăng giá trị counter
                counterRef.update((prev) => prev + 1);
              },
              child: const Text('Tăng'),
            ),
            ElevatedButton(
              onPressed: () {
                // Reset giá trị counter
                counterRef.update((_) => 0);
              },
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
```

---

## **Testing**

Thư viện cung cấp các tiện ích test để xác thực khả năng quản lý state.

Ví dụ test:

```dart
test('should transition from AsyncLoading to AsyncSuccess', () async {
  final ref = futureRef<String>(() async {
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

## **Đóng góp**

Đóng góp luôn được chào đón! Nếu bạn tìm thấy lỗi hoặc có ý tưởng cải thiện, vui lòng tạo issue hoặc pull request.
