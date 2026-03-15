import 'package:ref/ref.dart';
import 'package:test/test.dart';

void main() {
  group('ComputedRef', () {
    test('tính toán giá trị ban đầu từ dependency', () {
      final a = Ref<int>(1);
      final b = Ref<int>(2);

      final sum = ComputedRef<int>(() => a.state + b.state);

      expect(sum.state, equals(3));
    });

    test('tự động cập nhật khi dependency thay đổi', () {
      final a = Ref<int>(1);

      final doubled = ComputedRef<int>(() => a.state * 2);
      expect(doubled.state, equals(2));

      a.state = 5;
      expect(doubled.state, equals(10));
    });

    test('theo dõi nhiều dependency', () {
      final a = Ref<int>(1);
      final b = Ref<int>(2);

      final sum = ComputedRef<int>(() => a.state + b.state);

      a.state = 3;
      expect(sum.state, equals(5));

      b.state = 4;
      expect(sum.state, equals(7));
    });

    test('thông báo listener khi tính lại giá trị', () {
      final a = Ref<int>(0);
      final doubled = ComputedRef<int>(() => a.state * 2);

      final values = <int>[];
      doubled.addListener(values.add, name: 'test');

      a.state = 1;
      a.state = 2;

      // listener nhận giá trị ban đầu + 2 lần cập nhật
      expect(values, equals([0, 2, 4]));
    });

    test('factory function computedRef hoạt động đúng', () {
      final count = ref(5);
      final label = computedRef(() => 'Count: ${count.state}');

      expect(label.state, equals('Count: 5'));

      count.state = 10;
      expect(label.state, equals('Count: 10'));
    });

    test('hỗ trợ conditional dependency', () {
      final flag = Ref<bool>(true);
      final a = Ref<int>(1);
      final b = Ref<int>(100);

      final result = ComputedRef<int>(() => flag.state ? a.state : b.state);
      expect(result.state, equals(1));

      // Thay đổi b khi flag=true → b không phải dependency → không recompute
      b.state = 200;
      expect(result.state, equals(1));

      // Thay đổi flag → b trở thành dependency
      flag.state = false;
      expect(result.state, equals(200));

      // Bây giờ b là dependency
      b.state = 300;
      expect(result.state, equals(300));
    });

    test('chuỗi computed (computed phụ thuộc computed)', () {
      final base = Ref<int>(2);
      final doubled = ComputedRef<int>(() => base.state * 2);
      final quadrupled = ComputedRef<int>(() => doubled.state * 2);

      expect(quadrupled.state, equals(8));

      base.state = 3;
      expect(doubled.state, equals(6));
      expect(quadrupled.state, equals(12));
    });

    test('dispose dọn dẹp dependency', () {
      final a = Ref<int>(1);
      final computed = ComputedRef<int>(() => a.state);

      computed.dispose();

      // Sau dispose, thay đổi a không gây lỗi và computed giữ giá trị cũ
      a.state = 99;
      expect(computed.state, equals(1));
    });

    test('không thông báo listener khi giá trị không đổi', () {
      final a = Ref<int>(5);
      final same = ComputedRef<int>(() => a.state);

      final values = <int>[];
      same.addListener(values.add, name: 'test');
      final countBefore = values.length;

      a.state = 5; // giá trị giống → shouldUpdate = false → không notify listener
      expect(values.length, equals(countBefore));
      expect(same.state, equals(5));
    });
  });
}
