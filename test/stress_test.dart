import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref/ref.dart';

main() {
  testWidgets('stress test state changes and rebuilds',
      (WidgetTester tester) async {
    final ref = Ref<int>(0);
    int rebuildCount = 0;

    // Định nghĩa một widget mà sẽ rebuild mỗi khi có sự thay đổi state
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReactiveWidget<int>(
            ref: ref,
            builder: (context, state) {
              rebuildCount++;
              return Text(state.toString());
            },
          ),
        ),
      ),
    );

    // Thực hiện stress test với 10,000 thay đổi trạng thái
    for (int i = 1; i <= 10000; i++) {
      ref.state = i;
      await tester.pumpAndSettle();
    }

    // Kiểm tra xem số lần rebuild có phải là 10001 không (bao gồm lần build đầu tiên)
    expect(rebuildCount, 10001);
  });
}
