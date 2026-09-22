// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/11/14
// Brief: Player surface slot builder function.

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:flutter/material.dart';

/// 构建播放器渲染面插槽的默认实现
/// Builds the default player surface slot content.
///
/// 创建 SDK 的 [AliPlayerView] 原生渲染面，绑定到控制器
/// Creates the SDK's [AliPlayerView] native rendering surface
/// and binds it to the controller.
Widget buildPlayerSurfaceSlot(
  SlotBuildContext ctx,
  double width,
  double height,
) {
  final androidViewType = ctx.controller.widgetData?.androidViewType ??
      AndroidViewType.defaultValue;
  return AliPlayerView(
    onCreated: (viewId) => ctx.controller.setPlayerView(
      viewId,
      isPortrait: !ctx.controller.isFullScreenNotifier.value,
    ),
    x: 0,
    y: 0,
    width: width,
    height: height,
    aliPlayerViewType: androidViewType.toPlayerViewType(),
  );
}
