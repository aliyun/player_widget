// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/11
// Brief: 格式化工具类

import 'package:aliplayer_widget/i18n/player_i18n.dart';
import 'package:aliplayer_widget/i18n/player_i18n_keys.dart';
import 'package:flutter_aliplayer/flutter_avpdef.dart';

/// 格式化工具类
///
/// Format util
class FormatUtil {
  // 私有构造函数，防止实例化
  FormatUtil._();

  /// 格式化时间 [duration] 为 "HH:mm:ss" 或 "mm:ss" 格式
  ///
  /// Format the given [duration] into "HH:mm:ss" or "mm:ss" format.
  /// If the duration is less than 1 hour, the hour part will be omitted.
  static String formatDuration(Duration duration) {
    // Extract time components once to avoid redundant calculations
    final int totalSeconds = duration.inSeconds;
    final int hours = totalSeconds ~/ 3600; // Total hours (integer division)
    final int minutes = (totalSeconds % 3600) ~/ 60; // Remaining minutes
    final int seconds = totalSeconds % 60; // Remaining seconds

    // Format each component with leading zeros
    final String formattedHours = hours.toString().padLeft(2, '0');
    final String formattedMinutes = minutes.toString().padLeft(2, '0');
    final String formattedSeconds = seconds.toString().padLeft(2, '0');

    // Return formatted string based on whether hours are present
    if (hours > 0) {
      // Include hours if duration is 1 hour or more
      return '$formattedHours:$formattedMinutes:$formattedSeconds';
    } else {
      // Omit hours if duration is less than 1 hour
      return '$formattedMinutes:$formattedSeconds';
    }
  }

  /// 格式化渲染填充模式
  ///
  /// Format scale mode with i18n support.
  ///
  /// [scaleMode] 渲染填充模式
  static String formatScaleMode(int scaleMode) {
    switch (scaleMode) {
      case ScaleMode.SCALE_TO_FILL:
        return PlayerI18n.t(PlayerI18nKeys.scaleFill);
      case ScaleMode.SCALE_ASPECT_FIT:
        return PlayerI18n.t(PlayerI18nKeys.scaleFit);
      case ScaleMode.SCALE_ASPECT_FILL:
        return PlayerI18n.t(PlayerI18nKeys.scaleCrop);
      default:
        return PlayerI18n.t(PlayerI18nKeys.qualityUnknown);
    }
  }

  /// 格式化镜像模式
  ///
  /// Format mirror mode with i18n support.
  ///
  /// [mirrorMode] 镜像模式
  static String formatMirrorMode(int mirrorMode) {
    switch (mirrorMode) {
      case MirrorMode.MIRROR_MODE_NONE:
        return PlayerI18n.t(PlayerI18nKeys.mirrorNone);
      case MirrorMode.MIRROR_MODE_HORIZONTAL:
        return PlayerI18n.t(PlayerI18nKeys.mirrorHorizontal);
      case MirrorMode.MIRROR_MODE_VERTICAL:
        return PlayerI18n.t(PlayerI18nKeys.mirrorVertical);
      default:
        return PlayerI18n.t(PlayerI18nKeys.mirrorNone);
    }
  }

  /// 格式化倍速显示
  ///
  /// Format speed with i18n support.
  ///
  /// Examples:
  /// - Chinese: "1.5倍速"
  /// - English: "1.5x Speed"
  ///
  /// [speed] 播放速度
  static String formatSpeed(double speed) {
    return PlayerI18n.t(
      PlayerI18nKeys.speedFormat,
      {'speed': speed.toString()},
    );
  }

  /// 格式化旋转角度
  ///
  /// Format rotation degree.
  ///
  /// [degree] 旋转角度
  static String formatRotate(int degree) {
    return PlayerI18n.t(
      PlayerI18nKeys.rotateFormat,
      {'degree': degree.toString()},
    );
  }

  /// 格式化网络速度
  ///
  /// Format net speed
  static String formatBps(int bps) {
    if (bps < 0) return '0 bps'; // 处理负数情况

    if (bps < 1000) {
      // 小于 1000，显示 bps
      return '${bps.toStringAsFixed(0)} bps';
    } else if (bps < 1000 * 1000) {
      // 1,000 ~ 999,999 -> kbps
      return '${(bps / 1000).toStringAsFixed(2)} kbps';
    } else if (bps < 1000 * 1000 * 1000) {
      // 1,000,000 ~ 999,999,999 -> Mbps
      return '${(bps / 1000 / 1000).toStringAsFixed(2)} Mbps';
    } else {
      // >= 1,000,000,000 -> Gbps
      return '${(bps / 1000 / 1000 / 1000).toStringAsFixed(2)} Gbps';
    }
  }
}
