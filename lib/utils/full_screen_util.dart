// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 播放器全屏切换工具类

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'orientation_util.dart';

/// 播放器全屏切换工具类
class FullScreenUtil {
  // 私有构造函数，防止实例化
  FullScreenUtil._();

  /// 进入全屏模式
  ///
  /// 使用 fire-and-forget 模式（不 await），
  /// 先锁定横屏方向再隐藏系统 UI，使用 SystemUiMode.manual 兼容旧 iOS。
  static void enterFullScreen() {
    // 如果已经是全屏模式，则直接返回
    if (isFullScreen()) return;

    // 先锁定屏幕方向为横屏（优先级高于系统UI）
    OrientationUtil.switchToLandscape();

    // 隐藏状态栏和导航栏（使用 manual 模式，兼容旧 iOS）
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  /// 退出全屏模式
  ///
  /// 使用 fire-and-forget 模式，恢复竖屏方向和系统 UI。
  static void exitFullScreen() {
    // 如果已经不是全屏模式，则直接返回
    if (!isFullScreen()) return;

    // 恢复竖屏方向
    OrientationUtil.switchToPortrait();

    // 恢复状态栏和导航栏
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
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
