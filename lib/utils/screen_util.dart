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

    // 竖屏视频（portrait video）
    // TODO: 竖屏视频在全屏与非全屏模式下可能需要不同的布局策略，待后续需求明确后区分
    if (videoSize.height > videoSize.width) {
      return _calculatePortraitDimensions(screenSize, videoSize);
    }

    // 横屏视频（landscape video）
    final aspectRatio = videoSize.aspectRatio;
    return isFullScreenMode
        ? _calculateLandscapeFullScreenDimensions(screenSize, aspectRatio)
        : _calculateLandscapeNonFullScreenDimensions(screenSize, aspectRatio);
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

  /// 竖屏视频尺寸计算（portrait video）
  static Size _calculatePortraitDimensions(
    Size screenSize,
    Size videoSize,
  ) {
    final videoAspectRatio = videoSize.aspectRatio;
    final screenAspectRatio = screenSize.width / screenSize.height;

    if (screenAspectRatio > videoAspectRatio) {
      return Size(screenSize.width, screenSize.width / videoAspectRatio);
    }
    return Size(screenSize.height * videoAspectRatio, screenSize.height);
  }

  /// 横屏视频全屏模式尺寸计算（landscape video, fullscreen）
  static Size _calculateLandscapeFullScreenDimensions(
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

  /// 横屏视频非全屏模式尺寸计算（landscape video, non-fullscreen）
  static Size _calculateLandscapeNonFullScreenDimensions(
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
