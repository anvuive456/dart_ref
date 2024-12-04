import 'package:async/async.dart';
import 'package:ref/ref.dart';
import 'package:test/test.dart';

void main() {
  group('FutureRef', () {
    // test('FutureRef emits AsyncLoading first', () async {
    //   final futureRef = FutureRef<String>(() async {
    //     await Future.delayed(Duration(milliseconds: 100));
    //     return 'Result';
    //   });

    //   await expectLater(
    //     futureRef.changes,
    //     emitsThrough(AsyncLoading<String>()),
    //   );
    // });
    test('should emit AsyncLoading and AsyncSuccess', () async {
      final ref = FutureRef<String>(() async {
        await Future.delayed(Duration(seconds: 2));
        return 'Hello, world!';
      });

      await expectLater(
        ref.changes,
        emitsInOrder([
          isA<AsyncLoading<String>>(),
          isA<AsyncSuccess<String>>(),
        ]),
      );

      expect(ref.state.data, equals('Hello, world!'));
    });

    test('should emit AsyncError on failure', () async {
      final ref = FutureRef<String>(() async {
        throw 'Failed';
      });

      await expectLater(
        ref.changes,
        emitsInOrder([
          isA<AsyncLoading<String>>(),
          isA<AsyncError<String>>(),
        ]),
      );

      expect(ref.state.error, equals('Failed'));
    });
  });
}
