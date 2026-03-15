import 'package:flutter/material.dart';
import 'package:ref/ref.dart';

// Định nghĩa model
class User {
  final String name;
  final int age;

  const User({required this.name, required this.age});

  User copyWith({String? name, int? age}) {
    return User(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.name == name && other.age == age;
  }

  @override
  int get hashCode => name.hashCode ^ age.hashCode;

  @override
  String toString() => 'User(name: $name, age: $age)';
}

// Tạo các ref nguồn
final nameRef = ref('John');
final ageRef = ref(30);

// computedRef tự động phát hiện dependency vào nameRef và ageRef
final userRef = computedRef<User>(
  () => User(name: nameRef.state, age: ageRef.state),
);

// Sử dụng select để chỉ lắng nghe một phần của state
final userNameRef = userRef.select((user) => user.name);
final userAgeRef = userRef.select((user) => user.age);

// Sử dụng effectRef để xử lý side effects
final userEffectRef = effectRef(userRef);

class ImprovedExample extends StatefulWidget {
  const ImprovedExample({super.key});

  @override
  State<ImprovedExample> createState() => _ImprovedExampleState();
}

class _ImprovedExampleState extends State<ImprovedExample> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  late final void Function() _disposeEffect;

  @override
  void initState() {
    super.initState();
    nameController.text = nameRef.state;
    ageController.text = ageRef.state.toString();

    // Đăng ký effect và lưu hàm dispose
    _disposeEffect = userRef.effect((user) {
      print('User changed: $user');
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    _disposeEffect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Improved Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RefProvider<User>(
              ref: userRef,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('User Info (using RefConsumer):'),
                  RefConsumer<User>(
                    builder: (context, user) {
                      return Text(
                        'Name: ${user.name}, Age: ${user.age}',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Text('Name (using ReactiveWidget with select):'),
            ReactiveWidget(
              ref: userNameRef,
              builder: (context, name) {
                return Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 10),
            const Text('Age (using ReactiveWidget with select):'),
            ReactiveWidget(
              ref: userAgeRef,
              builder: (context, age) {
                return Text(
                  age.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                nameRef.state = value;
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final age = int.tryParse(value) ?? 0;
                ageRef.state = age;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Cập nhật các ref nguồn — userRef sẽ tự động recompute
                nameRef.state = 'Alice';
                ageRef.state = 25;
                nameController.text = 'Alice';
                ageController.text = '25';
              },
              child: const Text('Reset to Default'),
            ),
          ],
        ),
      ),
    );
  }
}
