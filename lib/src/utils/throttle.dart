import 'package:ref/src/transformer/state_transformer.dart';
import 'package:ref/src/transformer/throttle_transformer.dart';

StateTransformer<T> debounceTransformer<T>(
  Duration duration,
) {
  return ThrottleTransformer(duration);
}
