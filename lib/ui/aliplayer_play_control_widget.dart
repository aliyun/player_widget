// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/11
// Brief: 播放器控制控件

import 'dart:async';
import 'package:flutter/material.dart';

/// 播放器控制控件
///
/// Player Control Widget
class AliPlayerPlayControlWidget extends StatefulWidget {
  /// Whether to auto-hide the control
  final bool autoHide;

  /// 回调函数：通知外部控件是否可见
  final ValueChanged<bool>? onVisibilityChanged;

  /// Callbacks for various gestures
  final VoidCallback? onSingleTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  final ValueChanged<double>? onHorizontalDragUpdate;
  final ValueChanged<double>? onHorizontalDragEnd;

  final ValueChanged<double>? onLeftVerticalDragUpdate;
  final ValueChanged<double>? onLeftVerticalDragEnd;

  final ValueChanged<double>? onRightVerticalDragUpdate;
  final ValueChanged<double>? onRightVerticalDragEnd;

  const AliPlayerPlayControlWidget({
    super.key,
    this.autoHide = true,
    this.onVisibilityChanged,
    this.onSingleTap,
    this.onDoubleTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onLeftVerticalDragUpdate,
    this.onLeftVerticalDragEnd,
    this.onRightVerticalDragUpdate,
    this.onRightVerticalDragEnd,
  });

  @override
  State<AliPlayerPlayControlWidget> createState() =>
      _AliPlayerPlayControlWidgetState();
}

