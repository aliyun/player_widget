// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2025/7/16
// Brief: Subtitle builder interface and implementations for rendering subtitle widgets.

import 'package:flutter/cupertino.dart';

import 'subtitle_config.dart';
import 'subtitle_model.dart';

/// 字幕构建器接口，定义字幕 Widget 的构建合约。
///
/// 是字幕渲染的抽象层，内置实现为 [DefaultSubtitleBuilder]，
/// 也可通过 [CustomSubtitleBuilder] 自定义渲染方式。
///
/// Subtitle builder interface that defines the contract for building
/// subtitle widgets.
///
/// Serves as the abstraction layer for subtitle rendering. The built-in
/// implementation is [DefaultSubtitleBuilder], and custom rendering can be
/// achieved via [CustomSubtitleBuilder].
abstract class SubtitleBuilder {
  /// 根据字幕数据和配置构建字幕 Widget。
  ///
  /// Builds a subtitle widget from the given subtitle data and configuration.
  ///
  /// - [context] 当前构建上下文。
  ///   The current build context.
  /// - [subtitle] 要渲染的字幕数据。
  ///   The subtitle data to render.
  /// - [config] 字幕配置，包含样式和动画设置。
  ///   The subtitle configuration including style and animation settings.
  Widget build(
    BuildContext context,
    Subtitle subtitle,
    SubtitleConfig config,
  );
}

/// 默认字幕构建器，使用 [SubtitleStyleConfig] 中的样式渲染字幕文本。
///
/// 当 [SubtitleConfig.enableAnimation] 为 true 时，
/// 使用 [AnimatedSwitcher] 实现字幕切换动画。
///
/// Default subtitle builder that renders subtitle text using styles
/// from [SubtitleStyleConfig].
///
/// When [SubtitleConfig.enableAnimation] is true, uses [AnimatedSwitcher]
/// to animate subtitle transitions.
class DefaultSubtitleBuilder implements SubtitleBuilder {
  /// 根据字幕数据和配置构建默认样式的字幕 Widget。
  ///
  /// Builds a default-styled subtitle widget from the given subtitle data
  /// and configuration.
  @override
  Widget build(BuildContext context, Subtitle subtitle, SubtitleConfig config) {
    final styleConfig = config.styleConfig;

    Widget subtitleWidget = Container(
      key: ValueKey(subtitle.text),
      padding: styleConfig.padding,
      decoration: styleConfig.decoration,
      constraints: styleConfig.maxWidth != null
          ? BoxConstraints(maxWidth: styleConfig.maxWidth!)
          : null,
      child: Text(
        textAlign: TextAlign.center,
        subtitle.text,
        style: styleConfig.textStyle,
        maxLines: styleConfig.maxLines,
        overflow: styleConfig.overflow,
      ),
    );

    if (config.enableAnimation) {
      subtitleWidget = AnimatedSwitcher(
        duration: config.animationDuration,
        switchInCurve: config.animationCurve,
        switchOutCurve: config.animationCurve,
        child: subtitleWidget,
      );
    }

    return Padding(
      padding: styleConfig.margin,
      child: subtitleWidget,
    );
  }
}

/// 自定义字幕构建器，允许开发者通过自定义函数完全控制字幕的渲染方式。
///
/// 当 [customBuilder] 为 null 时，回退到 [DefaultSubtitleBuilder]。
///
/// Custom subtitle builder that allows developers to fully control subtitle
/// rendering through a custom function.
///
/// When [customBuilder] is null, falls back to [DefaultSubtitleBuilder].
class CustomSubtitleBuilder implements SubtitleBuilder {
  /// 自定义字幕构建函数。
  ///
  /// 接收当前构建上下文、字幕数据和字幕配置，返回自定义的字幕 Widget。
  /// 为 null 时回退到 [DefaultSubtitleBuilder]。
  ///
  /// Custom subtitle build function.
  ///
  /// Receives the current build context, subtitle data, and subtitle
  /// configuration, and returns a custom subtitle widget.
  /// Falls back to [DefaultSubtitleBuilder] when null.
  final Widget Function(
    BuildContext context,
    Subtitle subtitle,
    SubtitleConfig config,
  )? customBuilder;

  /// 创建自定义字幕构建器。
  ///
  /// Creates a custom subtitle builder.
  ///
  /// - [customBuilder] 自定义字幕构建函数，为 null 时回退到默认实现。
  ///   The custom subtitle build function; falls back to the default
  ///   implementation when null.
  CustomSubtitleBuilder({this.customBuilder});

  /// 根据字幕数据和配置构建字幕 Widget。
  ///
  /// 优先使用 [customBuilder]，若为 null 则回退到 [DefaultSubtitleBuilder]。
  ///
  /// Builds a subtitle widget from the given subtitle data and configuration.
  ///
  /// Uses [customBuilder] if available, otherwise falls back to
  /// [DefaultSubtitleBuilder].
  @override
  Widget build(BuildContext context, Subtitle subtitle, SubtitleConfig config) {
    if (customBuilder != null) {
      return customBuilder!(context, subtitle, config);
    }
    // 回退到默认构建器
    return DefaultSubtitleBuilder().build(context, subtitle, config);
  }
}
