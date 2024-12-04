import 'dart:async';

StreamTransformer<T, T> debounceTransformer<T>(
  Duration delay,
) {
  Timer? timer;

  return StreamTransformer<T, T>.fromHandlers(
    handleData: (data, sink) {
      if (timer?.isActive ?? false) {
        timer?.cancel();
      }
      timer = Timer(delay, () {
        sink.add(data);
      });
    },
  );
}
