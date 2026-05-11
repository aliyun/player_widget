// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/04/16
// Brief: Base 面板 可在横竖屏中复用
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:aliplayer_widget/theme/player_styles.dart';

/// 设置项在界面中的展示类型
enum SettingItemType {
  /// 开关
  ///
  /// 用于控制开/关状态
  switcher,

  /// 标签选择或输入
  ///
  /// 如标签、多选项
  tags,
}

class SettingItem<T> {
  /// 元素的唯一标识 key，对应 `[SettingMenuElements.xxx]`
  ///
  /// 配合 [AliPlayerWidget.hiddenSlotElements] 使用，
  /// 用于细粒度控制该设置项的可见性。
  ///
  /// Element key constant corresponding to `[SettingMenuElements.xxx]`.
  /// Works with [AliPlayerWidget.hiddenSlotElements] for fine-grained
  /// visibility control of individual setting items.
  final String? elementKey;

  /// 设置项类型
  final SettingItemType type;

  /// 设置项标题
  final String title;

  /// 设置项内容
  final List<Object?> tags;

  /// tag 值转换为显示文本的函数
  ///
  /// 用于将内部值（如 int）转换为用户可见的文本，支持国际化。
  final String Function(Object? tag)? tagToDisplayText;

  /// 统一由外部 state 提供
  /// switch 的受控值；为 null 表示本行不展示开关
  final ValueListenable<bool>? switchListenable;

  /// switch 回调
  final ValueChanged<bool>? onSwitchChanged;

  /// tag 点击回调
  final ValueChanged<Object?>? onTagTap;
  final ValueListenable<Object?>? selectedTagListenable;

  const SettingItem({
    this.elementKey,
    required this.type,
    required this.title,
    this.tags = const [],
    this.tagToDisplayText,
    this.switchListenable,
    this.onSwitchChanged,
    this.selectedTagListenable,
    this.onTagTap,
  });
}

typedef SettingItemTapCallback = void Function(int index, SettingItem item);

class AliPlayerSettingsPanelBase extends StatelessWidget {
  final List<SettingItem> settingItems;

  final SettingItemTapCallback? onRowTap;

  final Color backgroundColor;
  final Color panelColor;
  final Color dividerColor;

  final EdgeInsetsGeometry outerPadding;
  final EdgeInsetsGeometry listPadding;

  /// 分割线间距
  final EdgeInsetsGeometry dividerMargin;

  /// 竖屏 true（用 Card），横屏 false（不要 Card）
  final bool useCard;

  /// useCard=false 时可用
  final double borderRadius;

  /// true: 高度自适应（竖屏）; false: 高度占满（横屏）
  final bool shrinkWrap;

  /// item 项高度
  final double? itemHeight;

  const AliPlayerSettingsPanelBase({
    super.key,
    required this.itemHeight,
    required this.settingItems,
    required this.backgroundColor,
    required this.panelColor,
    required this.dividerColor,
    required this.dividerMargin,
    this.outerPadding = const EdgeInsets.symmetric(
        horizontal: PlayerStyles.kSettingPanelPaddingAll),
    this.listPadding = EdgeInsets.zero,
    this.onRowTap,
    required this.useCard,
    this.borderRadius = 0,
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final list = ListView.separated(
      padding: listPadding,
      itemCount: settingItems.length,
      shrinkWrap: shrinkWrap,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Container(
        margin: dividerMargin,
        height: PlayerStyles.kSettingPanelLineHeight,
        color: dividerColor,
      ),
      itemBuilder: (context, index) {
        final item = settingItems[index];
        return _buildSettingItem(index: index, item: item);
      },
    );

    Widget panelChild;
    if (useCard) {
      panelChild = Card(
        color: panelColor,
        margin: EdgeInsets.zero,
        child: list,
      );
    } else {
      panelChild = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: list,
      );
    }

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

/// 横屏：不要 Card，上下 padding 16
class AliPlayerLandScapeSettingsPanel extends StatelessWidget {
  final List<SettingItem> settingItems;
  final SettingItemTapCallback? onRowTap;

  const AliPlayerLandScapeSettingsPanel({
    super.key,
    required this.settingItems,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AliPlayerSettingsPanelBase(
          itemHeight: PlayerStyles.kSettingPanelLandScapeHeight,
          dividerMargin: const EdgeInsets.symmetric(
              horizontal: PlayerStyles.kSettingPanelLandScapeDividerMargin),
          settingItems: settingItems,
          backgroundColor: Colors.black.withOpacity(0.7),
          panelColor: Colors.transparent,
          dividerColor: PlayerStyles.colorOnPrimary.withOpacity(0.1),
          outerPadding: const EdgeInsets.only(
              top: PlayerStyles.kSettingPanelLandScapePadding),
          onRowTap: onRowTap,
          useCard: false,
          borderRadius: 0,
          shrinkWrap: true,
        ),
      ),
    );
  }
}

/// 竖屏：用 Card
class AliPlayerPortraitPanel extends StatelessWidget {
  final List<SettingItem> settingItems;
  final SettingItemTapCallback? onRowTap;

  const AliPlayerPortraitPanel({
    super.key,
    required this.settingItems,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return AliPlayerSettingsPanelBase(
      itemHeight: PlayerStyles.kSettingPanelPortraitHeight,
      dividerMargin: const EdgeInsets.only(
          left: PlayerStyles.kSettingPanelPortraitDividerMargin),
      settingItems: settingItems,
      backgroundColor: PlayerStyles.colorSettingPanel,
      panelColor: PlayerStyles.colorSettingPanelItem,
      dividerColor: PlayerStyles.colorOnPrimary.withOpacity(0.1),
      outerPadding: const EdgeInsets.symmetric(
          horizontal: PlayerStyles.kSettingPanelPaddingAll, vertical: 6),
      listPadding: EdgeInsets.zero,
      onRowTap: onRowTap,
      useCard: true,
    );
  }
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
          return Wrap(
            children: it.tags.map((tag) {
              final selected = (selectedTag == tag);
              final displayText = it.tagToDisplayText != null
                  ? it.tagToDisplayText!(tag)
                  : tag.toString();
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: it.onTagTap != null ? () => it.onTagTap!(tag) : null,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: selected
                          ? PlayerStyles.colorOnPrimary
                          : PlayerStyles.colorOnPrimary.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
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
            Expanded(
              child: _TitleWithSelected(
                title: it.title,
                index: index,
              ),
            ),
            if (it.tags.isNotEmpty && it.selectedTagListenable != null) ...[
              buildTagsArea(),
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
      style: const TextStyle(
        color: PlayerStyles.colorOnPrimary,
        fontSize: 14,
      ),
    );
  }
}
