// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/5/8
// Brief: Stutter detection strategy

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/utils/log_util.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

/// 卡顿统计信息
///
/// Contains stutter detection statistics.
class StutterInfo {
  /// 卡顿次数
  final int stutterCount;

  /// 总卡顿时长
  final Duration totalStutterDuration;

  /// 有效播放时长（不含卡顿）
  final Duration effectivePlayDuration;

  /// 卡顿率 = 卡顿时长 / (有效播放时长 + 卡顿时长)
  double get stutterRate {
    final total = effectivePlayDuration.inMilliseconds +
        totalStutterDuration.inMilliseconds;
    if (total <= 0) return 0;
    return totalStutterDuration.inMilliseconds / total;
  }

  const StutterInfo({
    required this.stutterCount,
    required this.totalStutterDuration,
    required this.effectivePlayDuration,
  });

  @override
  String toString() => 'StutterInfo(count: $stutterCount, '
      'stutterDuration: ${totalStutterDuration.inMilliseconds}ms, '
      'playDuration: ${effectivePlayDuration.inMilliseconds}ms, '
      'rate: ${(stutterRate * 100).toStringAsFixed(1)}%)';
}

/// 卡顿检测策略
///
/// 协调监听播放状态和加载状态，统计有效播放时长、卡顿次数和卡顿时长。
/// 当检测到卡顿时，通过 [onStutterDetected] 回调通知外部。
///
/// Stutter detection strategy.
///
/// Coordinates play state and loading state monitoring to track effective
/// playback duration, stutter count, and stutter duration.
class StutterDetectStrategy extends BasePlayerStrategy {
  /// 默认卡顿阈值，单位毫秒
  static const Duration _defaultStutterThreshold = Duration(milliseconds: 500);

  static int _defaultNowMillis() => DateTime.now().millisecondsSinceEpoch;

  /// 时间源，用于获取当前毫秒时间戳
  ///
  /// Time source for current millisecond timestamps.
  final int Function() _nowMillisProvider;

  int get _nowMillis => _nowMillisProvider();

  /// 卡顿阈值，低于此时长的 loading 不计入卡顿
  ///
  /// Loading durations shorter than this threshold are not counted as stutter.
  final Duration stutterThreshold;

  /// 卡顿检测回调
  ///
  /// Called when a stutter event is detected (loading duration exceeds threshold).
  final void Function(StutterInfo info)? onStutterDetected;

  /// 内部状态
  int _stutterCount = 0;
  int _totalStutterMs = 0;
  int _effectivePlayMs = 0;

  /// loading 开始时间戳
  int? _loadingStartTimestamp;

  /// 有效播放开始时间戳
  int? _playStartTimestamp;

  /// 当前是否处于播放中
  bool _isPlaying = false;

  /// 当前是否处于 loading
  bool _isLoading = false;

  /// 创建卡顿检测策略
  ///
  /// [stutterThreshold] Loading duration threshold for stutter detection.
  /// Defaults to 500ms.
  /// [onStutterDetected] Optional callback for stutter events.
  /// [nowMillisProvider] 时间源，必须返回正值（默认 `DateTime.now().millisecondsSinceEpoch`）。
  StutterDetectStrategy({
    this.stutterThreshold = _defaultStutterThreshold,
    this.onStutterDetected,
    @visibleForTesting int Function()? nowMillisProvider,
  }) : _nowMillisProvider = nowMillisProvider ?? _defaultNowMillis {
    assert(
      nowMillisProvider == null || nowMillisProvider() > 0,
      'nowMillisProvider must return positive values',
    );
  }

  @override
  String get name => 'StutterDetectStrategy';

  @override
  void onStart(AliPlayerWidgetController controller) {
    // 监听播放状态
    listen<int>(controller.playStateNotifier, (state) {
      final now = _nowMillis;
      final wasPlaying = _isPlaying;
      _isPlaying = (state == FlutterAvpdef.started);

      if (_isPlaying && !wasPlaying) {
        // 进入播放状态，开始计时
        _playStartTimestamp = now;
      } else if (!_isPlaying && wasPlaying) {
        // 离开播放状态，累计有效播放时长
        _accumulatePlayDuration(now);
      }
    });

    // 监听加载状态
    listen<bool>(controller.isLoadingStateNotifier, (isLoading) {
      final now = _nowMillis;
      if (isLoading && !_isLoading) {
        // 进入 loading
        _isLoading = true;
        _loadingStartTimestamp = now;

        // 暂停有效播放计时
        if (_isPlaying) {
          _accumulatePlayDuration(now);
        }
      } else if (!isLoading && _isLoading) {
        // 结束 loading
        _isLoading = false;
        final loadingDuration = Duration(
          milliseconds: now - _loadingStartTimestamp!,
        );

        // 判断是否为有效卡顿
        if (_isPlaying && loadingDuration >= stutterThreshold) {
          _stutterCount++;
          _totalStutterMs += loadingDuration.inMilliseconds;

          final info = _buildStutterInfo();
          logi('Stutter detected: $info', tag: name);
          onStutterDetected?.call(info);
        }

        // 恢复有效播放计时
        if (_isPlaying) {
          _playStartTimestamp = now;
        }
      }
    });
  }

  @override
  void onReset() {
    _stutterCount = 0;
    _totalStutterMs = 0;
    _effectivePlayMs = 0;
    _loadingStartTimestamp = null;
    _playStartTimestamp = null;
    _isPlaying = false;
    _isLoading = false;
  }

  /// 累计有效播放时长
  void _accumulatePlayDuration(int now) {
    if (_playStartTimestamp != null) {
      _effectivePlayMs += now - _playStartTimestamp!;
      _playStartTimestamp = null;
    }
  }

  /// 构建当前卡顿统计信息
  StutterInfo _buildStutterInfo() {
    return StutterInfo(
      stutterCount: _stutterCount,
      totalStutterDuration: Duration(milliseconds: _totalStutterMs),
      effectivePlayDuration: Duration(milliseconds: _effectivePlayMs),
    );
  }
}
