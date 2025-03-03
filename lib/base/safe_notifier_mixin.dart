// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/25
// Brief: 提供安全的通知和资源释放方法的混入类

import 'package:flutter/material.dart';

import 'package:aliplayer_widget/utils/log_util.dart';

/// A mixin that provides safe notification and disposal methods for ChangeNotifier.
///
/// 提供安全的通知和资源释放方法的混入类。
mixin SafeNotifierMixin on ChangeNotifier {
  // Tag for logging purposes.
  static const String _tag = "SafeNotifierMixin";

  // Whether the notifier has been disposed.
  bool _isDisposed = false;

  /// Whether the notifier has been disposed.
  ///
  /// 当前通知器是否已被释放。
  bool get isDisposed => _isDisposed;

  /// Check if the notifier is disposed and log a warning if it is.
  ///
  /// 检查通知器是否已被释放，并在已释放时输出警告日志。
  bool _checkDisposed() {
    if (_isDisposed) {
      // Log a warning message when attempting to interact with a disposed notifier.
      logw("Attempted to interact with a disposed notifier.", tag: _tag);
    }
    return _isDisposed;
  }

  /// Check if the notifier has listeners and log a warning if it does.
  ///
  /// 检查通知器是否有监听器。
  @override
  bool get hasListeners {
    // Only return true if the notifier is not disposed and has listeners.
    return !_checkDisposed() && super.hasListeners;
  }

  /// Safely notify listeners if the notifier is not disposed.
  ///
  /// 如果通知器未被释放，则安全地通知监听器。
  @override
  void notifyListeners() {
    if (!_checkDisposed()) {
      super.notifyListeners();
    }
  }

  /// Safely add a listener if the notifier is not disposed.
  ///
  /// 如果通知器未被释放，则安全地添加监听器。
  @override
  void addListener(VoidCallback listener) {
    if (!_checkDisposed()) {
      super.addListener(listener);
    }
  }

  /// Safely remove a listener if the notifier is not disposed.
  ///
  /// 如果通知器未被释放，则安全地移除监听器。
  @override
  void removeListener(VoidCallback listener) {
    if (!_checkDisposed()) {
      super.removeListener(listener);
    }
  }

  /// Mark the notifier as disposed and release resources.
  ///
  /// 标记通知器为已释放并释放相关资源。
  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      super.dispose();
    } else {
      logw("Attempted to dispose an already disposed notifier.", tag: _tag);
    }
  }
}
