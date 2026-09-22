// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/04/16
// Brief: 设置项数据模型

import 'package:flutter/foundation.dart';

/// 设置项点击回调
typedef SettingItemTapCallback = void Function(int index, SettingItem item);

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

/// 设置项数据模型
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

  /// 选中的 tag
  final ValueListenable<Object?>? selectedTagListenable;

  /// 构造函数
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
