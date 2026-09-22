// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/04/16
// Brief: 设置面板组件（可在横竖屏中复用）

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:aliplayer_widget/slot/slot_build_context.dart';
import 'package:aliplayer_widget/theme/theme.dart';
import 'setting_item.dart';

/// 设置面板基础组件，承载所有面板的公共字段与构建逻辑。
///
/// 竖屏子类 [PortraitSettingPanel] 通过继承预设参数；
/// 横屏子类 [LandScapeSettingPanel] 继承并在外层添加高斯模糊。
///
/// Base settings panel widget that holds common fields and build logic.
///
/// Portrait subclass [PortraitSettingPanel] inherits with preset parameters;
/// landscape subclass [LandScapeSettingPanel] inherits and wraps with
/// an outer backdrop blur.
class SettingPanelWidget extends StatelessWidget {
  /// 设置项
  final List<SettingItem> settingItems;

  /// 点击回调
  final SettingItemTapCallback? onRowTap;

  /// 背景色
  final Color backgroundColor;

  /// 面板色
  final Color panelColor;

  /// 分割线色
  final Color dividerColor;

  /// 外边距
  final EdgeInsetsGeometry outerPadding;

  /// 列表边距
  final EdgeInsetsGeometry listPadding;

  /// 分割线间距
  final EdgeInsetsGeometry dividerMargin;

  /// item 项高度
  final double? itemHeight;

  const SettingPanelWidget({
    super.key,
    required this.itemHeight,
    required this.settingItems,
    required this.backgroundColor,
    required this.panelColor,
    required this.dividerColor,
    required this.dividerMargin,
    this.outerPadding = const EdgeInsets.symmetric(
      horizontal: PlayerStyles.kSettingPanelPaddingAll,
    ),
    this.listPadding = EdgeInsets.zero,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final list = ListView.separated(
      padding: listPadding,
      itemCount: settingItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Container(
        margin: dividerMargin,
        height: PlayerStyles.kSettingPanelLineHeight,
        color: dividerColor,
      ),
      itemBuilder: (context, index) =>
          _buildSettingItem(index: index, item: settingItems[index]),
    );

    Widget panelChild = Card(
      elevation: 0,
      color: panelColor,
      margin: EdgeInsets.zero,
      child: list,
    );

    return Container(
      color: backgroundColor,
      padding: outerPadding,
      child: panelChild,
    );
  }

  /// 构建设置项（按 SettingItemType 分发，避免 switch(item 泛型匹配)）
  Widget _buildSettingItem({
    required int index,
    required SettingItem item,
  }) {
    switch (item.type) {
      case SettingItemType.tags:
        return _TagsRowReusable(
          index: index,
          itemHeight: itemHeight,
          item: item,
          onRowTap: onRowTap,
        );

      case SettingItemType.switcher:
        return _SwitchRowReusable(
          index: index,
          itemHeight: itemHeight,
          item: item,
          onRowTap: onRowTap,
        );
    }
  }
}

/// 横屏设置面板：继承 [SettingPanelWidget]，在外层添加高斯模糊。
///
/// Landscape settings panel that extends [SettingPanelWidget]
/// and wraps with a backdrop blur.
class LandScapeSettingPanel extends SettingPanelWidget {
  LandScapeSettingPanel({
    super.key,
    required super.settingItems,
    super.onRowTap,
  }) : super(
          itemHeight: PlayerStyles.kSettingPanelLandScapeHeight,
          backgroundColor: Colors.black.withOpacity(0.7),
          panelColor: Colors.transparent,
          dividerColor: const Color(0x1AFFFFFF),
          dividerMargin: const EdgeInsets.symmetric(
            horizontal: PlayerStyles.kSettingPanelLandScapeDividerMargin,
          ),
          outerPadding: const EdgeInsets.only(
            top: PlayerStyles.kSettingPanelLandScapePadding,
          ),
        );

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: super.build(context),
      ),
    );
  }
}

