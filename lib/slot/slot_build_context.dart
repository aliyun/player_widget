// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/11/14
// Brief: Dependency bundle for built-in slot builder functions;
//        mostly immutable references, with `dragStartPosition` as mutable drag state.

import 'package:flutter/foundation.dart';

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/ui/common/shared_animation_manager.dart';

/// 插槽构建所需的依赖集合。
/// Dependencies required for building built-in slots.
///
/// 持有稳定引用（Notifier 实例、Controller 实例），而非快照值。
/// 构建函数通过 `.value` 读取实时数据，确保 UI 更新正确。
///
/// Holds stable references (Notifier instances, Controller instances),
/// not snapshot values. Builder functions read real-time data via `.value`,
/// ensuring correct UI updates.
///
/// 在 `initState` 中创建一次，仅当 `didUpdateWidget` 检测到 Widget 参数变化时重建。
///
/// Created once in `initState`; only rebuilt when `didUpdateWidget` detects
/// changes in Widget parameters.
class SlotBuildContext {
  // ── 核心共享依赖 ──────────────────────────────────────────────────

  /// 播放控制器，持有所有播放相关的 Notifier 和方法。
  /// Player controller holding all playback-related notifiers and methods.
  final AliPlayerWidgetController controller;

  /// 共享动画管理器，控制顶部栏与底部栏的显隐动画。
  /// Shared animation manager that controls show/hide animations
  /// for the top bar and bottom bar.
  final SharedAnimationManager animationManager;

  // ── Widget 参数透传（didUpdateWidget 时可能重建）──────────────────

  /// 隐藏元素配置，控制默认插槽中单个 UI 元素的可见性。
  /// Hidden elements configuration for controlling visibility of
  /// individual UI elements within default slots.
  final Map<SlotType, Set<String>> hiddenSlotElements;

  // ── 唯一保留的 widget 级回调 ──────────────────────────────────────

  /// 返回按钮回调。
  /// Back button callback.
  ///
  /// 涉及 Navigator、widget.onBackPressed 和全屏状态的三重交互，
  /// 无法在单一插槽中独立实现，因此保留在此处。
  ///
  /// Involves Navigator, widget.onBackPressed, and fullscreen state
  /// triple interaction; cannot be independently implemented in a
  /// single slot, so it remains here.
  final VoidCallback? onBackPress;

  /// 拖拽起始位置，由底部栏拖拽回调管理。
  /// Drag start position, managed by bottom bar drag callbacks.
  ///
  /// 每个 [SlotBuildContext] 实例独立，避免多播放器实例间状态串扰。
  /// Each [SlotBuildContext] instance is independent, preventing
  /// state interference between multiple player instances.
  Duration? dragStartPosition;

  /// 创建 [SlotBuildContext] 实例。
  /// Creates a [SlotBuildContext] instance.
  SlotBuildContext({
    required this.controller,
    required this.animationManager,
    this.hiddenSlotElements = const {},
    this.onBackPress,
  });
}
