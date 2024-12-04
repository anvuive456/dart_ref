import 'package:logger/logger.dart';
import 'package:ref/src/observer/base_observer.dart';

class LogObserver extends BaseObserver {
  final logger = Logger(
    filter: DevelopmentFilter(),
  );
  @override
  void onDisposed(Type refType) {
    logger.f('$refType disposed');
  }

  @override
  void onStateChanged(Type refType, currentState, nextState) {
    if (currentState != nextState) {
      logger.w(
        '$refType: state has not changed but rebuilt. Current state: $currentState, next state: $nextState',
      );
      return;
    }
    logger.i('$refType: state changed from $currentState to $nextState');
  }
}
