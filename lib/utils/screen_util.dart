// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/18
// Brief: 屏幕工具类

// import 'package:aliplayer_widget/utils/log_util.dart';
import 'package:flutter/material.dart';

/// 屏幕工具类
class ScreenUtil {
  // 私有构造函数，防止实例化
  ScreenUtil._();

  /// 计算视频的实际渲染尺寸和宽高比
  ///
  /// Calculate the actual rendering size and aspect ratio of the video.
  static Size calculateRenderSize(
    BuildContext context, {
    required Size videoSize,
    required bool isFullScreenMode,
  }) {
    // 获取当前方向和屏幕尺寸
    final screenSize = MediaQuery.of(context).size;
    // logi("calculateRenderSize: screenSize: $screenSize, videoSize: $videoSize");

    // 如果视频尺寸为空或非法，则根据屏幕方向分配默认尺寸
    if (videoSize == Size.zero ||
        videoSize.width <= 0 ||
        videoSize.height <= 0 ||
        videoSize.aspectRatio <= 0) {
      return screenSize;
    }

    // 处理竖屏视频的情况下，调整逻辑
    if (videoSize.height > videoSize.width) {
      return isFullScreenMode
          ? _calculateVerticalFullScreenDimensions(screenSize, videoSize)
          : _calculateVerticalNonFullScreenDimensions(screenSize, videoSize);
    }

    // 计算视频的宽高比
    final aspectRatio = videoSize.aspectRatio;
    // 根据模式选择全屏或非全屏计算逻辑
    return isFullScreenMode
        ? _calculateFullScreenDimensions(screenSize, aspectRatio)
        : _calculateNonFullScreenDimensions(screenSize, aspectRatio);
  }

  /// 默认尺寸计算
  ///
  /// Calculate the default dimensions.
  static Size calculateDefaultDimensions(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;

    double width, height;

    // 计算宽和高，确保短边占满屏幕
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      width = shortestSide;
      height = shortestSide * size.aspectRatio;
    } else {
      height = shortestSide;
      width = shortestSide * size.aspectRatio;
    }

    return Size(width, height);
  }

  /// 竖屏模式下全屏显示
  static Size _calculateVerticalFullScreenDimensions(
    Size screenSize,
    Size videoSize,
  ) {
    final videoAspectRatio = videoSize.aspectRatio; // 竖屏的宽高比应该是 < 1
    final screenAspectRatio = screenSize.width / screenSize.height;

    // 如果屏幕宽高比大于视频宽高比，则优先利用屏幕宽度
    if (screenAspectRatio > videoAspectRatio) {
      return Size(screenSize.width, screenSize.width / videoAspectRatio);
    }
    // 否则优先利用屏幕高度
    return Size(screenSize.height * videoAspectRatio, screenSize.height);
  }

  /// 竖屏模式下非全屏显示
  static Size _calculateVerticalNonFullScreenDimensions(
    Size screenSize,
    Size videoSize,
  ) {
    final videoAspectRatio = videoSize.aspectRatio; // 竖屏的宽高比应该是 < 1
    final screenAspectRatio = screenSize.width / screenSize.height;

    // 如果屏幕宽高比大于视频宽高比，则优先利用屏幕宽度
    if (screenAspectRatio > videoAspectRatio) {
      return Size(screenSize.width, screenSize.width / videoAspectRatio);
    }
    // 否则优先利用屏幕高度
    return Size(screenSize.height * videoAspectRatio, screenSize.height);
  }

  /// 全屏模式下的宽高计算
  static Size _calculateFullScreenDimensions(
    Size screenSize,
    double aspectRatio,
  ) {
    final screenAspectRatio = screenSize.width / screenSize.height;

    // 根据宽高比判断是否需要留黑边
    if (aspectRatio > screenAspectRatio) {
      // 视频宽高比大于屏幕宽高比，优先利用屏幕高度
      return Size(screenSize.height * aspectRatio, screenSize.height);
    } else {
      // 视频宽高比小于屏幕宽高比，优先利用屏幕宽度
      return Size(screenSize.width, screenSize.width / aspectRatio);
    }
  }

  /// 非全屏模式下的宽高计算
  static Size _calculateNonFullScreenDimensions(
    Size screenSize,
    double aspectRatio,
  ) {
    final screenAspectRatio = screenSize.width / screenSize.height;

    // 根据宽高比判断是否需要留黑边
    if (aspectRatio > screenAspectRatio) {
      // 视频宽高比大于屏幕宽高比，优先利用屏幕宽度
      return Size(screenSize.width, screenSize.width / aspectRatio);
    } else {
      // 视频宽高比小于屏幕宽高比，优先利用屏幕高度
      return Size(screenSize.height * aspectRatio, screenSize.height);
    }
  }
}
