// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: Aqi
// Date: 2026/05/04
// Brief: 播放状态控件

import 'package:flutter/material.dart';

/// 保持 slider 的前后进度条的高度一致
class CustomSliderShape extends RoundedRectSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );

    // 绘制 缓冲进度条颜色
    if (secondaryOffset == null ||
        sliderTheme.secondaryActiveTrackColor == null) {
      return;
    }

    // 获取轨道的基本矩形信息
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // 确定绘制区域的左右边界
    // 注意：secondaryOffset 可能在 thumbCenter 的左边或右边，取决于 textDirection 和值的大小
    double startX;
    double endX;

    if (textDirection == TextDirection.ltr) {
      // LTR: thumbCenter 是起点，secondaryOffset 是终点
      startX = thumbCenter.dx;
      endX = secondaryOffset.dx;
    } else {
      // RTL: secondaryOffset 是起点，thumbCenter 是终点
      startX = secondaryOffset.dx;
      endX = thumbCenter.dx;
    }

    // 如果 secondaryTrackValue <= value，则 startX >= endX，无需绘制
    if (startX >= endX) {
      return;
    }

    // 构建绘制矩形
    final Rect secondaryRect = Rect.fromLTRB(
      startX,
      trackRect.top,
      endX,
      trackRect.bottom,
    );

    // 创建画笔
    final Paint secondaryPaint = Paint()
      ..color = sliderTheme.secondaryActiveTrackColor!
      ..style = PaintingStyle.fill;

    // 为了保持美观，使用与主轨道相同的圆角半径
    final double trackHeight = sliderTheme.trackHeight ?? 2.0;
    final Radius radius = Radius.circular(trackHeight / 2);

    // 使用 RRect 绘制，确保两端也是圆角（或者至少右端是圆角）
    // 注意：如果希望与主轨道无缝衔接，左端（靠近 thumb）可以是直角，但通常全圆角更美观
    final RRect secondaryRRect = RRect.fromRectAndRadius(
      secondaryRect,
      radius,
    );

    context.canvas.drawRRect(secondaryRRect, secondaryPaint);
  }
}
