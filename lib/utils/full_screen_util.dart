// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 播放器全屏切换工具类

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 播放器全屏切换工具类
class FullScreenUtil {
  // 私有构造函数，防止实例化
  FullScreenUtil._();

  /// 进入全屏模式
  static Future<void> enterFullScreen() async {
    // 如果已经是全屏模式，则直接返回
    if (isFullScreen()) return;

    // 隐藏状态栏和导航栏
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 锁定屏幕方向为横屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // 左横屏
      DeviceOrientation.landscapeRight, // 右横屏
    ]);
  }

  /// 退出全屏模式
  static Future<void> exitFullScreen() async {
    // 如果已经不是全屏模式，则直接返回
    if (!isFullScreen()) return;

    // 恢复状态栏和导航栏
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // 解锁屏幕方向，恢复为竖屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // 正常竖屏
      DeviceOrientation.portraitDown, // 倒置竖屏
    ]);
  }

  /// 切换全屏模式（自动在全屏和非全屏之间切换）
  static Future<void> toggleFullScreen() async {
    if (isFullScreen()) {
      await exitFullScreen();
    } else {
      await enterFullScreen();
    }
  }

  /// 获取当前屏幕方向
  static Orientation _getCurrentOrientation() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return MediaQueryData.fromView(view).orientation;
  }

  /// 实时获取当前是否为全屏模式
  static bool isFullScreen() {
    // 获取当前屏幕方向
    final orientation = _getCurrentOrientation();
    // 全屏模式通常对应横屏方向
    return orientation == Orientation.landscape;
  }
}
