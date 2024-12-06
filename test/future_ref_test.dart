import 'package:ref/ref.dart';
import 'package:test/test.dart';

void main() {
  group('FutureRef', () {
    test('should transition from AsyncLoading to AsyncSuccess', () async {
      final ref = FutureRef<String>(() async {
        await Future.delayed(Duration(milliseconds: 100));
        return 'Hello, world!';
      });

      final List<AsyncValue<String>> states = [];
      ref.addListener((state) => states.add(state));

      // Chờ cho FutureRef hoàn tất
      await Future.delayed(Duration(milliseconds: 200));

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

    test('should transition from AsyncLoading to AsyncError on failure',
        () async {
      final ref = FutureRef<String>(() async {
        throw 'Failed';
      });

      final List<AsyncValue<String>> states = [];
      ref.addListener((state) => states.add(state));

      // Chờ cho FutureRef hoàn tất
      await Future.delayed(Duration(milliseconds: 100));

      expect(
        states,
        [
          isA<AsyncLoading<String>>(),
          isA<AsyncError<String>>().having((e) => e.error, 'error', 'Failed'),
        ],
      );

      expect(ref.state, isA<AsyncError<String>>());
      expect(ref.state.error, equals('Failed'));
    });
  });
}
