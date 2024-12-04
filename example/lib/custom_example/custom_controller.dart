import 'package:ref/ref.dart';

class CustomState {
  final bool loading;
  final int value;

  const CustomState({
    this.loading = true,
    this.value = 0,
  });

  CustomState copyWith({bool? loading, int? value}) {
    return CustomState(
      loading: loading ?? this.loading,
      value: value ?? this.value,
    );
  }
}

class CustomController extends Ref<CustomState> {
  CustomController()
      : super(
          const CustomState(),
        );

  void increase() async {
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(
      loading: false,
      value: state.value + 1,
    );
  }
}

final customController = CustomController();
