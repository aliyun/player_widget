// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/11/14
// Brief: Defines constants for all player UI slots and their configurations.

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

import 'slot_config.dart';
import 'slot_elements.dart';

/// 插槽常量定义类。
///
/// Defines constants for all player UI slots and their configurations.
class SlotConstants {
  // 私有构造函数，防止实例化
  SlotConstants._();

  /// 插槽配置映射。
  ///
  /// Slot configuration map.
  ///
  /// Key 为插槽类型 [SlotType]，Value 为该插槽的配置 [SlotConfig]。
  /// 用于定义插槽在不同播放场景（SceneType）下的可见性与可用性。
  ///
  /// The key is the slot type [SlotType], and the value is the corresponding
  /// configuration [SlotConfig]. Used to define visibility and availability
  /// of each slot under different playback scenes ([SceneType]).
  static const Map<SlotType, SlotConfig> slotConfigs = <SlotType, SlotConfig>{
    /// 播放画面基础层（视频内容层）。
    /// Base video rendering layer (player surface).
    SlotType.playerSurface: SlotConfig(),

    /// 播放状态层（如加载中、暂停图标等）。
    /// Play state layer (e.g., buffering, paused icon).
    SlotType.playState: SlotConfig(),

    /// 全局浮层（如提示弹层、交互反馈等）。
    /// Global overlays (e.g., notifications, interaction feedback).
    SlotType.overlays: SlotConfig(),

    /// 视频封面图层。
    /// Video cover image layer.
    ///
    /// 不在以下场景展示：
    /// - live：直播
    /// - restricted：受限播放
    /// - minimal：极简模式
    ///
    /// Not displayed in:
    /// - live
    /// - restricted
    /// - minimal
    SlotType.coverImage: SlotConfig(
      excludedScenes: {
        SceneType.live,
        SceneType.restricted,
        SceneType.minimal,
      },
    ),

    /// 底部播放控制栏。
    /// Bottom playback control bar.
    ///
    /// 在极简模式 minimal 中不展示。
    /// Hidden in minimal mode.
    SlotType.playControl: SlotConfig(
      excludedScenes: {
        SceneType.minimal,
      },
    ),

    /// 顶部栏（如返回按钮、标题等）。
    /// Top bar (e.g., back button, title).
    ///
    /// 在极简模式 minimal 中不展示。
    /// Hidden in minimal mode.
    SlotType.topBar: SlotConfig(
      excludedScenes: {
        SceneType.minimal,
      },
    ),

    /// 底部栏（如时间轴、附加信息等）。
    /// Bottom bar (timeline, extra info, etc.).
    ///
    /// 在极简模式 minimal 中不展示。
    /// Hidden in minimal mode.
    SlotType.bottomBar: SlotConfig(
      excludedScenes: {
        SceneType.minimal,
      },
    ),

    /// 中心区域展示层（如大播放按钮、错误提示等）。
    /// Center display layer (big play button, error messages, etc.).
    ///
    /// 在极简模式 minimal 中不展示。
    /// Hidden in minimal mode.
    SlotType.centerDisplay: SlotConfig(
      excludedScenes: {
        SceneType.minimal,
      },
    ),

    /// 设置菜单。
    /// Settings menu.
    ///
    /// 在极简模式 minimal 中不展示。
    /// Hidden in minimal mode.
    SlotType.settingMenu: SlotConfig(
      excludedScenes: {
        SceneType.minimal,
      },
    ),

    /// 拖动进度条时显示的缩略图。
    /// Seek thumbnail shown when dragging the progress bar.
    ///
    /// 不在以下场景展示：
    /// - live：直播
    /// - restricted：受限播放
    /// - minimal：极简模式
    ///
    /// Not displayed in:
    /// - live
    /// - restricted
    /// - minimal
    SlotType.seekThumbnail: SlotConfig(
      excludedScenes: {
        SceneType.live,
        SceneType.restricted,
        SceneType.minimal,
      },
    ),

    /// 字幕层。
    /// Subtitle layer.
    ///
    /// 在极简模式 minimal 中不展示。
    /// Hidden in minimal mode.
    SlotType.subtitle: SlotConfig(
      excludedScenes: {
        SceneType.minimal,
      },
    ),
  };

  /// 设置菜单元素级别的场景配置映射。
  ///
  /// Setting menu element-level scene configuration map.
  ///
  /// Key 为 [SettingMenuElements] 常量，Value 为该元素的 [SlotConfig]。
  /// 用于定义设置面板中各设置项在不同播放场景下的可见性，
  /// 与插槽级别的 [slotConfigs] 保持一致的配置模式。
  ///
  /// The key is a [SettingMenuElements] constant, and the value is the
  /// corresponding [SlotConfig]. Used to define visibility of individual
  /// setting items under different playback scenes.
  static const Map<String, SlotConfig> settingElementConfigs =
      <String, SlotConfig>{
    /// 倍速：直播和受限场景不可用
    /// Speed: unavailable in live and restricted scenes
    SettingMenuElements.speed: SlotConfig(
      excludedScenes: {
        SceneType.live,
        SceneType.restricted,
      },
    ),

    /// 循环播放：直播场景不可用
    /// Loop: unavailable in live scene
    SettingMenuElements.loop: SlotConfig(
      excludedScenes: {
        SceneType.live,
      },
    ),

    /// 字幕开关：直播场景不可用
    /// Subtitle: unavailable in live scene
    SettingMenuElements.subtitle: SlotConfig(
      excludedScenes: {
        SceneType.live,
      },
    ),
  };
}
