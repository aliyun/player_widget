// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/11
// Brief: 播放状态控件

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_avpdef.dart';

/// 播放状态控件
///
/// Player State Widget
class AliPlayerPlayStateWidget extends StatefulWidget {
  /// 控件宽度
  ///
  /// Width of the widget
  final double width;

  /// 控件高度
  ///
  /// Height of the widget
  final double height;

  /// 播放状态
  ///
  /// Current play state
  final int playState;

  /// 错误码
  ///
  /// Error code, if any
  final int? errorCode;

  /// 错误信息
  ///
  /// Error message, if any
  final String? errorMsg;

  /// 取消暂停回调
  ///
  /// Callback for canceling pause
  final VoidCallback? onPauseCanceled;

  /// 刷新播放回调
  ///
  /// Callback for refreshing
  final VoidCallback? onRefresh;

  const AliPlayerPlayStateWidget({
    super.key,
    required this.width,
    required this.height,
    required this.playState,
    this.errorCode,
    this.errorMsg,
    this.onPauseCanceled,
    this.onRefresh,
  });

  @override
  State<AliPlayerPlayStateWidget> createState() =>
      _AliPlayerPlayStateWidgetState();
}

class _AliPlayerPlayStateWidgetState extends State<AliPlayerPlayStateWidget> {
  @override
  Widget build(BuildContext context) {
    // 如果需要拦截手势，则使用 GestureDetector
    return widget.playState.shouldInterceptGestures
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _handleTap,
            onDoubleTap: null,
            child: _buildContentArea(),
          )
        : IgnorePointer(
            ignoring: true,
            child: _buildContentArea(),
          );
  }

  /// 构建核心内容区域
  ///
  /// Build the core content area
  Widget _buildContentArea() {
    // 判断是否需要显示背景颜色
    final bool showBackground = widget.playState.shouldShowBackground;

    return Stack(
      children: [
        Container(
          width: widget.width,
          height: widget.height,
          color: showBackground
              ? Colors.black.withOpacity(0.5)
              : Colors.transparent,
          child: Center(
            child: _buildContent(),
          ),
        ),
        // 调试模式下显示调试信息
        if (kDebugMode)
          Positioned(
            left: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _buildDebugInfo(),
            ),
          ),
      ],
    );
  }

  /// 处理点击事件
  ///
  /// Handle the tap event
  void _handleTap() {
    switch (widget.playState) {
      case FlutterAvpdef.paused:
        widget.onPauseCanceled?.call();
        break;
      case FlutterAvpdef.completion:
      case FlutterAvpdef.error:
        widget.onRefresh?.call();
        break;
      default:
        break;
    }
  }

  /// 构建内容
  /// 根据播放状态构建不同的 UI
  ///
  /// Build content based on play state
  Widget _buildContent() {
    switch (widget.playState) {
      case FlutterAvpdef.paused:
        return _buildPausedState();
      case FlutterAvpdef.error:
        return _buildErrorState();
      case FlutterAvpdef.completion:
        return _buildCompletionState();
      default:
        return const SizedBox.shrink();
    }
  }

  /// 构建暂停状态的 UI
  /// 显示一个白色的播放箭头图标
  ///
  /// Build UI for paused state
  Widget _buildPausedState() {
    return const Icon(
      Icons.play_arrow,
      color: Colors.white,
      size: _playStateIconSize,
    );
  }

  /// 构建完成状态的 UI
  /// 显示一个白色的重播图标
  ///
  /// Build UI for completion state
  Widget _buildCompletionState() {
    return const Icon(
      Icons.replay,
      color: Colors.white,
      size: _playStateIconSize,
    );
  }

  /// 构建错误状态的 UI
  /// 包括一个红色的错误图标和错误信息文本
  ///
  /// Build UI for error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            color: Colors.red,
            size: _playStateIconSize,
          ),
          const SizedBox(height: 16),
          Text(
            _buildErrorMessage(),
            style: _errorTextStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  /// 构建错误信息文本
  /// 包括错误码和错误描述
  ///
  /// Build error message text
  String _buildErrorMessage() {
    return 'Error Code: ${widget.errorCode ?? "Unknown"}\n'
        'Error Message: ${widget.errorMsg ?? "An unexpected error occurred."}';
  }

  /// 构建调试信息
  /// 仅在调试模式下显示当前播放状态
  ///
  /// Build debug information
  Widget _buildDebugInfo() {
    return Text(
      'state: ${_getStateName(widget.playState)}',
      style: _debugTextStyle,
    );
  }

  /// 获取状态名称
  /// 根据播放状态返回对应的字符串描述
  ///
  /// Get the name of the play state
  static String _getStateName(int state) {
    switch (state) {
      case FlutterAvpdef.unknow:
        return 'unknown';
      case FlutterAvpdef.idle:
        return 'idle';
      case FlutterAvpdef.initalized:
        return 'initialized';
      case FlutterAvpdef.prepared:
        return 'prepared';
      case FlutterAvpdef.started:
        return 'started';
      case FlutterAvpdef.paused:
        return 'paused';
      case FlutterAvpdef.stopped:
        return 'stopped';
      case FlutterAvpdef.completion:
        return 'completion';
      case FlutterAvpdef.error:
        return 'error';
      default:
        return 'invalid state';
    }
  }

  /// 状态更新回调
  /// 当 Widget 的状态被更新时，该方法被调用。
  ///
  /// Called when the state of the widget is updated.
  @override
  void didUpdateWidget(covariant AliPlayerPlayStateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRebuild(oldWidget)) {
      setState(() {});
    }
  }

  /// 判断是否需要触发重建
  ///
  /// Determine whether to trigger a rebuild
  bool _shouldRebuild(AliPlayerPlayStateWidget oldWidget) {
    // 仅在播放状态变化或错误信息变化时触发重建
    return widget.playState != oldWidget.playState ||
        (widget.playState == FlutterAvpdef.error &&
            (widget.errorCode != oldWidget.errorCode ||
                widget.errorMsg != oldWidget.errorMsg));
  }
}

/// 播放状态扩展
///
/// Play state extension
extension PlayStateHelper on int {
  /// 扩展方法：判断是否需要显示背景颜色
  ///
  /// Extension method: determine whether to show background color
  bool get shouldShowBackground =>
      this == FlutterAvpdef.paused ||
      this == FlutterAvpdef.error ||
      this == FlutterAvpdef.completion;

  /// 扩展方法：判断是否需要拦截手势事件
  ///
  /// Extension method: determine whether to intercept gesture events
  bool get shouldInterceptGestures =>
      this != FlutterAvpdef.prepared && this != FlutterAvpdef.started;
}

/// 播放状态图标大小
const double _playStateIconSize = 64;

/// 错误信息样式
const TextStyle _errorTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 14,
);

/// 调试信息样式
const TextStyle _debugTextStyle = TextStyle(
  color: Colors.grey,
  fontSize: 10,
);
