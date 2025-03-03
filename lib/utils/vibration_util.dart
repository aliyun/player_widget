// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/11
// Brief: 提供了用于控制设备振动的方法

import 'package:flutter/services.dart';
import 'dart:async';

import 'log_util.dart';

/// 震动工具类
///
/// 提供了用于控制设备振动的方法，例如振动控制
///
/// If you think the HapticFeedback vibration effect provided by Flutter native is not awesome,
/// we recommend you use the vibration third-party library to achieve it.
class VibrationUtil {
  /// 默认振动时长（毫秒）
  static const int defaultVibrationDuration = 500;

  /// 最小防抖间隔（毫秒）
  static const int defaultMinVibrationInterval = 300;

  /// 上次振动时间，用于防抖机制
  static DateTime? _lastVibrationTime;

  // 私有构造函数，防止实例化
  VibrationUtil._();

  /// 根据指定时长触发设备振动反馈
  ///
  /// [duration] 振动时长（单位：毫秒），默认值为 [defaultVibrationDuration]
  static void vibrate({int duration = defaultVibrationDuration}) async {
    try {
      final now = DateTime.now();

      // 防抖机制：控制两次振动之间的最小间隔
      if (_lastVibrationTime == null ||
          now.difference(_lastVibrationTime!) >=
              const Duration(milliseconds: defaultMinVibrationInterval)) {
        // 使用 HapticFeedback 模拟振动
        await _performHapticFeedback(duration);
        _lastVibrationTime = now;
      }
    } catch (e) {
      loge("Failed to execute haptic feedback: $e");
    }
  }

  /// 执行 HapticFeedback 振动操作
  ///
  /// [duration] 振动时长（单位：毫秒）
  static Future<void> _performHapticFeedback(int duration) async {
    // 计算需要触发的振动次数
    final int vibrationCount = (duration / 100).ceil(); // 每次振动约 100 毫秒

    for (int i = 0; i < vibrationCount; i++) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100)); // 控制振动间隔
    }
  }

  /// 边界振动反馈，带有防抖机制
  ///
  /// [value] 边界值，当值小于等于 0.0 或大于等于 1.0 时触发振动
  static void vibrateOnEdge(double value) {
    final now = DateTime.now();

    // 防抖机制：控制两次振动之间的最小间隔
    if ((_lastVibrationTime == null ||
            now.difference(_lastVibrationTime!) >=
                const Duration(milliseconds: defaultMinVibrationInterval)) &&
        (value <= 0.0 || value >= 1.0)) {
      HapticFeedback.heavyImpact();
      _lastVibrationTime = now;
    }
  }
}
