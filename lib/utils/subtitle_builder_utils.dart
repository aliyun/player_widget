//Copyright © 2025 Alibaba Cloud. All rights reserved.

// @author junHuiYe
// @date 2025/7/16 16:31
// @brief 字幕构建器接口

import 'package:aliplayer_widget/utils/subtitle_config_utils.dart';
import 'package:flutter/cupertino.dart';

import 'package:aliplayer_widget/constants/subtitle_model.dart';

/// 字幕构建器接口
abstract class SubtitleBuilder {
  /// 构建字幕Widget
  Widget build(
    BuildContext context,
    Subtitle subtitle,
    SubtitleConfig config,
  );
}

/// 默认字幕构建器
class DefaultSubtitleBuilder implements SubtitleBuilder {
  @override
  Widget build(BuildContext context, Subtitle subtitle, SubtitleConfig config) {
    final styleConfig = config.styleConfig;

    Widget subtitleWidget = Container(
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

/// 自定义字幕构建器示例
class CustomSubtitleBuilder implements SubtitleBuilder {
  final Widget Function(
          BuildContext context, Subtitle subtitle, SubtitleConfig config)?
      customBuilder;

  CustomSubtitleBuilder({this.customBuilder});

  @override
  Widget build(BuildContext context, Subtitle subtitle, SubtitleConfig config) {
    if (customBuilder != null) {
      return customBuilder!(
        context,
        subtitle,
        config,
      );
    }
    // 回退到默认构建器
    return DefaultSubtitleBuilder().build(
      context,
      subtitle,
      config,
    );
  }
}
