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
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      _prefsCompleter.complete(prefs);
    });
  }

  // 单例实例
  static final SPManager _instance = SPManager._internal();

  // 获取单例实例
  static SPManager get instance => _instance;

  // 异步初始化完成信号，供写操作等待
  final Completer<SharedPreferences> _prefsCompleter = Completer();

  // 初始化完成后缓存实例，供同步读操作直接使用
  SharedPreferences? _prefs;

  /// 保存 String 类型的值
  Future<bool> saveString(String key, String value) =>
      _saveOperation((prefs) => prefs.setString(key, value));

  /// 获取 String 类型的值
  String? getString(String key) =>
      _getOperation((prefs) => prefs.getString(key));

  /// 保存 int 类型的值
  Future<bool> saveInt(String key, int value) =>
      _saveOperation((prefs) => prefs.setInt(key, value));

  /// 获取 int 类型的值
  int? getInt(String key) => _getOperation((prefs) => prefs.getInt(key));

  /// 保存 double 类型的值
  Future<bool> saveDouble(String key, double value) =>
      _saveOperation((prefs) => prefs.setDouble(key, value));

  /// 获取 double 类型的值
  double? getDouble(String key) =>
      _getOperation((prefs) => prefs.getDouble(key));

  /// 保存 bool 类型的值
  Future<bool> saveBool(String key, bool value) =>
      _saveOperation((prefs) => prefs.setBool(key, value));

  /// 获取 bool 类型的值
  bool? getBool(String key) => _getOperation((prefs) => prefs.getBool(key));

  /// 保存 List<String> 类型的值
  Future<bool> saveStringList(String key, List<String> value) =>
      _saveOperation((prefs) => prefs.setStringList(key, value));

  /// 获取 List<String> 类型的值
  List<String>? getStringList(String key) =>
      _getOperation((prefs) => prefs.getStringList(key));

  /// 删除指定 key 的值
  Future<bool> remove(String key) =>
      _saveOperation((prefs) => prefs.remove(key));

  /// 清空所有存储的数据
  Future<bool> clearAll() => _saveOperation((prefs) => prefs.clear());

  // 通用异步写操作：等待初始化完成后执行
  Future<bool> _saveOperation(
    Future<bool> Function(SharedPreferences) operation,
  ) async {
    final prefs = await _prefsCompleter.future;
    return operation(prefs);
  }

  // 通用同步读操作：未初始化时返回 null
  T? _getOperation<T>(T? Function(SharedPreferences) operation) {
    final prefs = _prefs;
    if (prefs == null) return null;
    try {
      return operation(prefs);
    } catch (e) {
      return null;
    }
  }
}
