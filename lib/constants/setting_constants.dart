// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/17
// Brief: 定义播放器设置相关的常量

import 'package:flutter_aliplayer/flutter_avpdef.dart';

/// 播放器设置相关的常量类
///
/// Constants class for player settings.
class SettingConstants {
  // 私有构造函数，防止实例化
  SettingConstants._();

  /// 可选的播放速度
  ///
  /// Available playback speed options.
  ///
  /// 包括以下选项：
  /// - 0.3: 极慢速 / Very slow.
  /// - 0.5: 慢速 / Slow.
  /// - 1.0: 正常速度 / Normal speed (default).
  /// - 1.5: 快速 / Fast.
  /// - 2.0: 更快速 / Faster.
  /// - 3.0: 极快速 / Very fast.
  static final List<double> speedOptions = [
    0.3,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
  ];

  /// 默认的播放速度
  ///
  /// Default playback speed.
  static const double defaultSpeed = 1.0;

  /// 默认的播放音量
  ///
  /// Default playback volume.
  static const double defaultVolume = 1.0;

  /// 默认的亮度
  ///
  /// Default brightness.
  static const double defaultBrightness = 0.5;

  /// 默认的循环播放状态
  ///
  /// Default loop play state.
  static const bool defaultIsLoop = false;

  /// 默认的静音状态
  ///
  /// Default mute state.
  static const bool defaultIsMute = false;

  /// 可选的镜像模式
  ///
  /// Available mirror mode options.
  static final List<int> mirrorModeOptions = [
    MirrorMode.MIRROR_MODE_NONE,
    MirrorMode.MIRROR_MODE_HORIZONTAL,
    MirrorMode.MIRROR_MODE_VERTICAL,
  ];

  /// 默认的镜像模式
  ///
  /// Default mirror mode.
  static const int defaultMirrorMode = MirrorMode.MIRROR_MODE_NONE;

  /// 可选的旋转角度
  ///
  /// Available rotate mode options.
  static final List<int> rotateModeOptions = [
    RotateMode.ROTATE_0,
    RotateMode.ROTATE_90,
    RotateMode.ROTATE_180,
    RotateMode.ROTATE_270,
  ];

  /// 默认的旋转角度
  ///
  /// Default rotate mode.
  static const int defaultRotateMode = RotateMode.ROTATE_0;

  /// 可选的渲染填充模式
  ///
  /// Available scale mode options.
  static final List<int> scaleModeOptions = [
    ScaleMode.SCALE_TO_FILL,
    ScaleMode.SCALE_ASPECT_FIT,
    ScaleMode.SCALE_ASPECT_FILL,
  ];

  /// 默认的渲染填充模式
  ///
  /// Default scale mode.
  static const int defaultScaleMode = ScaleMode.SCALE_ASPECT_FILL;
}
