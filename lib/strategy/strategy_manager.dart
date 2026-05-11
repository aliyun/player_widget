// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/5/8
// Brief: Strategy manager for managing player strategy lifecycle

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/utils/log_util.dart';

/// 策略管理器，统一管理已注册策略的生命周期
///
/// 与 [AliPlayerWidgetController] 一对一绑定，随 Controller 创建而创建，
/// 随 destroy 而销毁。默认内置推荐策略（首帧统计、卡顿检测），开箱即用。
///
/// Strategy manager that manages the lifecycle of registered strategies.
///
/// Bound one-to-one with [AliPlayerWidgetController]. By default, it registers
/// recommended built-in strategies (first frame timing, stutter detection).
class StrategyManager {
  static const String _tag = 'StrategyManager';

  final List<PlayerStrategy> _strategies = [];
  AliPlayerWidgetController? _controller;
  bool _started = false;

  /// 创建策略管理器，默认注册内置推荐策略
  ///
  /// Creates a strategy manager with default built-in strategies.
  StrategyManager() {
    // 内置推荐策略，开箱即用
    register(FirstFrameStrategy());
    register(StutterDetectStrategy());
  }

  /// 当前已注册的策略列表（只读）
  ///
  /// Returns an unmodifiable list of currently registered strategies.
  List<PlayerStrategy> get strategies => List.unmodifiable(_strategies);

  /// 注册策略
  ///
  /// 可在 [start] 前或 [start] 后动态注册。若已 start，新注册的策略会立即启动。
  ///
  /// Registers a strategy. If already started, the new strategy will be
  /// started immediately.
  void register(PlayerStrategy strategy) {
    // 检查是否已注册同名策略
    final existing = _strategies.indexWhere((s) => s.name == strategy.name);
    if (existing != -1) {
      logw(
        'Strategy "${strategy.name}" already registered, replacing with new instance.',
        tag: _tag,
      );
      // 停止旧策略
      _safeStop(_strategies[existing]);
      _strategies[existing] = strategy;
    } else {
      _strategies.add(strategy);
    }

    // 若已启动，立即启动新策略
    if (_started && _controller != null) {
      _safeStart(strategy, _controller!);
    }
  }

  /// 按名称移除策略
  ///
  /// Unregisters a strategy by name. If the strategy is running, it will be stopped.
  void unregister(String name) {
    final index = _strategies.indexWhere((s) => s.name == name);
    if (index == -1) return;

    final strategy = _strategies.removeAt(index);
    if (_started) {
      _safeStop(strategy);
    }
  }

  /// 移除所有已注册的策略（包括内置策略）
  ///
  /// Removes all registered strategies, including built-in ones.
  void clear() {
    if (_started) {
      for (final strategy in _strategies) {
        _safeStop(strategy);
      }
    }
    _strategies.clear();
  }

  /// 初始化策略管理器，启动所有已注册策略
  ///
  /// 由 [AliPlayerWidgetController._init] 调用。
  ///
  /// Initializes the strategy manager and starts all registered strategies.
  /// Called by [AliPlayerWidgetController._init].
  void initialize(AliPlayerWidgetController controller) {
    if (_started) {
      // 已初始化时重复调用：先 stop 清理旧订阅，再重新启动
      for (final strategy in _strategies) {
        _safeStop(strategy);
      }
    }

    _controller = controller;
    _started = true;

    for (final strategy in _strategies) {
      _safeStart(strategy, controller);
    }
  }

  /// 重置所有策略的内部状态
  ///
  /// 用于视频源切换时调用，保持策略活跃但重置统计数据。
  ///
  /// Resets all strategies' internal state. Called when video source changes.
  void reset() {
    if (!_started) return;

    for (final strategy in _strategies) {
      try {
        strategy.onReset();
      } catch (e, stack) {
        loge(
          'Error resetting strategy "${strategy.name}": $e\n$stack',
          tag: _tag,
        );
      }
    }
  }

  /// 停止并销毁所有策略
  ///
  /// 由 [AliPlayerWidgetController.destroy] 调用。
  ///
  /// Stops and disposes all strategies. Called by [AliPlayerWidgetController.destroy].
  void dispose() {
    for (final strategy in _strategies) {
      _safeStop(strategy);
    }
    _strategies.clear();
    _controller = null;
    _started = false;
  }

  /// 安全启动策略，异常不影响其他策略
  void _safeStart(
    PlayerStrategy strategy,
    AliPlayerWidgetController controller,
  ) {
    try {
      strategy.isActive = true;
      strategy.onStart(controller);
    } catch (e, stack) {
      strategy.isActive = false;
      loge(
        'Error starting strategy "${strategy.name}": $e\n$stack',
        tag: _tag,
      );
    }
  }

  /// 安全停止策略，异常不影响其他策略
  ///
  /// 先置 isActive = false，再调用 onStop()。
  /// 这保证策略在 onStop() 中执行持久化时，可通过 isActive 判断
  /// 是否应触发外部回调（此时 UI 可能已销毁）。
  void _safeStop(PlayerStrategy strategy) {
    try {
      strategy.isActive = false;
      strategy.onStop();
    } catch (e, stack) {
      loge('Error stopping strategy "${strategy.name}": $e\n$stack', tag: _tag);
    }
  }
}
