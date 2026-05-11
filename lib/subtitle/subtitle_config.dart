// Copyright © 2025 Alibaba Cloud. All rights reserved.

// @author junHuiYe
// @date 2025/7/16 16:26
// @brief 字幕配置

import 'package:flutter/material.dart';

/// 字幕样式配置
class SubtitleStyleConfig {
  final TextStyle textStyle;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final BoxDecoration? decoration;
  final double? maxWidth;
  final int? maxLines;
  final TextOverflow overflow;

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

/// 完整的字幕配置
class SubtitleConfig {
  final SubtitleStyleConfig styleConfig;

  /// 字幕位置偏移
  ///
  /// Subtitle position offset within the player area.
  /// Uses [EdgeInsets] to define the offset from each edge.
  /// Only [bottom], [left], and [right] are used by the subtitle widget.
  final EdgeInsets position;

  final bool enableAnimation;
  final Duration animationDuration;
  final Curve animationCurve;

  const SubtitleConfig({
    this.styleConfig = const SubtitleStyleConfig(),
    this.position = const EdgeInsets.only(bottom: 0),
    this.enableAnimation = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

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
