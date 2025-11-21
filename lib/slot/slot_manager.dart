// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/11/13
// Brief: Slot manager for AliPlayerWidget, used to manage slot building logic

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:flutter/material.dart';

/// 插槽管理器
///
/// 负责管理播放器插槽的构建逻辑，提供统一的插槽构建接口
class SlotManager {
  // 私有构造函数，防止实例化
  SlotManager._();

  /// 构建插槽或默认组件
  ///
  /// Build slot widget or default widget
  static Widget buildSlot({
    required AliPlayerWidget widget,
    required SlotType slotType,
    required Widget Function(BuildContext context) defaultBuilder,
    required BuildContext context,
  }) {
    final slotBuilders = widget.slotBuilders;

    // 如果插槽构建器为null，则不显示该插槽
    if (slotBuilders.containsKey(slotType) && slotBuilders[slotType] == null) {
      return const SizedBox.shrink();
    }

    // 如果插槽构建器不为null，则使用自定义构建器，否则使用默认构建器
    final slotBuilder = slotBuilders[slotType];
    return slotBuilder?.call(context) ?? defaultBuilder(context);
  }

  /// 构建浮层插槽
  ///
  /// Build overlays slot widgets
  static List<Widget> buildOverlaysSlot({
    required AliPlayerWidget widget,
    required Widget Function(BuildContext context) defaultBuilder,
    required BuildContext context,
  }) {
    const slotType = SlotType.overlays;
    final slotBuilders = widget.slotBuilders;

    // 如果插槽构建器为null，则不显示该插槽
    if (slotBuilders.containsKey(slotType) && slotBuilders[slotType] == null) {
      return const <Widget>[];
    }

    // 如果插槽构建器不为null，则使用自定义构建器
    final slotBuilder = slotBuilders[slotType];
    if (slotBuilder != null) {
      return [slotBuilder(context)];
    }

    // 回退到默认的overlays参数（向后兼容）
    return widget.overlays;
  }

  /// 检查插槽是否被禁用
  ///
  /// Check if slot is disabled (explicitly set to null)
  static bool isSlotDisabled(AliPlayerWidget widget, SlotType slotType) {
    return widget.slotBuilders.containsKey(slotType) &&
        widget.slotBuilders[slotType] == null;
  }

  /// 检查插槽是否有自定义构建器
  ///
  /// Check if slot has custom builder
  static bool hasCustomBuilder(AliPlayerWidget widget, SlotType slotType) {
    return widget.slotBuilders[slotType] != null;
  }

  /// 批量构建多个插槽
  ///
  /// Build multiple slots at once
  static Map<SlotType, Widget> buildMultipleSlots({
    required AliPlayerWidget widget,
    required Map<SlotType, Widget Function(BuildContext context)>
        defaultBuilders,
    required BuildContext context,
  }) {
    final result = <SlotType, Widget>{};

    for (final entry in defaultBuilders.entries) {
      final slotType = entry.key;
      final defaultBuilder = entry.value;

      if (!isSlotDisabled(widget, slotType)) {
        result[slotType] = buildSlot(
          widget: widget,
          slotType: slotType,
          defaultBuilder: defaultBuilder,
          context: context,
        );
      }
    }

    return result;
  }
}
