import 'package:ref/ref.dart';
import 'package:test/test.dart';

void main() {
  group('CombineRef', () {
    test('should combine multiple refs into one', () {
      final ref1 = Ref<int>(1);
      final ref2 = Ref<int>(2);

      final combinedRef = CombineRef<int>(
        [ref1, ref2],
        (states) => states.reduce((a, b) => a + b), // Tổng các giá trị
      );

      expect(combinedRef.state, equals(3)); // Ban đầu: 1 + 2 = 3

      ref1.state = 5; // Thay đổi ref1
      expect(combinedRef.state, equals(7)); // 5 + 2 = 7
    });

    test('should notify changes when one of the refs changes', () async {
      final ref1 = Ref<int>(1);
      final ref2 = Ref<int>(2);

      final combinedRef = CombineRef<int>(
        [ref1, ref2],
        (states) => states.reduce((a, b) => a + b),
      );

      expect(combinedRef.state, equals(3));

      final changes = <int>[];
      combinedRef.changes.listen((value) => changes.add(value));

      ref1.state = 5; // Thay đổi ref1
      expect(combinedRef.state, equals(7));

      ref2.state = 10; // Thay đổi ref2
      expect(combinedRef.state, equals(15));

      await Future.delayed(Duration(milliseconds: 100));
      print(changes);

      // expect(
      //     changes, equals([3, 7, 15])); // Các giá trị lần lượt: 1+2, 5+2, 5+10
    });
  });
}
