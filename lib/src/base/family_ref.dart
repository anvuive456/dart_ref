import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:ref/ref.dart';
import 'package:ref/src/base/observed_ref.dart';
import 'package:ref/src/observer/base_observer.dart';

class FamilyRef<Key, T> {
  final BaseRef<T> Function(Key key) create;
  final Map<Key, WeakReference<BaseRef<T>>> _refs = {};
  final List<BaseObserver<T>>? observers;
  FamilyRef(
    this.create, {
    this.observers,
  });

  @visibleForTesting
  Map<Key, WeakReference<BaseRef<T>>> get refs => _refs;

  BaseRef<T> call(Key key) {
    // Kiểm tra nếu đã tồn tại và còn sống
    final existingRef = _refs[key]?.target;

    cleanup();

    if (existingRef != null) {
      return existingRef;
    }

    // Nếu chưa tồn tại hoặc đã bị thu gom, tạo mới
    final ref = create(key);
    if (observers != null) {
      _refs[key] = WeakReference(ObservedRef<T>(ref, observers!));
    } else {
      _refs[key] = WeakReference(ref);
    }
    return ref;
  }

  /// Dọn dẹp các WeakReference đã bị null
  void cleanup() {
    _refs.removeWhere((_, weakRef) => weakRef.target == null);
  }

  /// Dispose toàn bộ Ref
  void dispose() {
    for (final weakRef in _refs.values) {
      weakRef.target?.dispose();
    }
    _refs.clear();
  }
}

FamilyRef<K, T> familyRef<K extends Object, T>(
  BaseRef<T> Function(K key) create, {
  List<BaseObserver<T>>? observers,
}) {
  return FamilyRef<K, T>(create, observers: observers);
}