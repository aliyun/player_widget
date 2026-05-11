// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/11/14
// Brief: Defines the SlotType class for player UI slot identification and ordering.

/// 插槽类型定义
///
/// Slot type definition for identifying and ordering player UI slots.
///
/// 每个插槽类型由 [key]（唯一标识）和 [defaultOrder]（默认层级顺序）组成。
/// 内置插槽使用预定义的常量，间距为 10，便于外部插入自定义插槽。
///
/// Each slot type consists of a [key] (unique identifier) and [defaultOrder]
/// (default stacking order). Built-in slots use predefined constants with
/// gaps of 10, making it easy to insert custom slots at any position.
///
/// 内置插槽使用示例 / Built-in slot usage:
/// ```dart
/// AliPlayerWidget(
///   controller,
///   slotBuilders: {
///     SlotType.topBar: (context) => MyCustomTopBar(),
///   },
/// )
/// ```
///
/// 自定义插槽使用示例 / Custom slot usage:
/// ```dart
/// // 定义自定义插槽，order=35 自动落在 coverImage(30) 和 playControl(40) 之间
/// const watermark = SlotType('watermark', defaultOrder: 35);
///
/// AliPlayerWidget(
///   controller,
///   slotBuilders: {
///     watermark: (context) => WatermarkWidget(),
///   },
///   // 按 defaultOrder 自动排序
/// )
/// ```
class SlotType {
  /// 插槽唯一标识
  ///
  /// Unique identifier for the slot.
  final String key;

  /// 默认层级顺序
  ///
  /// Default stacking order in the player's Stack.
  /// Higher values render on top. Built-in slots use gaps of 10
  /// (10, 20, 30...) to allow custom slots to be inserted between them.
  final int defaultOrder;

  /// 创建插槽类型
  ///
  /// Creates a slot type with the given [key] and [defaultOrder].
  const SlotType(this.key, {this.defaultOrder = 0});

  // ---------------------------------------------------------------------------
  // 内置插槽常量（Built-in slot constants）
  //
  // 按 defaultOrder 排序，间距 10，便于外部插入自定义插槽。
  // Sorted by defaultOrder with gaps of 10 for easy custom slot insertion.
  // ---------------------------------------------------------------------------

  /// 播放器表面插槽（视频渲染层）
  ///
  /// Player surface slot (video rendering layer).
  static const playerSurface = SlotType(
    'playerSurface',
    defaultOrder: 10,
  );

  /// 字幕插槽
  ///
  /// Subtitle slot.
  static const subtitle = SlotType(
    'subtitle',
    defaultOrder: 20,
  );

  /// 封面图插槽
  ///
  /// Cover image slot.
  static const coverImage = SlotType(
    'coverImage',
    defaultOrder: 30,
  );

  /// 播放控制插槽（手势交互层）
  ///
  /// Play control slot (gesture interaction layer).
  static const playControl = SlotType(
    'playControl',
    defaultOrder: 40,
  );

  /// 顶部栏插槽
  ///
  /// Top bar slot.
  static const topBar = SlotType(
    'topBar',
    defaultOrder: 50,
  );

  /// 底部栏插槽
  ///
  /// Bottom bar slot.
  static const bottomBar = SlotType(
    'bottomBar',
    defaultOrder: 60,
  );

  /// seek 缩略图插槽
  ///
  /// Seek thumbnail slot.
  static const seekThumbnail = SlotType(
    'seekThumbnail',
    defaultOrder: 70,
  );

  /// 中心显示插槽（大播放按钮、错误提示等）
  ///
  /// Center display slot (big play button, error messages, etc.).
  static const centerDisplay = SlotType(
    'centerDisplay',
    defaultOrder: 80,
  );

  /// 播放状态插槽（加载中、暂停图标等）
  ///
  /// Play state slot (buffering, paused icon, etc.).
  static const playState = SlotType(
    'playState',
    defaultOrder: 90,
  );

  /// 设置菜单插槽
  ///
  /// Settings menu slot.
  static const settingMenu = SlotType('settingMenu', defaultOrder: 100);

  /// 浮层插槽（提示弹层、交互反馈等）
  ///
  /// Overlays slot (notifications, interaction feedback, etc.).
  static const overlays = SlotType(
    'overlays',
    defaultOrder: 110,
  );

  // ---------------------------------------------------------------------------
  // 内置插槽列表
  // ---------------------------------------------------------------------------

  /// 所有内置插槽列表，按 [defaultOrder] 排序。
  ///
  /// List of all built-in slots, sorted by [defaultOrder].
  ///
  /// 用作默认渲染顺序。自定义插槽通过 [defaultOrder] 自动插入到合适位置。
  ///
  /// Used as the default rendering order.
  /// Custom slots are automatically inserted at the correct position via [defaultOrder].
  static const List<SlotType> builtInSlots = <SlotType>[
    playerSurface,
    subtitle,
    coverImage,
    playControl,
    topBar,
    bottomBar,
    seekThumbnail,
    centerDisplay,
    playState,
    settingMenu,
    overlays,
  ];

  @override
  String toString() => 'SlotType($key, order: $defaultOrder)';
}
