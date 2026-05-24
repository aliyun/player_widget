// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: wyq
// Date: 2026/5/8
// Brief: 播放器状态显示工具

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:aliplayer_widget/ui/aliplayer_play_state_widget.dart';

/// 播放状态提示工具类
class PlayStateShowUtil {
  static OverlayEntry? _currentEntry;
  static Timer? _autoHideTimer;

  /// 显示播放状态
  ///
  /// [duration]:
  /// - 对于 Loading 状态：如果为 null，则不自动消失，需手动调用 hide()。
  /// - 对于其他状态：默认为 2秒，必须在指定时间后消失。
  static void show(
    BuildContext context, {
    required PlayStatus widgetStatus,
    String? statusMessage,
    String? statusCode,
    Duration? duration = const Duration(seconds: 2),
  }) {
    // 1. 基础安全检查
    if (!context.mounted) return;

    // 2. 移除旧的 Overlay 和取消旧的 Timer
    // 这一步至关重要，确保同一时间只有一个提示，并清除之前的自动隐藏计划
    _cancelAutoHideTimer();
    _removeCurrentEntry();

    // 3. 再次检查 Context，防止在 remove 过程中页面被销毁
    if (!context.mounted) return;

    // 4. 创建新的 OverlayEntry
    final newEntry = OverlayEntry(
      builder: (overlayContext) {
        return _PlayStateOverlayContent(
          widgetStatus: widgetStatus,
          statusCode: statusCode,
          statusMessage: statusMessage,
        );
      },
    );

    // 5. 插入 Overlay
    try {
      final overlayState = Overlay.of(context, rootOverlay: true);
      // 确保 OverlayState 本身是有效的
      if (overlayState.context.mounted) {
        overlayState.insert(newEntry);
      } else {
        return; // Overlay 不可用，直接放弃
      }
    } catch (e) {
      debugPrint("PlayStateShowUtil: Overlay insert failed: $e");
      return;
    }

    // 6. 更新全局引用
    _currentEntry = newEntry;

    // 7. 设置自动隐藏逻辑
    // 逻辑：如果是 Loading 且 duration 为 null，则不设置定时器（长期显示）
    // 其他情况，或者 Loading 指定了 duration，则设置定时器
    if (duration != null && duration > Duration.zero) {
      _autoHideTimer = Timer(duration, () {
        // 【关键修复】：这里不再检查 context.mounted！
        // 即使页面销毁了，如果 Entry 还在屏幕上，我们必须把它移除，否则就是内存泄漏/UI残留。
        // 我们只检查这个 Timer 是否对应当前的 Entry，防止旧 Timer 误删新 Entry。
        if (_currentEntry == newEntry) {
          _removeCurrentEntry();
        }
      });
    }
  }

  /// 内部方法：安全移除当前 Entry
  static void _removeCurrentEntry() {
    final entryToRemove = _currentEntry;

    // 【原子操作】先清空引用，再执行移除。
    // 这样即使 remove() 报错，外部看来状态也已经重置，允许下一次 show。
    _currentEntry = null;

    if (entryToRemove != null) {
      try {
        entryToRemove.remove();
      } catch (e) {
        // 忽略移除异常，通常是因为 Entry 已经被移除或 Overlay 已销毁
        // debugPrint("PlayStateShowUtil: Remove entry error: $e");
      }
    }
  }

  /// 取消自动隐藏定时器
  static void _cancelAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
  }

  /// 清空所有状态（用于极端情况下的重置）
  static void _clearAll() {
    _cancelAutoHideTimer();
    _removeCurrentEntry();
  }

  /// 便捷方法：成功状态 (默认2秒后消失)
  static void success(
    BuildContext context, {
    String? message,
    String? code,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      widgetStatus: PlayStatus.success,
      statusMessage: message,
      statusCode: code,
      duration: duration,
    );
  }

  /// 便捷方法：错误状态 (默认3秒后消失)
  static void error(
    BuildContext context, {
    String? message,
    String? code,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      widgetStatus: PlayStatus.error,
      statusMessage: message,
      statusCode: code,
      duration: duration,
    );
  }

  /// 便捷方法：信息状态 (默认2秒后消失)
  static void info(
    BuildContext context, {
    String? message,
    String? code,
    Duration duration = const Duration(seconds: 2),
  }) {
    show(
      context,
      widgetStatus: PlayStatus.info,
      statusMessage: message,
      statusCode: code,
      duration: duration,
    );
  }

  /// 便捷方法：加载状态
  ///
  /// [duration]:
  /// - 如果传入 null，则一直显示直到调用 hide()
  /// - 如果传入时间，则超时自动消失
  /// - 推荐使用默认的自动隐藏时间，避免忘记调用 hide() 导致 UI 残留
  ///
  /// **重要提示**：当使用 duration=null 时，必须在以下时机调用 hide()：
  /// 1. 播放器准备完成后（onPrepared 回调）
  /// 2. 发生错误需要显示错误提示前
  /// 3. 页面销毁时（dispose 中）
  static void loading(
    BuildContext context, {
    String? message,
    Duration? duration,
  }) {
    show(
      context,
      widgetStatus: PlayStatus.loading,
      statusMessage: message,
      duration: duration,
    );
  }

  /// 手动隐藏
  static void hide() {
    _clearAll();
  }
}

/// 提取出来的 Widget
class _PlayStateOverlayContent extends StatefulWidget {
  final PlayStatus widgetStatus;
  final String? statusCode;
  final String? statusMessage;

  const _PlayStateOverlayContent({
    required this.widgetStatus,
    this.statusCode,
    this.statusMessage,
  });

  @override
  State<_PlayStateOverlayContent> createState() =>
      _PlayStateOverlayContentState();
}

class _PlayStateOverlayContentState extends State<_PlayStateOverlayContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    // 启动入场动画
    _controller.forward();
  }

  @override
  void dispose() {
    // 停止并释放控制器，防止内存泄漏
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 IgnorePointer 确保不阻挡用户操作底层播放器
    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.center,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: AliPlayerPlayStateWidget(
                widgetStatus: widget.widgetStatus,
                statusCode: widget.statusCode,
                statusMessage: widget.statusMessage,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
