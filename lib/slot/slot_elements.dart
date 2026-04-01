// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/03/30
// Brief: Defines element key constants for each slot's sub-components.

/// 插槽元素 key 常量定义
///
/// 配合 [AliPlayerWidget.hiddenSlotElements] 使用，用于隐藏默认插槽内的单个 UI 元素。
///
/// Element key constants for use with [AliPlayerWidget.hiddenSlotElements],
/// allowing fine-grained visibility control of individual UI elements
/// within each default slot.
///
/// 示例 / Example:
/// ```dart
/// AliPlayerWidget(
///   controller,
///   hiddenSlotElements: {
///     SlotType.topBar: {TopBarElements.download, TopBarElements.snapshot},
///     SlotType.bottomBar: {BottomBarElements.fullscreen},
///   },
/// )
/// ```

/// 顶部栏元素 key 常量
///
/// Top bar element key constants.
class TopBarElements {
  TopBarElements._();

  /// 返回按钮
  ///
  /// Back button
  static const String back = 'back';

  /// 标题
  ///
  /// Title
  static const String title = 'title';

  /// 下载按钮
  ///
  /// Download button
  static const String download = 'download';

  /// 截图按钮
  ///
  /// Snapshot button
  static const String snapshot = 'snapshot';

  /// 画中画按钮
  ///
  /// Picture-in-picture button
  static const String pip = 'pip';

  /// 设置按钮
  ///
  /// Settings button
  static const String settings = 'settings';
}

/// 底部栏元素 key 常量
///
/// Bottom bar element key constants.
class BottomBarElements {
  BottomBarElements._();

  /// 播放/暂停按钮
  ///
  /// Play/pause button
  static const String play = 'play';

  /// 进度条
  ///
  /// Progress bar
  static const String progress = 'progress';

  /// 直播刷新按钮
  ///
  /// Live refresh button
  static const String refresh = 'refresh';

  /// 外挂字幕切换按钮
  ///
  /// External subtitle toggle button
  static const String subtitle = 'subtitle';

  /// 全屏切换按钮
  ///
  /// Fullscreen toggle button
  static const String fullscreen = 'fullscreen';
}

/// 设置菜单元素 key 常量
///
/// Setting menu element key constants.
class SettingMenuElements {
  SettingMenuElements._();

  /// 声音
  ///
  /// Volume
  static const String volume = 'volume';

  /// 亮度
  ///
  /// Brightness
  static const String brightness = 'brightness';

  /// 倍速
  ///
  /// Playback speed
  static const String speed = 'speed';

  /// 清晰度
  ///
  /// Track info (quality)
  static const String trackInfo = 'trackInfo';

  /// 循环播放
  ///
  /// Loop play
  static const String loop = 'loop';

  /// 静音播放
  ///
  /// Mute play
  static const String mute = 'mute';

  /// 镜像模式
  ///
  /// Mirror mode
  static const String mirrorMode = 'mirrorMode';

  /// 旋转模式
  ///
  /// Rotate mode
  static const String rotateMode = 'rotateMode';

  /// 渲染填充模式
  ///
  /// Scale mode
  static const String scaleMode = 'scaleMode';
}

/// 中心显示元素 key 常量
///
/// Center display element key constants.
class CenterDisplayElements {
  CenterDisplayElements._();

  /// 声音滑块
  ///
  /// Volume slider
  static const String volume = 'volume';

  /// 亮度滑块
  ///
  /// Brightness slider
  static const String brightness = 'brightness';

  /// 倍速显示
  ///
  /// Speed display
  static const String speed = 'speed';
}

/// 播放状态元素 key 常量
///
/// Play state element key constants.
class PlayStateElements {
  PlayStateElements._();

  /// 错误图标
  ///
  /// Error icon
  static const String errorIcon = 'errorIcon';

  /// 错误信息
  ///
  /// Error message
  static const String errorMessage = 'errorMessage';
}

/// Seek 缩略图元素 key 常量
///
/// Seek thumbnail element key constants.
class SeekThumbnailElements {
  SeekThumbnailElements._();

  /// 缩略图图片
  ///
  /// Thumbnail image
  static const String thumbnail = 'thumbnail';

  /// 时间文本
  ///
  /// Time text
  static const String timeText = 'timeText';
}

/// 播放控制手势元素 key 常量
///
/// Play control gesture element key constants.
///
/// 注意：这些元素用于控制手势交互的禁用，而非 UI 元素的隐藏。
/// 当某个手势被添加到 hiddenSlotElements 中时，该手势将被禁用。
///
/// Note: These elements control gesture interaction disabling, not UI element hiding.
/// When a gesture is added to hiddenSlotElements, that gesture will be disabled.
class PlayControlElements {
  PlayControlElements._();

  /// 单击手势（显示/隐藏控制栏 + 切换播放状态）
  ///
  /// Single tap gesture (show/hide control bar + toggle play state)
  static const String singleTap = 'singleTap';

  /// 双击手势（切换播放状态）
  ///
  /// Double tap gesture (toggle play state)
  static const String doubleTap = 'doubleTap';

  /// 长按手势（倍速播放）
  ///
  /// Long press gesture (speed playback)
  static const String longPress = 'longPress';

  /// 水平拖动手势（seek 调整进度）
  ///
  /// Horizontal drag gesture (seek to adjust progress)
  static const String horizontalDrag = 'horizontalDrag';

  /// 左侧垂直拖动手势（调整亮度）
  ///
  /// Left vertical drag gesture (adjust brightness)
  static const String leftVerticalDrag = 'leftVerticalDrag';

  /// 右侧垂直拖动手势（调整音量）
  ///
  /// Right vertical drag gesture (adjust volume)
  static const String rightVerticalDrag = 'rightVerticalDrag';
}
