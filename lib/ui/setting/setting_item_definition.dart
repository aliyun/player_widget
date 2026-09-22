// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/05/06
// Brief: 设置项纯元数据描述符，定义设置项的静态元数据（分组、排序、可见性规则）

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

/// 设置项分组，用于竖屏设置面板的分段显示
///
/// Setting item group for sectioned display in portrait settings panel.
enum SettingItemGroup {
  /// 字幕相关设置
  ///
  /// Subtitle-related settings.
  subtitle,

  /// 播放控制相关设置（倍速、清晰度等）
  ///
  /// Playback control settings (speed, quality, etc.).
  playback,

  /// 开关类设置（循环、静音等）
  ///
  /// Toggle settings (loop, mute, etc.).
  toggles,

  /// 显示模式设置（镜像、渲染、旋转等）
  ///
  /// Display mode settings (mirror, scale, rotate, etc.).
  display,
}

/// 设置项纯元数据描述符
///
/// 仅定义设置项的静态元数据（分组、场景排除、面板可见性）,
/// 不包含任何运行时构建逻辑。运行时的构建与可见性绑定由
/// [SettingItemRegistry] 负责。
///
/// Pure metadata descriptor for a setting item.
///
/// Defines only static metadata (grouping, scene exclusion, panel
/// visibility) without any runtime build logic. Runtime build and
/// visibility binding are handled by [SettingItemRegistry].
class SettingItemDefinition {
  /// 元素唯一标识 key，对应 [SettingMenuElements] 常量
  ///
  /// Element key corresponding to a [SettingMenuElements] constant.
  final String elementKey;

  /// 竖屏设置面板中的分组归属
  ///
  /// Group this item belongs to in the portrait settings panel.
  final SettingItemGroup group;

  /// 排除的场景集合，在这些场景下该设置项不可见
  ///
  /// Scene types where this setting item is hidden.
  final Set<SceneType> excludedScenes;

  /// 是否在竖屏设置面板中显示
  ///
  /// Whether this item is visible in the portrait settings panel.
  final bool showInPortraitPanel;

  /// 是否在横屏设置面板中显示
  ///
  /// Whether this item is visible in the landscape settings panel.
  final bool showInLandscapePanel;

  /// 创建设置项描述符
  ///
  /// Creates a setting item definition.
  const SettingItemDefinition({
    required this.elementKey,
    required this.group,
    this.excludedScenes = const {},
    this.showInPortraitPanel = true,
    this.showInLandscapePanel = true,
  });
}
