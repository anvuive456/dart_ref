import 'package:ref/src/base/base_ref.dart';

typedef EffectCallback<T> = void Function(T state);

/// Một ref để xử lý side effects khi state thay đổi
class EffectRef<T> extends BaseRef<T> {
  final BaseRef<T> _source;
  final List<EffectCallback<T>> _effects = [];
  final String _scopeId = Object().hashCode.toString();

  EffectRef(this._source) : super(_source.state) {
    // Lắng nghe sự thay đổi từ source
    _source.addListener(
      (newState) {
        // Cập nhật state
        state = newState;
        // Chạy các effect
        _runEffects(newState);
      },
      name: _scopeId,
    );
  }

  /// Thêm một effect callback
  void addEffect(EffectCallback<T> effect) {
    _effects.add(effect);
    // Chạy effect ngay lập tức với state hiện tại
    effect(state);
  }

  /// Xóa một effect callback
  void removeEffect(EffectCallback<T> effect) {
    _effects.remove(effect);
  }

  /// Chạy tất cả các effect với state mới
  void _runEffects(T state) {
    for (final effect in _effects) {
      effect(state);
    }
  }

  @override
  set state(T newState) {
    // Cập nhật state của source
    _source.state = newState;
    // State của EffectRef sẽ được cập nhật thông qua listener
  }

  @override
  void dispose() {
    _source.removeListener(_scopeId);
    _effects.clear();
    super.dispose();
  }
}

/// Tạo một EffectRef từ một ref
EffectRef<T> effectRef<T>(BaseRef<T> source) {
  return EffectRef<T>(source);
}

/// Extension để thêm effect vào ref
extension EffectExtension<T> on BaseRef<T> {
  /// Thêm một effect callback và trả về một function để xóa effect
  void Function() effect(EffectCallback<T> effect) {
    final effectRef = EffectRef<T>(this);
    effectRef.addEffect(effect);
    return () => effectRef.removeEffect(effect);
  }
}
