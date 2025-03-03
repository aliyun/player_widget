// Created with Android Studio
// User：keria
// Date：2021/6/29
// Email：runchen.brc@alibaba-inc.com
// Reference：A utility class for logging messages with different levels.

import 'package:flutter/foundation.dart';

/// 回调函数类型定义
typedef LogCallback = void Function(
  LogLevel level,
  String tag,
  String message,
);

/// 日志工具类
///
/// A utility class for logging.
class LogUtil {
  /// 默认日志标签
  static const String _defaultTag = "AliPlayerWidget";

  /// 是否开启调试模式
  static bool _debuggable = kDebugMode;

  /// 当前日志标签
  static String _currentTag = _defaultTag;

  /// 当前日志级别
  static LogLevel _logLevel = LogLevel.verbose;

  /// 日志级别简写映射表
  static const Map<LogLevel, String> _levelShortcuts = {
    LogLevel.verbose: "[V]",
    LogLevel.debug: "[D]",
    LogLevel.info: "[I]",
    LogLevel.warn: "[W]",
    LogLevel.error: "[E]",
  };

  /// 缓存的时间戳
  static String _cachedTimestamp = "";

  /// 上次更新时间戳的时间
  static int _lastTimestampUpdate = 0;

  /// 回调函数列表
  static final List<LogCallback> _callbacks = [];

  // 私有构造函数，防止实例化
  LogUtil._();

  /// 初始化日志工具类
  ///
  /// Initializes the log utility with optional debug mode, tag, and log level.
  /// This method can only be called once.
  static void init({
    bool isDebug = false,
    String tag = _defaultTag,
    LogLevel level = LogLevel.verbose,
  }) {
    _debuggable = isDebug;
    _currentTag = tag.isEmpty ? _defaultTag : tag;
    _logLevel = level;
  }

  /// 注册日志回调函数
  ///
  /// Registers a callback function to receive logs of specified levels.
  static void registerCallback(LogCallback callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
    }
  }

  /// 移除日志回调函数
  ///
  /// Removes a previously registered callback function.
  static void unregisterCallback(LogCallback callback) {
    _callbacks.remove(callback);
  }

  /// 移除所有日志回调函数
  ///
  /// Removes all previously registered callback functions.
  static void unregisterAllCallbacks() {
    _callbacks.clear();
  }

  /// 打印日志
  ///
  /// Prints a log message with the specified log level and tag.
  static void log(LogLevel level, Object object, {String tag = _defaultTag}) {
    if (!_debuggable || level.index < _logLevel.index) return;

    final logTag = tag.isEmpty ? _currentTag : tag;
    final timestamp = getCachedTimestamp();
    final levelShortcut = _levelShortcuts[level] ?? "[X]"; // 默认未知级别为 [X]

    String msg;
    if (levelShortcut == "[X]") {
      // 如果是未知级别，生成警告日志
      msg = "[$timestamp] [WARN] $logTag:-> Unknown log level encountered.";
      print(msg);

      // 调用回调函数，使用 LogLevel.warn 级别
      for (final callback in _callbacks) {
        callback(LogLevel.warn, logTag, msg);
      }
      return; // 直接返回，不再继续处理
    }

    // 正常日志处理
    msg = "[$timestamp] $levelShortcut $logTag:-> $object";
    print(msg);

    // 调用回调函数
    for (final callback in _callbacks) {
      callback(level, logTag, msg);
    }
  }

  /// 获取格式化后的时间戳（带缓存）
  ///
  /// Returns a cached timestamp updated every 100 milliseconds.
  static String getCachedTimestamp() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastTimestampUpdate > 100) {
      // 每 100 毫秒更新一次
      _cachedTimestamp = getFormattedTimestamp();
      _lastTimestampUpdate = now;
    }
    return _cachedTimestamp;
  }

  /// 获取格式化后的时间戳
  ///
  /// Get the formatted timestamp in the format "YYYY-MM-DD HH:mm:ss.SSS".
  static String getFormattedTimestamp() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final millisecond = now.millisecond.toString().padLeft(3, '0');
    return "$year-$month-$day $hour:$minute:$second.$millisecond";
  }

  /// 打印 Verbose 级别日志
  static void v(Object object, {String tag = _defaultTag}) {
    log(LogLevel.verbose, object, tag: tag);
  }

  /// 打印 Debug 级别日志
  static void d(Object object, {String tag = _defaultTag}) {
    log(LogLevel.debug, object, tag: tag);
  }

  /// 打印 Info 级别日志
  static void i(Object object, {String tag = _defaultTag}) {
    log(LogLevel.info, object, tag: tag);
  }

  /// 打印 Warn 级别日志
  static void w(Object object, {String tag = _defaultTag}) {
    log(LogLevel.warn, object, tag: tag);
  }

  /// 打印 Error 级别日志
  static void e(Object object, {String tag = _defaultTag}) {
    log(LogLevel.error, object, tag: tag);
  }
}

/// 打印 Verbose 级别日志
void logv(Object object, {String tag = LogUtil._defaultTag}) {
  LogUtil.v(object, tag: tag);
}

/// 打印 Debug 级别日志
void logd(Object object, {String tag = LogUtil._defaultTag}) {
  LogUtil.d(object, tag: tag);
}

/// 打印 Info 级别日志
void logi(Object object, {String tag = LogUtil._defaultTag}) {
  LogUtil.i(object, tag: tag);
}

/// 打印 Warn 级别日志
void logw(Object object, {String tag = LogUtil._defaultTag}) {
  LogUtil.w(object, tag: tag);
}

/// 打印 Error 级别日志
void loge(Object object, {String tag = LogUtil._defaultTag}) {
  LogUtil.e(object, tag: tag);
}

/// 日志级别枚举
///
/// An enumeration representing different log levels.
enum LogLevel {
  verbose, // 最详细的日志
  debug, // 调试信息
  info, // 普通信息
  warn, // 警告信息
  error, // 错误信息
}
