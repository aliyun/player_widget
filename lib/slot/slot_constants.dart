// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/11/14
// Brief: Defines constants for all player UI slots and their configurations.

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

import 'slot_config.dart';

/// 插槽常量定义类。
///
/// Defines constants for all player UI slots and their configurations.
class SlotConstants {
  // 私有构造函数，防止实例化
  SlotConstants._();

  /// 播放器可用的所有插槽类型列表。
  ///
  /// List of all available slot types in the player.
  ///
  /// 插槽（Slot）用于承载播放器的不同 UI 组件，例如字幕、封面图、
  /// 播放控制栏、顶部栏和底部栏等。此列表定义播放器初始化时默认
  /// 会加载的全部插槽。
  ///
  /// Slots are used to host different UI components of the player such as
  /// subtitles, cover images, playback controls, top bar, bottom bar, etc.
  /// This list defines all default slots that are initialized with the player.
  static const List<SlotType> slotTypes = <SlotType>[
    SlotType.playerSurface,
    SlotType.subtitle,
    SlotType.coverImage,
    SlotType.playControl,
    SlotType.topBar,
    SlotType.bottomBar,
    SlotType.seekThumbnail,
    SlotType.centerDisplay,
    SlotType.playState,
    SlotType.settingMenu,
  ];

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
}
