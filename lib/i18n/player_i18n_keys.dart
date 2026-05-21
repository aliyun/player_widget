// Copyright 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/4/7
// Brief: Player i18n key constants

/// 播放器国际化 Key 常量定义
///
/// Internationalization key constants for the player widget.
///
/// ## 命名规范 / Naming Convention
///
/// 格式: `player.{模块}.{功能}`
/// Format: `player.{module}.{feature}`
///
/// 示例 / Examples:
/// - `player.settings.volume` - 设置面板的音量
/// - `player.error.code` - 错误码
class PlayerI18nKeys {
  PlayerI18nKeys._();

  // ==================== 设置面板 Settings ====================
  /// 字幕 / Subtitle
  static const String subtitle = 'player.settings.subtitle';

  /// 声音 / Volume
  static const String volume = 'player.settings.volume';

  /// 亮度 / Brightness
  static const String brightness = 'player.settings.brightness';

  /// 倍速 / Speed
  static const String speed = 'player.settings.speed';

  /// 清晰度 / Quality
  static const String quality = 'player.settings.quality';

  /// 循环播放 / Loop
  static const String loop = 'player.settings.loop';

  /// 静音播放 / Mute
  static const String mute = 'player.settings.mute';

  /// 镜像模式 / Mirror Mode
  static const String mirrorMode = 'player.settings.mirrorMode';

  /// 旋转模式 / Rotate Mode
  static const String rotateMode = 'player.settings.rotateMode';

  /// 渲染填充 / Scale Mode
  static const String scaleMode = 'player.settings.scaleMode';

  // ==================== 播放错误 Play Error ====================
  /// 错误码 / Error Code
  static const String errorCode = 'player.error.code';

  /// 错误信息 / Error Message
  static const String errorMessage = 'player.error.message';

  /// 发生错误 / An error occurred
  static const String errorOccurred = 'player.error.occurred';

  /// 未知错误 / Unknown error
  static const String errorUnknown = 'player.error.unknown';

  /// 无可选项 / No options available
  static const String emptyOption = 'player.prompt.emptyOption';

  // ==================== 镜像模式 Mirror Mode ====================
  /// 无 / None
  static const String mirrorNone = 'player.mirror.none';

  /// 水平镜像 / Horizontal Mirror
  static const String mirrorHorizontal = 'player.mirror.horizontal';

  /// 垂直镜像 / Vertical Mirror
  static const String mirrorVertical = 'player.mirror.vertical';

  // ==================== 倍速显示 Speed Display ====================
  /// 倍速格式 / Speed Format
  static const String speedFormat = 'player.speed.format';

  /// 倍速播放状态 / Speed Fast Forward Status
  static const String speedFastForward = 'player.speed.speedFastForward';

  // ==================== 清晰度 Quality ====================
  /// 自动 / Auto
  static const String qualityAuto = 'player.quality.auto';

  /// 未知 / Unknown
  static const String qualityUnknown = 'player.quality.unknown';

  // ==================== 渲染填充模式 Scale Mode ====================
  /// 填充 / Fill
  static const String scaleFill = 'player.scale.fill';

  /// 适应 / Fit
  static const String scaleFit = 'player.scale.fit';

  /// 裁剪 / Crop
  static const String scaleCrop = 'player.scale.crop';

  // ==================== 提示信息 Tips ====================
  /// 已下载 / Downloaded
  static const String downloaded = 'player.tip.downloaded';

  /// 正在下载 / Downloading
  static const String downloading = 'player.tip.downloading';

  /// 下载失败 / Download failed
  static const String downloadFailed = 'player.tip.downloadFailed';

  /// 下载路径未设置 / storagePath Not Set
  static const String downloadStoragePathNotSet =
      'player.tip.downloadStoragePathNotSet';

  /// 文件已经保存 / AlreadySaved
  static const String downloadAlreadySaved = 'player.tip.downloadAlreadySaved';

  /// 下载进度显示 / Download Progress
  static const String downloadProgress = 'player.tip.downloadProgress';

  /// 下载进度显示 / Download Progress
  static const String downloadStart = 'player.tip.downloadStart';

  // ==================== 旋转模式 Rotate Mode ====================
  /// 旋转角度格式 (如 "90°")
  static const String rotateFormat = 'player.rotate.format';

  /// 播放器状态 加载中 / loading
  static const String statusLoading = 'player.status.loading';

  /// 播放器状态 网络速度  / NetSpeed
  static const String statusNetSpeed = 'player.status.netSpeed';

  /// 播放器状态 错误码  / errorCode
  static const String statusErrorCode = 'player.status.errorCode';

  /// 播放器状态 错误信息 / errorMsg
  static const String statusErrorMsg = 'player.status.errorMsg';

  /// 播放器状态 截图已保存 / screenshot saved
  static const String statusSnapSaved = 'player.status.snapSaved';

  /// 播放器状态 清晰度 / quality
  static const String statusQuality = 'player.status.quality';

  /// 播放器状态 字幕开 / subtitle on
  static const String subtitleOn = 'player.status.subtitleOn';

  /// 播放器状态 字幕关 / subtitle off
  static const String subtitleOff = 'player.status.subtitleOff';
}
