// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/11/14
// Brief: Built-in slot default builder registry.

import 'package:flutter/material.dart';

import 'package:aliplayer_widget/slot/slot_build_context.dart';
import 'package:aliplayer_widget/slot/slot_type.dart';
import 'package:aliplayer_widget/ui/bottom_bar_widget.dart';
import 'package:aliplayer_widget/ui/center_display_widget.dart';
import 'package:aliplayer_widget/ui/cover_image_widget.dart';
import 'package:aliplayer_widget/ui/play_control_widget.dart';
import 'package:aliplayer_widget/ui/play_state_widget.dart';
import 'package:aliplayer_widget/ui/player_surface_widget.dart';
import 'package:aliplayer_widget/ui/seek_thumbnail_widget.dart';
import 'package:aliplayer_widget/ui/subtitle_widget.dart';
import 'package:aliplayer_widget/ui/top_bar_widget.dart';
import 'package:aliplayer_widget/ui/setting/setting_panel_widget.dart';

/// 插槽内容构建器，根据宽高创建插槽内容 Widget。
///
/// Slot content builder that creates a slot content Widget based on width and height.
typedef SlotBuilder = Widget Function(double width, double height);

/// 内置插槽的默认构建器注册表。
/// Default builder registry for built-in slots.
///
/// 将每个 [SlotType] 映射到对应的顶层构建函数，
/// 通过闭包将 [SlotBuildContext] 绑定到第一个参数。
///
/// Maps each [SlotType] to its corresponding top-level builder function,
/// binding [SlotBuildContext] to the first parameter via closure.
class DefaultSlotFactory {
  /// 创建内置插槽构建器映射。
  ///
  /// Creates the built-in slot content builder map.
  static Map<SlotType, SlotBuilder> createDefaultBuilders(
    SlotBuildContext ctx,
  ) {
    return {
      SlotType.playerSurface: (w, h) => buildPlayerSurfaceSlot(ctx, w, h),
      SlotType.coverImage: (w, h) => buildCoverImageSlot(ctx, w, h),
      SlotType.playControl: (w, h) => buildPlayControlSlot(ctx, w, h),
      SlotType.topBar: (w, h) => buildTopBarSlot(ctx, w, h),
      SlotType.bottomBar: (w, h) => buildBottomBarSlot(ctx, w, h),
      SlotType.seekThumbnail: (w, h) => buildSeekThumbnailSlot(ctx, w, h),
      SlotType.centerDisplay: (w, h) => buildCenterDisplaySlot(ctx, w, h),
      SlotType.playState: (w, h) => buildPlayStateSlot(ctx, w, h),
      SlotType.settingMenu: (w, h) => buildSettingMenuSlot(ctx, w, h),
      SlotType.subtitle: (w, h) => buildSubtitleSlot(ctx, w, h),
    };
  }
}