/// 竖屏设置面板：继承 [SettingPanelWidget]，预设竖屏样式参数。
///
/// Portrait settings panel that extends [SettingPanelWidget] with portrait presets.
class PortraitSettingPanel extends SettingPanelWidget {
  // colorOnPrimary = Colors.white → withOpacity(0.1) = Color(0x1AFFFFFF)
  const PortraitSettingPanel({
    super.key,
    required super.settingItems,
    super.onRowTap,
  }) : super(
          itemHeight: PlayerStyles.kSettingPanelPortraitHeight,
          backgroundColor: PlayerStyles.colorSettingPanel,
          panelColor: PlayerStyles.colorSettingPanelItem,
          dividerColor: const Color(0x1AFFFFFF),
          dividerMargin: const EdgeInsets.only(
            left: PlayerStyles.kSettingPanelPortraitDividerMargin,
          ),
          outerPadding: const EdgeInsets.symmetric(
            horizontal: PlayerStyles.kSettingPanelPaddingAll,
            vertical: 6,
          ),
          listPadding: EdgeInsets.zero,
        );
}

/// 标签、多选项 Widget
class _TagsRowReusable extends StatelessWidget {
  final int index;
  final double? itemHeight;
  final SettingItem item;
  final SettingItemTapCallback? onRowTap;

  const _TagsRowReusable({
    required this.index,
    required this.itemHeight,
    required this.item,
    required this.onRowTap,
  });

  // 选项
  @override
  Widget build(BuildContext context) {
    final it = item;

    Widget buildTagsArea() {
      if (it.tags.isEmpty || it.selectedTagListenable == null) {
        return const SizedBox.shrink();
      }

      return ValueListenableBuilder(
        valueListenable: it.selectedTagListenable as ValueListenable,
        builder: (context, selectedTag, _) {
          // Horizontal scroll prevents overflow when tags exceed row width.
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: it.tags.map((tag) {
                      final selected = (selectedTag == tag);
                      final displayText = it.tagToDisplayText != null
                          ? it.tagToDisplayText!(tag)
                          : tag.toString();
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: it.onTagTap != null
                            ? () => it.onTagTap!(tag)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            displayText,
                            style: TextStyle(
                              color: selected
                                  ? PlayerStyles.colorOnPrimary
                                  : PlayerStyles.colorOnPrimary
                                      .withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    // 标题
    Widget row = SizedBox(
      height: itemHeight,
      child: Padding(
        // 标题左边距
        padding: const EdgeInsets.only(
          left: PlayerStyles.kSettingPanelItemPadding,
        ),
        child: Row(
          children: [
            Flexible(
              child: _TitleWithSelected(
                title: it.title,
                index: index,
              ),
            ),
            if (it.tags.isNotEmpty && it.selectedTagListenable != null) ...[
              Expanded(
                child: buildTagsArea(),
              ),
              // 选项右边距 8
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );

    if (onRowTap != null) {
      row = GestureDetector(
        onTap: () => onRowTap!(index, it),
        child: row,
      );
    }

    return row;
  }
}

/// 控制开关 Widget
class _SwitchRowReusable extends StatelessWidget {
  final int index;
  final double? itemHeight;
  final SettingItem item;
  final SettingItemTapCallback? onRowTap;

  const _SwitchRowReusable({
    required this.index,
    required this.itemHeight,
    required this.item,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final it = item;

    Widget row = SizedBox(
      height: itemHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PlayerStyles.kSettingPanelItemPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: _TitleWithSelected(
                title: it.title,
                index: index,
              ),
            ),
            if (it.switchListenable != null)
              ValueListenableBuilder<bool>(
                valueListenable: it.switchListenable!,
                builder: (_, v, __) => Transform.scale(
                  scale: 0.9,
                  alignment: Alignment.centerRight,
                  child: Switch(
                    value: v,
                    onChanged: it.onSwitchChanged,
                    activeColor: Colors.blue,
                    activeTrackColor: Colors.blue.withOpacity(0.3),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (onRowTap != null) {
      row = GestureDetector(
        onTap: () => onRowTap!(index, it),
        child: row,
      );
    }

    return row;
  }
}

/// 标题 Widget
class _TitleWithSelected extends StatelessWidget {
  final String title;
  final int index;

  const _TitleWithSelected({
    required this.title,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: const TextStyle(
        color: PlayerStyles.colorOnPrimary,
        fontSize: 14,
      ),
    );
  }
}

/// 构建设置面板插槽的默认实现。
/// Builds the default settings menu slot content.
///
/// 设置面板的显示由边缘触发监听器处理，
/// 此插槽仅作为占位组件存在。
///
/// The settings panel display is handled by an edge-trigger listener;
/// this slot only exists as a placeholder widget.
Widget buildSettingMenuSlot(
  SlotBuildContext ctx,
  double width,
  double height,
) {
  return const SizedBox.shrink();
}
