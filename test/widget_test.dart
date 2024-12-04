import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ref/ref.dart';

void main() {
  testWidgets('should rebuild widget only when state changes',
      (WidgetTester tester) async {
    // Một biến đếm số lần rebuild
    int rebuildCount = 0;

    final ref = Ref<int>(0);

    // Định nghĩa một widget lắng nghe ref.state và tăng biến đếm rebuild
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

    // Cập nhật state lần 1
    ref.state = 1;
    await tester.pumpAndSettle(); // Đảm bảo UI được cập nhật

    // Kiểm tra xem đã rebuild một lần
    expect(rebuildCount, equals(2));

    // Cập nhật state lần 2
    ref.state = 2;
    await tester.pumpAndSettle(); // Đảm bảo UI được cập nhật

    // Kiểm tra xem đã rebuild thêm một lần nữa
    expect(rebuildCount, equals(3));
  });
}
