import 'package:ref/src/transformer/debounce_transformer.dart';
import 'package:ref/src/transformer/state_transformer.dart';

StateTransformer<T> debounceTransformer<T>(
  Duration delay,
) {
  return DebounceTransformer(delay);
}
