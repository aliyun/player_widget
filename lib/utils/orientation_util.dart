// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 播放器旋转操作工具类

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 播放器旋转操作工具类
class OrientationUtil {
  // 私有构造函数，防止实例化
  OrientationUtil._();

  /// 切换到横屏模式
  static Future<void> switchToLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // 左横屏
      DeviceOrientation.landscapeRight, // 右横屏
    ]);
  }

  /// 切换到竖屏模式
  static Future<void> switchToPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // 正常竖屏
      DeviceOrientation.portraitDown, // 倒置竖屏
    ]);
  }

  /// 切换屏幕方向（自动在横屏和竖屏之间切换）
  static Future<void> toggleOrientation() async {
    final orientation = await getCurrentOrientation();
    if (orientation == Orientation.landscape) {
      await switchToPortrait();
    } else {
      await switchToLandscape();
    }
  }

  /// 锁定屏幕方向为用户当前的方向
  static Future<void> lockCurrentOrientation(BuildContext context) async {
    final orientation = MediaQueryData.fromView(View.of(context)).orientation;

    if (orientation == Orientation.landscape) {
      await switchToLandscape();
    } else {
      await switchToPortrait();
    }
  }

  /// 解锁屏幕方向，允许所有方向
  static Future<void> unlockOrientation() async {
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  /// 获取当前屏幕方向
  static Future<Orientation> getCurrentOrientation() async {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    return MediaQueryData.fromView(view).orientation;
  }
}
