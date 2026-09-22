// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/5/8
// Brief: Player strategy interface and base class

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:flutter/foundation.dart';

/// 播放器策略接口
///
/// 定义策略的生命周期合约。策略只观察播放器状态，不直接控制播放行为。
/// 当需要协调多个状态信号、维护内部计时/计数、并在视频切换时重置时，
/// 应使用策略而非直接监听单个 ValueNotifier。
///
/// Player strategy interface.
///
/// Defines the lifecycle contract for strategies. Strategies only observe
/// player state and do not directly control playback behavior.
abstract class PlayerStrategy {
  /// 策略是否处于活跃状态（onStart 之后、onStop 之前）
  ///
  /// 由 [StrategyManager] 维护生命周期，子类可读取此状态判断是否应触发外部回调。
  /// 在 [onStop] 执行时此值已为 false，因此策略可安全地执行持久化操作
  /// 而不触发可能指向已销毁 UI 的回调。
  ///
  /// Whether the strategy is currently active (between onStart and onStop).
  /// Managed by [StrategyManager]. Subclasses should check this before
  /// invoking external callbacks. When [onStop] is called, this is already false.
  bool isActive = false;

  /// 策略唯一标识，用于注册/注销和调试日志
  ///
  /// Unique identifier for the strategy, used for registration and debug logs.
  String get name;

  /// 策略启动，订阅感兴趣的状态变化
  ///
  /// Called when the strategy is started. Subscribe to notifiers here.
  ///
  /// [controller] The player widget controller providing state access.
  void onStart(AliPlayerWidgetController controller);

  /// 策略停止，释放资源并取消所有订阅
  ///
  /// Called when the strategy is stopped. Release resources and cancel subscriptions.
  void onStop();

  /// 视频切换时重置内部状态（保持策略活跃）
  ///
  /// Called when the video source changes. Reset internal counters/timers
  /// while keeping the strategy active.
  void onReset() {}
}

/// 策略基类，自动管理 ValueNotifier 监听的订阅与清理
///
/// 继承此类后，只需在 [onStart] 中调用 [listen] 订阅 notifier，
/// 框架会在 [onStop] 时自动取消所有订阅，防止内存泄漏。
///
/// Base class for strategies with automatic listener lifecycle management.
///
/// Subclasses call [listen] in [onStart] to subscribe to notifiers.
/// All subscriptions are automatically cleaned up in [onStop].
abstract class BasePlayerStrategy extends PlayerStrategy {
  final List<_Binding> _bindings = [];

  /// 便捷方法：监听指定 ValueListenable，自动管理生命周期
  ///
  /// 内置 isActive 守卫：策略停止后不再触发回调，避免通知已销毁的 UI。
  ///
  /// Convenience method to listen to a [ValueListenable] with automatic
  /// lifecycle management. Includes an [isActive] guard: callbacks will not
  /// fire after the strategy is stopped.
  ///
  /// [listenable] The value listenable to observe.
  /// [onChanged] Callback invoked with the new value when it changes.
  void listen<T>(
    ValueListenable<T> listenable,
    void Function(T value) onChanged,
  ) {
    void listener() {
      if (isActive) onChanged(listenable.value);
    }

    listenable.addListener(listener);
    _bindings.add(_Binding(listenable, listener));
  }

  /// 安全触发外部回调（仅在策略活跃时执行）
  ///
  /// 用于在 [onStop] 等生命周期方法中安全地触发外部通知，
  /// 框架保证策略停止后不会调用回调。
  ///
  /// Safely invokes an external callback only when the strategy is active.
  /// Use this in [onStop] or other lifecycle methods to avoid notifying
  /// destroyed UI subscribers.
  void notify<T>(void Function(T)? callback, T value) {
    if (isActive) callback?.call(value);
  }

  @override
  void onStop() {
    for (final binding in _bindings) {
      binding.listenable.removeListener(binding.listener);
    }
    _bindings.clear();
  }

  @override
  void onReset() {
    // 子类按需重写
  }
}

/// 内部绑定记录，用于追踪 listener 与 listenable 的对应关系
class _Binding {
  /// The value listenable being observed.
  final ValueListenable listenable;

  /// The listener callback triggered by changes to the listenable.
  final VoidCallback listener;

  /// Creates a new [_Binding] instance.
  const _Binding(this.listenable, this.listener);
}
