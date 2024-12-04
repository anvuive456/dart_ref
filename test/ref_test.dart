import 'package:ref/ref.dart';
import 'package:test/test.dart';

void main() {
  group('Test Ref', () {
    late Ref<int> count;
    setUp(() {
      count = ref(0);
    });

    test('Count increase', () {
      expect(count.state, equals(0));
      count.update((prev) => prev + 1);
      expect(count.state > 0, isTrue);
    });

    test('Count changes', () async {
      expectLater(
        count.changes,
        emitsInOrder([5, 10]), // Kiểm tra tuần tự mà không cần delay
      );

      count.state = 5;
      count.state = 10;
    });
  });
}
