// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/5/8
// Brief: Resume play strategy - example custom strategy

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/utils/log_util.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';

/// 记忆播放策略（示例自定义策略）
///
/// 演示如何继承 [BasePlayerStrategy] 实现自定义业务逻辑：
/// - 监听播放进度，节流保存到 SPManager
/// - 通过 [getResumePosition] 静态方法获取续播位置，业务侧设置到 [AliPlayerWidgetData.startTime]
/// - 监听状态变化：暂停/停止时立即保存，播放完成时清除记录
/// - 接近视频结尾时自动清除记录
///
/// Resume play strategy (example custom strategy).
class ResumePlayStrategy extends BasePlayerStrategy {
  /// 节流间隔默认值（避免频繁写入存储）
  static const Duration _defaultSaveInterval = Duration(seconds: 2);

  /// 接近结尾阈值默认值（剩余时长小于此值时清除记录）
  static const Duration _defaultEndThreshold = Duration(seconds: 10);

  /// 节流间隔
  final Duration saveInterval;

  /// 接近结尾的阈值
  final Duration endThreshold;

  /// 进度保存回调（每次保存时通知外部）
  final void Function(Duration position)? onPositionSaved;

  /// 内部状态
  int _lastSaveTimestamp = 0;
  String? _currentMediaId;
  Duration _totalDuration = Duration.zero;
  Duration _lastPosition = Duration.zero;
  bool _isCompleted = false;

  static const String _keyPrefix = 'resume_play_';

  ResumePlayStrategy({
    this.saveInterval = _defaultSaveInterval,
    this.endThreshold = _defaultEndThreshold,
    this.onPositionSaved,
  });

  @override
  String get name => 'ResumePlayStrategy';

  @override
  void onStart(AliPlayerWidgetController controller) {
    // 提取当前视频的 mediaId 用作存储 key，获取不到则不执行策略
    _currentMediaId = controller.widgetData?.videoSource.mediaId;
    if (_currentMediaId == null) return;

    // 监听播放状态变化
    listen<int>(controller.playStateNotifier, (state) {
      _handleStateChanged(state);
    });

    // 监听总时长
    listen<Duration>(controller.totalDurationNotifier, (duration) {
      _totalDuration = duration;
    });

    // 监听播放进度（带节流）
    listen<Duration>(controller.currentPositionNotifier, (position) {
      _lastPosition = position;
      _onPositionChanged(position);
    });
  }

  @override
  void onStop() {
    // 策略停止时兜底保存（如用户退出页面时正在播放）
    if (!_isCompleted && _lastPosition > Duration.zero) {
      _saveResumePosition(_lastPosition);
    }
    super.onStop();
  }

  @override
  void onReset() {
    _lastSaveTimestamp = 0;
    _currentMediaId = null;
    _totalDuration = Duration.zero;
    _lastPosition = Duration.zero;
    _isCompleted = false;
  }

  /// 播放状态变化处理
  void _handleStateChanged(int state) {
    switch (state) {
      // 暂停/停止时立即保存当前位置（不受节流限制）
      case FlutterAvpdef.paused:
      case FlutterAvpdef.stopped:
        if (_lastPosition > Duration.zero) {
          _saveResumePosition(_lastPosition);
        }
        break;
      // 播放完成时清除记录，并标记完成状态防止后续位置回调重新保存
      case FlutterAvpdef.completion:
        _isCompleted = true;
        _clearResumePosition();
        break;
      // 错误状态时保存当前进度（避免丢失）
      case FlutterAvpdef.error:
        if (_lastPosition > Duration.zero) {
          _saveResumePosition(_lastPosition);
        }
        break;
    }
  }

  /// 进度变化处理（带节流）
  void _onPositionChanged(Duration position) {
    if (_currentMediaId == null || _isCompleted) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // 节流：固定间隔保存一次，避免频繁写入
    if (now - _lastSaveTimestamp < saveInterval.inMilliseconds) {
      return;
    }
    _lastSaveTimestamp = now;

    // 接近结尾时清除记录
    if (_totalDuration > Duration.zero &&
        (_totalDuration - position) < endThreshold) {
      _clearResumePosition();
      return;
    }

    // 保存当前位置
    _saveResumePosition(position);
  }

  /// 保存续播位置
  void _saveResumePosition(Duration position) {
    if (_currentMediaId == null) return;

    SPManager.instance.saveInt(
      '$_keyPrefix$_currentMediaId',
      position.inMilliseconds,
    );
    logi('Saved position: ${position.inMilliseconds}ms', tag: name);

    // 通过框架提供的 notify() 安全触发回调（onStop 期间自动跳过）
    notify(onPositionSaved, position);
  }

  /// 获取指定视频源的续播位置（静态工具方法）
  ///
  /// 在构建 [AliPlayerWidgetData] 时调用，将返回值设置到 [AliPlayerWidgetData.startTime]，
  /// 播放器会在 prepare 前原生应用该起始位置，无画面跳变。
  ///
  /// 返回续播位置（毫秒），无记录时返回 0。
  static int getResumePosition(VideoSource? source) {
    if (source == null) return 0;

    final mediaId = source.mediaId;
    final key = '$_keyPrefix$mediaId';
    return SPManager.instance.getInt(key) ?? 0;
  }

  /// 清除续播位置
  void _clearResumePosition() {
    if (_currentMediaId == null) return;

    SPManager.instance.remove('$_keyPrefix$_currentMediaId');
    logi('Cleared resume position (near end)', tag: name);
  }
}
