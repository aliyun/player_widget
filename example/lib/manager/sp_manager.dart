// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/19
// Brief: SharedPreferences 管理工具类

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 管理工具类（单例模式）
/// 采用懒加载方式，无需显式初始化
class SPManager {
  // 私有构造函数，防止外部实例化
  SPManager._internal() {
    _initPrefs();
  }

  // 单例实例
  static final SPManager _instance = SPManager._internal();

  // 获取单例实例
  static SPManager get instance => _instance;

  // SharedPreferences 实例
  SharedPreferences? _prefs;

  // 初始化标志
  bool _initialized = false;

  // 等待初始化完成的Completer列表
  final List<Function(SharedPreferences)> _pendingCallbacks = [];

  // 初始化SharedPreferences
  void _initPrefs() {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      _initialized = true;

      // 处理等待中的回调
      for (var callback in _pendingCallbacks) {
        callback(prefs);
      }
      _pendingCallbacks.clear();
    });
  }

  // 获取SharedPreferences实例，确保已初始化
  void _ensureInitialized(Function(SharedPreferences) callback) {
    if (_initialized && _prefs != null) {
      callback(_prefs!);
    } else {
      _pendingCallbacks.add(callback);
      // 如果尚未开始初始化，则开始初始化
      if (_prefs == null && !_initialized && _pendingCallbacks.length == 1) {
        _initPrefs();
      }
    }
  }

  /// 保存 String 类型的值
  Future<bool> saveString(String key, String value) async {
    return _saveOperation((prefs) => prefs.setString(key, value));
  }

  /// 获取 String 类型的值
  String? getString(String key) {
    return _getOperation((prefs) => prefs.getString(key));
  }

  /// 保存 int 类型的值
  Future<bool> saveInt(String key, int value) async {
    return _saveOperation((prefs) => prefs.setInt(key, value));
  }

  /// 获取 int 类型的值
  int? getInt(String key) {
    return _getOperation((prefs) => prefs.getInt(key));
  }

  /// 保存 double 类型的值
  Future<bool> saveDouble(String key, double value) async {
    return _saveOperation((prefs) => prefs.setDouble(key, value));
  }

  /// 获取 double 类型的值
  double? getDouble(String key) {
    return _getOperation((prefs) => prefs.getDouble(key));
  }

  /// 保存 bool 类型的值
  Future<bool> saveBool(String key, bool value) async {
    return _saveOperation((prefs) => prefs.setBool(key, value));
  }

  /// 获取 bool 类型的值
  bool? getBool(String key) {
    return _getOperation((prefs) => prefs.getBool(key));
  }

  /// 保存 List<String> 类型的值
  Future<bool> saveStringList(String key, List<String> value) async {
    return _saveOperation((prefs) => prefs.setStringList(key, value));
  }

  /// 获取 List<String> 类型的值
  List<String>? getStringList(String key) {
    return _getOperation((prefs) => prefs.getStringList(key));
  }

  /// 删除指定 key 的值
  Future<bool> remove(String key) async {
    return _saveOperation((prefs) => prefs.remove(key));
  }

  /// 清空所有存储的数据
  Future<bool> clearAll() async {
    return _saveOperation((prefs) => prefs.clear());
  }

  // 通用保存操作
  Future<bool> _saveOperation(
    Future<bool> Function(SharedPreferences) operation,
  ) async {
    Completer<bool> completer = Completer<bool>();

    _ensureInitialized((prefs) async {
      try {
        bool result = await operation(prefs);
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  // 通用获取操作
  T? _getOperation<T>(T? Function(SharedPreferences) operation) {
    if (!_initialized || _prefs == null) {
      // 如果尚未初始化，启动初始化并返回null
      if (!_initialized) {
        _initPrefs();
      }
      return null;
    }

    try {
      return operation(_prefs!);
    } catch (e) {
      return null;
    }
  }
}
