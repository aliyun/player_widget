// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/11
// Brief: 格式化工具类

import 'package:flutter_aliplayer/flutter_avpdef.dart';

/// 格式化工具类
///
/// format util
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
  /// [scaleMode] 渲染填充模式
  static String formatScaleMode(int scaleMode) {
    switch (scaleMode) {
      case ScaleMode.SCALE_TO_FILL:
        return 'ScaleToFill';
      case ScaleMode.SCALE_ASPECT_FIT:
        return 'ScaleAspectFit';
      case ScaleMode.SCALE_ASPECT_FILL:
        return 'ScaleAspectFill';
      default:
        return 'Unknown';
    }
  }

  /// 格式化镜像模式
  ///
  /// [mirrorMode] 镜像模式
  static String formatMirrorMode(int mirrorMode) {
    switch (mirrorMode) {
      case MirrorMode.MIRROR_MODE_NONE:
        return 'None';
      case MirrorMode.MIRROR_MODE_HORIZONTAL:
        return 'Horizontal';
      case MirrorMode.MIRROR_MODE_VERTICAL:
        return 'Vertical';
      default:
        return 'Unknown';
    }
  }
}
