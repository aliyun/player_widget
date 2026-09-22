// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/10
// Brief: Android 播放器视图类型

import 'package:flutter_aliplayer/flutter_aliplayer.dart';

/// Android 播放器视图类型
///
/// Android player view type
///
/// 仅对 Android 平台生效，iOS 平台会忽略此配置。
/// Only takes effect on Android; iOS ignores this configuration.
enum AndroidViewType {
  /// SurfaceView 渲染
  ///
  /// 性能更优，但不支持动画变换和透明背景。
  ///
  /// Better performance, but does not support animated transitions or transparent backgrounds.
  surfaceView,

  /// TextureView 渲染
  ///
  /// 支持动画变换和透明背景，兼容性更好。
  ///
  /// Supports animated transitions and transparent backgrounds with better compatibility.
  textureView,

  /// DisplayView 渲染
  ///
  /// 基于 AliDisplayView 的视图类型。
  ///
  /// View type based on AliDisplayView.
  displayView;

  /// 默认视图类型
  ///
  /// Default view type
  static const AndroidViewType defaultValue = textureView;

  /// 转换为 SDK 的视图类型
  ///
  /// Convert to the SDK view type
  AliPlayerViewTypeForAndroid toPlayerViewType() {
    return switch (this) {
      AndroidViewType.surfaceView => AliPlayerViewTypeForAndroid.surfaceview,
      AndroidViewType.textureView => AliPlayerViewTypeForAndroid.textureview,
      AndroidViewType.displayView => AliPlayerViewTypeForAndroid.displayview,
    };
  }
}
