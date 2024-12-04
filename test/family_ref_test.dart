import 'package:ref/ref.dart';
import 'package:test/test.dart';

void main() {
  group('FamilyRef', () {
    test('should create and cache refs by key', () {
      final ref = FamilyRef<int, int>((key) => Ref(key * 2));

      final ref1 = ref(2);
      final ref2 = ref(2);
      final ref3 = ref(3);

      expect(ref1, equals(ref2)); // Cùng key trả về cùng một instance
      expect(ref1.state, equals(4)); // 2 * 2 = 4
      expect(ref3.state, equals(6)); // 3 * 2 = 6
    });

    test('should cleanup unused refs', () {
      final familyRef = FamilyRef<int, int>((key) => Ref(key * 2));

      familyRef(1);
      familyRef(2);

      familyRef.cleanup();

      expect(familyRef.refs.length, equals(2)); // Không có ref nào bị cleanup
    });
  });
}
