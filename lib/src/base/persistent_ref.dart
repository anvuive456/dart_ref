import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ref/src/base/base_ref.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Một ref lưu trữ state vào local storage
///
/// [PersistentRef] tự động lưu state vào SharedPreferences khi state thay đổi
/// và khôi phục state khi khởi tạo.
///
/// Ví dụ:
/// ```dart
/// final counterRef = persistentRef<int>(
///   'counter',
///   0,
///   serializer: (value) => value.toString(),
///   deserializer: (value) => int.parse(value),
/// );
///
/// // State sẽ được lưu vào SharedPreferences khi thay đổi
/// counterRef.state = 1;
///
/// // State sẽ được khôi phục khi khởi động lại ứng dụng
/// ```
class PersistentRef<T> extends BaseRef<T> {
  /// Key để lưu trữ state trong SharedPreferences
  final String key;
  
  /// Hàm chuyển đổi state thành String để lưu trữ
  final String Function(T value) _serializer;
  
  /// Hàm chuyển đổi String thành state khi khôi phục
  final T Function(String value) _deserializer;
  
  /// Instance của SharedPreferences
  SharedPreferences? _prefs;
  
  /// Khởi tạo PersistentRef với key và giá trị mặc định
  ///
  /// [key] là key để lưu trữ state trong SharedPreferences
  /// [defaultValue] là giá trị mặc định khi không tìm thấy state đã lưu
  /// [serializer] là hàm chuyển đổi state thành String để lưu trữ
  /// [deserializer] là hàm chuyển đổi String thành state khi khôi phục
  PersistentRef(
    this.key,
    T defaultValue, {
    String Function(T value)? serializer,
    T Function(String value)? deserializer,
  })  : _serializer = serializer ?? _defaultSerializer<T>(),
        _deserializer = deserializer ?? _defaultDeserializer<T>(),
        super(defaultValue) {
    _init();
  }

  /// Khởi tạo SharedPreferences và khôi phục state
  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final storedValue = _prefs!.getString(key);
      if (storedValue != null) {
        state = _deserializer(storedValue);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing PersistentRef: $e');
      }
    }
  }

  @override
  set state(T newState) {
    super.state = newState;
    _saveState();
  }

  /// Lưu state vào SharedPreferences
  Future<void> _saveState() async {
    try {
      if (_prefs != null) {
        final serialized = _serializer(state);
        await _prefs!.setString(key, serialized);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving state: $e');
      }
    }
  }

  /// Xóa state đã lưu
  Future<void> clearPersistedState() async {
    try {
      if (_prefs != null) {
        await _prefs!.remove(key);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing state: $e');
      }
    }
  }
}

/// Tạo một PersistentRef với key và giá trị mặc định
///
/// [key] là key để lưu trữ state trong SharedPreferences
/// [defaultValue] là giá trị mặc định khi không tìm thấy state đã lưu
/// [serializer] là hàm chuyển đổi state thành String để lưu trữ
/// [deserializer] là hàm chuyển đổi String thành state khi khôi phục
PersistentRef<T> persistentRef<T>(
  String key,
  T defaultValue, {
  String Function(T value)? serializer,
  T Function(String value)? deserializer,
}) {
  return PersistentRef<T>(
    key,
    defaultValue,
    serializer: serializer,
    deserializer: deserializer,
  );
}

/// Hàm chuyển đổi mặc định cho các kiểu dữ liệu cơ bản
String Function(T value) _defaultSerializer<T>() {
  return (T value) {
    if (value is int || value is double || value is bool || value is String) {
      return value.toString();
    } else if (value is List || value is Map) {
      return jsonEncode(value);
    } else {
      throw UnsupportedError(
        'Type $T is not supported by default serializer. Please provide a custom serializer.',
      );
    }
  };
}

/// Hàm chuyển đổi mặc định cho các kiểu dữ liệu cơ bản
T Function(String value) _defaultDeserializer<T>() {
  return (String value) {
    if (T == int) {
      return int.parse(value) as T;
    } else if (T == double) {
      return double.parse(value) as T;
    } else if (T == bool) {
      return (value.toLowerCase() == 'true') as T;
    } else if (T == String) {
      return value as T;
    } else if (T == List || T == Map) {
      return jsonDecode(value) as T;
    } else {
      throw UnsupportedError(
        'Type $T is not supported by default deserializer. Please provide a custom deserializer.',
      );
    }
  };
}
