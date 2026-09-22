// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/14
// Brief: 自定义居中展示控件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/ui/common/content_view_type.dart';
import 'package:aliplayer_widget/ui/custom/custom_control_slider.dart';
import 'package:aliplayer_widget/ui/custom/custom_icon_button.dart';
import 'package:flutter/material.dart';

/// 自定义居中展示控件
class CenterDisplayWidget extends StatelessWidget {
  /// 内容组件
  final Widget contentWidget;

  const CenterDisplayWidget({
    super.key,
    required this.contentWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: PlayerStyles.kTopBarHeight +
            PlayerStyles.kCenterDisplayTopExtraPadding,
      ),
      child: Container(
        alignment: Alignment.topCenter,
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                color: PlayerStyles.kControlWidgetColor,
                // 设置圆角半径
                borderRadius: BorderRadius.circular(
                  PlayerStyles.kCenterDisplayBorderRadius,
                ),
              ),
              alignment: Alignment.center,
              child: contentWidget,
            ),
          ),
        ),
      ),
    );
  }
}

/// 构建中心显示插槽的默认实现。
/// Builds the default center display slot content.
///
/// 监听内容类型 Notifier，根据当前类型显示亮度、音量或倍速控件。
/// Listens to the content type notifier and displays brightness,
/// volume, or speed controls accordingly.
Widget buildCenterDisplaySlot(
  SlotBuildContext ctx,
  double width,
  double height,
) {
  // 获取 centerDisplay 插槽的隐藏元素配置
  final hiddenElements = ctx.hiddenSlotElements[SlotType.centerDisplay];

  // 监听播放状态显示视图的内容类型
  return ValueListenableBuilder(
    valueListenable: ctx.controller.contentViewTypeNotifier,
    builder: (context, contentViewType, __) {
      // 如果不显示任何内容，则返回空组件
      if (contentViewType == ContentViewType.none) {
        return const SizedBox.shrink();
      }

      // 检查当前内容类型是否被隐藏
      final contentWidget = _buildCenterDisplayContentWidget(
        ctx,
        contentViewType,
        hiddenElements,
      );

      // 如果内容被隐藏，返回空组件
      if (contentWidget == null) {
        return const SizedBox.shrink();
      }

      return CenterDisplayWidget(
        contentWidget: contentWidget,
      );
    },
  );
}

/// 根据内容类型获取对应的内容组件（内部辅助函数）。
/// Gets the content widget for the given type (internal helper).
Widget? _buildCenterDisplayContentWidget(
  SlotBuildContext ctx,
  ContentViewType contentViewType,
  Set<String>? hiddenElements,
) {
  switch (contentViewType) {
    case ContentViewType.brightness:
      return hiddenElements.isElementVisible(CenterDisplayElements.brightness)
          ? _buildBrightnessSlider(ctx)
          : null;
    case ContentViewType.volume:
      return hiddenElements.isElementVisible(CenterDisplayElements.volume)
          ? _buildVolumeSlider(ctx)
          : null;
    case ContentViewType.speed:
      return hiddenElements.isElementVisible(CenterDisplayElements.speed)
          ? _buildSpeedDisplayView()
          : null;
    default:
      return null;
  }
}

/// 构建播放速度显示视图（内部辅助函数）。
/// Builds the speed display view (internal helper).
Widget _buildSpeedDisplayView() {
  return SizedBox(
    height: PlayerStyles.kControlWidgetHeight,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: PlayerStyles.kControlVerticalInsets,
        horizontal: PlayerStyles.kControlHorizontalInsets,
      ),
      child: Row(
        children: [
          const CustomIconButton(
            iconName: PlayerIcons.speedControl,
            iconSize: Size.square(PlayerStyles.iconSizeTopBar),
          ),
          const SizedBox(
            width: PlayerStyles.kSpeedDisplayIconTextSpacing,
          ),
          Text(
            PlayerI18n.t(PlayerI18nKeys.speedFastForward),
            style: const TextStyle(
              color: Colors.white,
              fontSize: PlayerStyles.kSpeedDisplayFontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

/// 构建声音滑块控件（内部辅助函数）。
/// Builds the volume slider widget (internal helper).
Widget _buildVolumeSlider(SlotBuildContext ctx) {
  // 监听音量状态
  return ValueListenableBuilder(
    valueListenable: ctx.controller.volumeNotifier,
    builder: (builder, volume, __) {
      return CustomControlSlider(
        text: PlayerI18n.t(PlayerI18nKeys.volume),
        startIconName: PlayerIcons.volume,
        initialValue: volume,
        isInteractive: false,
      );
    },
  );
}

/// 构建亮度滑块控件（内部辅助函数）。
/// Builds the brightness slider widget (internal helper).
Widget _buildBrightnessSlider(SlotBuildContext ctx) {
  // 监听亮度状态
  return ValueListenableBuilder(
    valueListenable: ctx.controller.brightnessNotifier,
    builder: (context, brightness, __) {
      return CustomControlSlider(
        text: PlayerI18n.t(PlayerI18nKeys.brightness),
        startIconName: PlayerIcons.brightness,
        initialValue: brightness,
        isInteractive: false,
      );
    },
  );
}
