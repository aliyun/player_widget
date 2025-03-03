// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/17
// Brief: 颜色工具类

import 'dart:math';

import 'package:flutter/material.dart';

/// 颜色工具类
/// Color Utility Class
///
/// 提供获取 Material Design 颜色的工具方法。
class ColorUtil {
  // 私有构造函数，防止实例化
  ColorUtil._();

  /// 获取 Material Design 颜色
  /// Get Material Design color
  ///
  /// 如果传入了 [index]，则返回对应索引的颜色；
  /// 如果未传入 [index]，则返回随机颜色。
  ///
  /// 索引范围为 [0, Colors.primaries.length - 1]，
  /// 超出范围的索引会被自动调整到有效范围内。
  static MaterialColor getMaterialColor({int? index}) {
    if (index != null) {
      // Ensure the index is within valid range
      index = index.clamp(0, Colors.primaries.length - 1);
      return Colors.primaries[index];
    } else {
      // Return a random color
      return Colors.primaries[_random.nextInt(Colors.primaries.length)];
    }
  }

  /// 随机数生成器
  ///
  /// Random number generator
  static final Random _random = Random();
}
