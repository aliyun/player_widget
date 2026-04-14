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
  ///
  /// [controller] 播放器控制器，传递给 slotBuilder 以支持在全屏模式下正确控制播放器
  ///
  /// 支持两种 slotBuilder 签名以保持向后兼容：
  /// - `Widget Function(BuildContext)` - 旧版本（已废弃）
  /// - `Widget Function(BuildContext, AliPlayerWidgetController)` - 新版本（推荐）
  static Widget buildSlot({
    required AliPlayerWidget widget,
    required SlotType slotType,
    required Widget Function(BuildContext context) defaultBuilder,
    required BuildContext context,
    required AliPlayerWidgetController controller,
  }) {
    final slotBuilders = widget.slotBuilders;

    // 如果插槽构建器为null，则不显示该插槽
    if (slotBuilders.containsKey(slotType) && slotBuilders[slotType] == null) {
      return const SizedBox.shrink();
    }

    // 如果插槽构建器不为null，则使用自定义构建器，否则使用默认构建器
    final slotBuilder = slotBuilders[slotType];
    if (slotBuilder != null) {
      // 检测函数签名以支持向后兼容
      // 支持旧版 SlotWidgetBuilder (单参数) 和新版 SlotWidgetBuilderWithController (双参数)
      return _callSlotBuilder(slotBuilder, context, controller);
    }
    return defaultBuilder(context);
  }

  /// 调用 slotBuilder，自动检测签名类型以支持向后兼容
  ///
  /// Call slotBuilder with automatic signature detection for backward compatibility
  static Widget _callSlotBuilder(
    Function slotBuilder,
    BuildContext context,
    AliPlayerWidgetController controller,
  ) {
    // 通过反射检测函数参数数量
    // 如果函数接受2个参数，使用新版签名；否则使用旧版签名
    try {
      // 尝试新版签名 (context, controller)
      return Function.apply(slotBuilder, [context, controller]);
    } catch (e) {
      // 如果失败，回退到旧版签名
      // ignore: deprecated_member_use
      return Function.apply(slotBuilder, [context]);
    }
  }

  /// 构建浮层插槽
  ///
  /// Build overlays slot widgets
  ///
  /// [controller] 播放器控制器，传递给 slotBuilder 以支持在全屏模式下正确控制播放器
  ///
  /// 支持两种 slotBuilder 签名以保持向后兼容：
  /// - `Widget Function(BuildContext)` - 旧版本（已废弃）
  /// - `Widget Function(BuildContext, AliPlayerWidgetController)` - 新版本（推荐）
  static List<Widget> buildOverlaysSlot({
    required AliPlayerWidget widget,
    required Widget Function(BuildContext context) defaultBuilder,
    required BuildContext context,
    required AliPlayerWidgetController controller,
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
      return [_callSlotBuilder(slotBuilder, context, controller)];
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

  /// 获取指定插槽的需隐藏元素集合
  ///
  /// 从上下文向上自动查找 [AliPlayerWidget]，返回相应插槽的隐藏配置。
  /// 此实现使各个 UI 组件能够内聚地获取配置，而无需外部逐层传入。
  ///
  /// ⚠️ 性能警告 / Performance Warning:
  /// 此方法内部调用 `context.findAncestorWidgetOfExactType()`，会遍历 widget tree。
  /// 若需要检查多个元素可见性，建议调用一次此方法获取 hiddenElements，
  /// 然后使用 [HiddenElementsExt.isElementVisible] 扩展方法进行多次检查，避免重复遍历。
  ///
  /// ⚠️ This method calls `context.findAncestorWidgetOfExactType()` internally,
  /// which traverses the widget tree. When checking visibility of multiple elements,
  /// prefer calling this method once and using [HiddenElementsExt.isElementVisible] for subsequent checks.
  static Set<String> getHiddenElements(
    BuildContext context,
    SlotType slotType,
  ) {
    // Note keria:
    // 使用 findAncestorWidgetOfExactType 而非 InheritedWidget，主要基于性能与使用场景的考量：
    //
    // 1. hiddenSlotElements 属于配置型数据，初始化后基本不会发生变化；
    // 2. AliPlayerWidget 在播放过程中会因进度、状态变化频繁触发 rebuild；
    //
    // 如果使用 InheritedWidget：
    // - 虽然数据读取本身是 O(1)，但其依赖机制会在依赖发生变化或 rebuild 时，
    //   触发所有依赖该 InheritedWidget 的子组件进行级联重建；
    // - 在播放器高频 rebuild 的场景下，这种机制会带来额外的性能开销。
    //
    // 相比 findAncestorWidgetOfExactType：
    // - 其查找复杂度是 O(n)，其中 n 为向上遍历的祖先层级数。
    // - 虽然需要向上查找 widget tree（通常仅 5~10 层），
    // - 但不会建立依赖关系，也不会引发额外的子树重建，整体开销更可控。
    //
    // 因此在当前场景下，该方案更有利于避免不必要的 rebuild，提高性能稳定性。
    // 后续仍需持续关注 UI 性能表现，避免潜在性能劣化。
    final widget = context.findAncestorWidgetOfExactType<AliPlayerWidget>();
    return widget?.hiddenSlotElements[slotType] ?? const <String>{};
  }

  /// 批量构建多个插槽
  ///
  /// Build multiple slots at once
  static Map<SlotType, Widget> buildMultipleSlots({
    required AliPlayerWidget widget,
    required Map<SlotType, Widget Function(BuildContext context)>
        defaultBuilders,
    required BuildContext context,
    required AliPlayerWidgetController controller,
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
          controller: controller,
        );
      }
    }

    return result;
  }
}

/// 隐藏元素集合的扩展方法
///
/// Extension methods for hidden element sets.
extension HiddenElementsExt on Set<String>? {
  /// 检查元素是否可见
  ///
  /// Check if an element is visible.
  ///
  /// 若集合为 null 或空，则所有元素默认可见。
  /// 若集合包含 [key]，则该元素被隐藏。
  ///
  /// If the set is null or empty, all elements are visible by default.
  /// If the set contains [key], that element is hidden.
  bool isElementVisible(String key) {
    final set = this;
    if (set == null || set.isEmpty) return true;
    return !set.contains(key);
  }
}
