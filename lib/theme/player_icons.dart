// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/04/03
// Brief: Icon file name constants for aliplayer_widget.

/// 播放器图标文件名常量
///
/// 命名规则：`ic_` 前缀 + 小写下划线，状态后缀 `_on`/`_off`/`_done`/`_exit`
///
/// 格式选择：SVG 首选（无需多分辨率），PNG 需提供 1x/2x/3x 三套
abstract final class PlayerIcons {
  PlayerIcons._();

  // ─── 顶部栏 ────────────────────────────────────────────
  /// 返回按钮
  static const String back = 'ic_return.png';

  /// 截图按钮
  static const String snapshot = 'ic_snapshot.png';

  /// 下载按钮
  static const String download = 'ic_download.png';

  /// 设置按钮
  static const String settings = 'ic_settings.png';

  /// 播放按钮
  static const String play = 'ic_play.png';

  /// 播放按钮(竖屏样式)
  static const String playPortrait = 'ic_play_portrait.png';

  /// 暂停按钮
  static const String pause = 'ic_pause.png';

  /// 暂停按钮(竖屏样式)
  static const String pausePortrait = 'ic_pause_portrait.png';

  /// 刷新按钮
  static const String refresh = 'ic_refresh.png';

  /// 字幕显示开启按钮
  static const String subtitleOpen = 'ic_subtitle_open.png';

  /// 字幕显示关闭按钮
  static const String subtitleClose = 'ic_subtitle_close.png';

  /// 声音控制
  static const String volume = 'ic_volume.png';

  /// 亮度控制
  static const String brightness = 'ic_light.png';

  /// 倍速控制
  static const String speedControl = 'ic_fast_forward.png';

  /// 全屏控制
  static const String fullScreen = 'ic_fullscreen.png';

  /// 播放器状态 加载中
  static const String statusLoading = 'ic_loading.png';

  /// 播放器状态 错误
  static const String statusError = 'ic_error.png';

  /// 播放器状态 提示
  static const String statusInfo = 'ic_info.png';

  /// 播放器状态 成功
  static const String statusSuccess = 'ic_success.png';
}
