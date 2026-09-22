// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2025/7/16
// Brief: Subtitle style and layout configuration models.

import 'package:flutter/material.dart';

/// 字幕样式配置，控制字幕的文本样式和布局属性。
///
/// 包含文本样式、内边距、外边距、装饰、最大宽度、最大行数和溢出策略等属性，
/// 供 [SubtitleConfig] 引用以完成字幕渲染。
///
/// Subtitle style configuration that controls text style and layout properties.
///
/// Contains text style, padding, margin, decoration, max width, max lines,
/// and overflow policy, referenced by [SubtitleConfig] for subtitle rendering.
class SubtitleStyleConfig {
  /// 字幕文本样式。
  ///
  /// The text style for subtitle text.
  final TextStyle textStyle;

  /// 字幕容器内边距。
  ///
  /// The padding inside the subtitle container.
  final EdgeInsets padding;

  /// 字幕容器外边距。
  ///
  /// The margin outside the subtitle container.
  final EdgeInsets margin;

  /// 字幕容器装饰，如背景色和圆角。
  ///
  /// The decoration for the subtitle container, such as background color
  /// and border radius.
  final BoxDecoration? decoration;

  /// 字幕容器最大宽度。
  ///
  /// The maximum width of the subtitle container.
  final double? maxWidth;

  /// 字幕文本最大行数。
  ///
  /// The maximum number of lines for subtitle text.
  final int? maxLines;

  /// 字幕文本溢出策略。
  ///
  /// The overflow strategy for subtitle text.
  final TextOverflow overflow;

  /// 创建字幕样式配置。
  ///
  /// Creates a subtitle style configuration.
  ///
  /// - [textStyle] 字幕文本样式。
  ///   The text style for subtitle text.
  /// - [padding] 字幕容器内边距。
  ///   The padding inside the subtitle container.
  /// - [margin] 字幕容器外边距。
  ///   The margin outside the subtitle container.
  /// - [decoration] 字幕容器装饰。
  ///   The decoration for the subtitle container.
  /// - [maxWidth] 字幕容器最大宽度。
  ///   The maximum width of the subtitle container.
  /// - [maxLines] 字幕文本最大行数。
  ///   The maximum number of lines for subtitle text.
  /// - [overflow] 字幕文本溢出策略。
  ///   The overflow strategy for subtitle text.
  const SubtitleStyleConfig({
    this.textStyle = const TextStyle(
      fontSize: 16,
      color: Colors.white,
      backgroundColor: Colors.transparent,
      fontWeight: FontWeight.normal,
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
    this.margin = const EdgeInsets.all(1.0),
    this.decoration = const BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
    this.maxWidth,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  /// 创建当前样式配置的副本，可选覆盖部分属性。
  ///
  /// Creates a copy of this style configuration with optionally
  /// overridden properties.
  SubtitleStyleConfig copyWith({
    TextStyle? textStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BoxDecoration? decoration,
    double? maxWidth,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return SubtitleStyleConfig(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      decoration: decoration ?? this.decoration,
      maxWidth: maxWidth ?? this.maxWidth,
      maxLines: maxLines ?? this.maxLines,
      overflow: overflow ?? this.overflow,
    );
  }
}

/// 字幕完整配置，包含样式、位置和动画设置。
///
/// 聚合 [SubtitleStyleConfig] 样式配置与位置偏移、动画开关等布局参数，
/// 供字幕构建器（如 [DefaultSubtitleBuilder]）使用。
///
/// Complete subtitle configuration including style, position, and animation.
///
/// Aggregates [SubtitleStyleConfig] style settings with position offset
/// and animation parameters, consumed by subtitle builders
/// such as [DefaultSubtitleBuilder].
class SubtitleConfig {
  /// 字幕样式配置。
  ///
  /// The subtitle style configuration.
  final SubtitleStyleConfig styleConfig;

  /// 字幕位置偏移。
  ///
  /// 使用 [EdgeInsets] 定义字幕在播放器区域内的偏移量。
  /// 仅 [bottom]、[left] 和 [right] 三个方向被字幕组件使用。
  ///
  /// Subtitle position offset within the player area.
  ///
  /// Uses [EdgeInsets] to define the offset from each edge.
  /// Only [bottom], [left], and [right] are used by the subtitle widget.
  final EdgeInsets position;

  /// 是否启用字幕切换动画。
  ///
  /// Whether to enable subtitle switching animation.
  final bool enableAnimation;

  /// 字幕切换动画时长。
  ///
  /// The duration of the subtitle switching animation.
  final Duration animationDuration;

  /// 字幕切换动画曲线。
  ///
  /// The curve of the subtitle switching animation.
  final Curve animationCurve;

  /// 创建字幕完整配置。
  ///
  /// Creates a complete subtitle configuration.
  ///
  /// - [styleConfig] 字幕样式配置。
  ///   The subtitle style configuration.
  /// - [position] 字幕位置偏移。
  ///   The subtitle position offset.
  /// - [enableAnimation] 是否启用字幕切换动画。
  ///   Whether to enable subtitle switching animation.
  /// - [animationDuration] 字幕切换动画时长。
  ///   The duration of the subtitle switching animation.
  /// - [animationCurve] 字幕切换动画曲线。
  ///   The curve of the subtitle switching animation.
  const SubtitleConfig({
    this.styleConfig = const SubtitleStyleConfig(),
    this.position = const EdgeInsets.only(),
    this.enableAnimation = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  /// 创建当前配置的副本，可选覆盖部分属性。
  ///
  /// Creates a copy of this configuration with optionally
  /// overridden properties.
  SubtitleConfig copyWith({
    SubtitleStyleConfig? styleConfig,
    EdgeInsets? position,
    bool? enableAnimation,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return SubtitleConfig(
      styleConfig: styleConfig ?? this.styleConfig,
      position: position ?? this.position,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }
}