class _AliPlayerPlayControlWidgetState
    extends State<AliPlayerPlayControlWidget> {
  /// 自动隐藏时间间隔
  ///
  /// Auto-hide duration as a static constant
  static const Duration _autoHideDuration = Duration(seconds: 3);

  /// 控件是否可见
  ///
  /// Whether the control is visible
  bool _isVisible = false;

  /// 定时器
  ///
  /// Timer for auto-hide
  Timer? _hideTimer;

  /// 手势检测的起点
  Offset? _startPosition;

  /// 上一次触发回调的值（用于去抖动）
  double? _lastHorizontalValue;
  double? _lastLeftVerticalValue;
  double? _lastRightVerticalValue;

  /// 缓存父容器尺寸以优化性能
  ///
  /// Cache the parent container size to optimize performance.
  Size? _cachedContainerSize;

  /// 当前拖动是否为左侧
  ///
  /// Whether the current drag is on the left side.
  bool? _isLeftSide;

  /// 滑动灵敏度阈值（像素）
  ///
  /// Minimum distance (in pixels) required to trigger a drag update.
  static const double _dragSensitivityThreshold = 10.0;

  /// 百分比变化的灵敏度阈值
  ///
  /// Minimum percentage change required to trigger a callback.
  static const double _percentChangeThreshold = 0.02;

  /// 获取父容器尺寸
  ///
  /// Get the size of the parent container.
  Size _getParentContainerSize(BuildContext context) {
    if (_cachedContainerSize == null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      _cachedContainerSize = renderBox.size;
    }
    return _cachedContainerSize!;
  }

  /// 切换控件可见性
  ///
  /// Toggle the visibility of the control view
  void _toggleVisibility() {
    _isVisible = !_isVisible;

    // 通知外部可见性变化
    _notifyVisibilityChanged();

    if (_isVisible && widget.autoHide) {
      _resetHideTimer();
    } else {
      _cancelHideTimer();
    }
  }

  /// 隐藏控件
  ///
  /// Hide the control view
  void _hide() {
    _isVisible = false;

    // 通知外部可见性变化
    _notifyVisibilityChanged();

    _cancelHideTimer();
  }

  /// 重置定时器
  ///
  /// Reset the hide timer
  void _resetHideTimer() {
    // Cancel any previous timer
    _cancelHideTimer();
    if (widget.autoHide) {
      _hideTimer = Timer(_autoHideDuration, _hide);
    }
  }

  /// 取消定时器
  ///
  /// Cancel the hide timer
  void _cancelHideTimer() {
    _hideTimer?.cancel();
  }

  /// 通知外部可见性变化
  ///
  /// Notify the parent about the visibility change
  void _notifyVisibilityChanged() {
    // 调用回调函数
    widget.onVisibilityChanged?.call(_isVisible);
  }

  @override
  void dispose() {
    // Ensure to cancel any active timer on dispose
    _cancelHideTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _toggleVisibility();
        widget.onSingleTap?.call();
      },
      onDoubleTap: widget.onDoubleTap != null
          ? () {
              _hide();
              widget.onDoubleTap?.call();
            }
          : null,
      onLongPressStart: widget.onLongPressStart != null
          ? (_) {
              _hide();
              widget.onLongPressStart?.call();
            }
          : null,
      onLongPressEnd: widget.onLongPressEnd != null
          ? (_) {
              _hide();
              widget.onLongPressEnd?.call();
            }
          : null,
      onHorizontalDragStart: widget.onHorizontalDragUpdate != null ||
              widget.onHorizontalDragEnd != null
          ? _onHorizontalDragStart
          : null,
      onHorizontalDragUpdate: widget.onHorizontalDragUpdate != null
          ? _onHorizontalDragUpdate
          : null,
      onHorizontalDragEnd:
          widget.onHorizontalDragEnd != null ? _onHorizontalDragEnd : null,
      onVerticalDragStart: (widget.onLeftVerticalDragUpdate != null ||
              widget.onLeftVerticalDragEnd != null ||
              widget.onRightVerticalDragUpdate != null ||
              widget.onRightVerticalDragEnd != null)
          ? _onVerticalDragStart
          : null,
      onVerticalDragUpdate: (widget.onLeftVerticalDragUpdate != null ||
              widget.onRightVerticalDragUpdate != null)
          ? _onVerticalDragUpdate
          : null,
      onVerticalDragEnd: (widget.onLeftVerticalDragEnd != null ||
              widget.onRightVerticalDragEnd != null)
          ? _onVerticalDragEnd
          : null,
      child: Container(),
    );
  }

  /// 水平拖动开始
  void _onHorizontalDragStart(DragStartDetails details) {
    _startPosition = details.globalPosition;
    _lastHorizontalValue = null; // 重置上次值
  }

  /// 水平拖动更新
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_startPosition == null) return;

    final Size containerSize = _getParentContainerSize(context);

    // 计算水平移动的距离
    double deltaX = details.globalPosition.dx - _startPosition!.dx;

    // 如果滑动距离未达到灵敏度阈值，则不触发回调
    if (deltaX.abs() < _dragSensitivityThreshold) return;

    // 将 deltaX 转换为相对于容器宽度的百分比（范围：-1 到 1）
    double seekDelta = deltaX / containerSize.width;
    double roundedSeekDelta = double.parse(seekDelta.toStringAsFixed(2));

    // 如果百分比变化未达到灵敏度阈值，则不触发回调
    if (_lastHorizontalValue == null ||
        (roundedSeekDelta - _lastHorizontalValue!).abs() >=
            _percentChangeThreshold) {
      widget.onHorizontalDragUpdate?.call(roundedSeekDelta);
      _lastHorizontalValue = roundedSeekDelta;
    }
  }

  /// 水平拖动结束
  void _onHorizontalDragEnd(DragEndDetails details) {
    _startPosition = null;

    // 如果有最后的值，传递给回调函数
    if (_lastHorizontalValue != null) {
      widget.onHorizontalDragEnd?.call(_lastHorizontalValue!);
    }

    // 重置上次值
    _lastHorizontalValue = null;
  }

  /// 垂直拖动开始
  void _onVerticalDragStart(DragStartDetails details) {
    _startPosition = details.globalPosition;

    // 根据拖动起点判断左右侧
    double screenWidth = MediaQuery.of(context).size.width;
    _isLeftSide = details.globalPosition.dx < screenWidth / 2;

    // 重置左侧和右侧上次值
    _lastLeftVerticalValue = null;
    _lastRightVerticalValue = null;
  }

  /// 垂直拖动更新
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_startPosition == null || _isLeftSide == null) return;

    // 判断是左侧还是右侧
    final Size containerSize = _getParentContainerSize(context);

    // 计算垂直移动的距离，并取反以调整方向
    double deltaY = -(details.globalPosition.dy - _startPosition!.dy);

    // 如果滑动距离未达到灵敏度阈值，则不触发回调
    if (deltaY.abs() < _dragSensitivityThreshold) return;

    // 将 deltaY 转换为相对于容器高度的百分比（范围：-1 到 1）
    double deltaPercent = deltaY / containerSize.height;
    double roundedDeltaPercent = double.parse(deltaPercent.toStringAsFixed(2));

    // 如果百分比变化未达到灵敏度阈值，则不触发回调
    if (_isLeftSide!) {
      // 左侧垂直拖动
      if (_lastLeftVerticalValue == null ||
          (roundedDeltaPercent - _lastLeftVerticalValue!).abs() >=
              _percentChangeThreshold) {
        widget.onLeftVerticalDragUpdate?.call(roundedDeltaPercent);
        _lastLeftVerticalValue = roundedDeltaPercent;
      }
    } else {
      // 右侧垂直拖动
      if (_lastRightVerticalValue == null ||
          (roundedDeltaPercent - _lastRightVerticalValue!).abs() >=
              _percentChangeThreshold) {
        widget.onRightVerticalDragUpdate?.call(roundedDeltaPercent);
        _lastRightVerticalValue = roundedDeltaPercent;
      }
    }

    // 更新起点
    _startPosition = details.globalPosition;
  }

  /// 垂直拖动结束
  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isLeftSide == null) return;

    if (_isLeftSide!) {
      // 如果有最后的值，传递给回调函数
      if (_lastLeftVerticalValue != null) {
        widget.onLeftVerticalDragEnd?.call(_lastLeftVerticalValue!);
      }
      // 重置左侧上次值
      _lastLeftVerticalValue = null;
    } else {
      // 如果有最后的值，传递给回调函数
      if (_lastRightVerticalValue != null) {
        widget.onRightVerticalDragEnd?.call(_lastRightVerticalValue!);
      }
      // 重置右侧上次值
      _lastRightVerticalValue = null;
    }

    _startPosition = null;
    _isLeftSide = null;
  }
}
