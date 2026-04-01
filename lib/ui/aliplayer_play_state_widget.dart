// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/11
// Brief: 播放状态控件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/slot/slot_elements.dart';
import 'package:aliplayer_widget/slot/slot_manager.dart';
import 'package:flutter/material.dart';

/// 播放状态控件
///
/// A widget that displays the current player state.
class AliPlayerPlayStateWidget extends StatelessWidget {
  /// 错误码
  ///
  /// Error code, if any
  final int? errorCode;

  /// 错误信息
  ///
  /// Error message, if any
  final String? errorMsg;

  const AliPlayerPlayStateWidget({
    super.key,
    this.errorCode,
    this.errorMsg,
  });

  @override
  Widget build(BuildContext context) {
    return _buildContentArea(context);
  }

  /// 构建核心内容区域
  ///
  /// Build the core content area
  Widget _buildContentArea(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      alignment: Alignment.center,
      child: _buildErrorState(context),
    );
  }

  /// 构建错误状态的 UI
  /// 包括一个红色的错误图标和错误信息文本
  ///
  /// Build UI for error state
  Widget _buildErrorState(BuildContext context) {
    // 一次性获取隐藏配置，避免重复遍历 widget tree
    // Get hidden config once to avoid repeated widget tree traversal
    final hiddenElements = SlotManager.getHiddenElements(
      context,
      SlotType.playState,
    );

    // 检查元素是否可见
    final showIcon = hiddenElements.isElementVisible(
      PlayStateElements.errorIcon,
    );
    final showMessage = hiddenElements.isElementVisible(
      PlayStateElements.errorMessage,
    );

    // 当所有元素都被隐藏时，返回空容器
    if (!showIcon && !showMessage) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showIcon)
          const Icon(
            Icons.error,
            color: Colors.red,
            size: _playStateIconSize,
          ),
        if (showIcon && showMessage) const SizedBox(height: 16),
        if (showMessage)
          Text(
            _buildErrorMessage(),
            style: _errorMessageStyle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
      ],
    );
  }

  /// 构建错误信息文本
  /// 包括错误码和错误描述
  ///
  /// Build error message text
  String _buildErrorMessage() {
    return 'Error Code: ${errorCode ?? "Unknown"}\n'
        'Error Message: ${errorMsg ?? "An unexpected error occurred."}';
  }
}

/// 播放状态扩展
///
/// Play state extension
extension PlayStateHelper on int {
  /// 扩展方法：判断是否需要构建 Widget
  ///
  /// Extension method: determine whether to build the widget
  bool get shouldBuildWidget => this == FlutterAvpdef.error;
}

/// 播放状态图标大小
///
/// Play state icon size
const double _playStateIconSize = 64;

/// 错误信息样式
///
/// Error message text style
const TextStyle _errorMessageStyle = TextStyle(
  color: Colors.white,
  fontSize: 14,
);
