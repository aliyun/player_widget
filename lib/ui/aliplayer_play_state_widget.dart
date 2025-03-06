// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/11
// Brief: 播放状态控件

import 'package:flutter/material.dart';
import 'package:flutter_aliplayer/flutter_avpdef.dart';

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
    return _buildContentArea();
  }

  /// 构建核心内容区域
  ///
  /// Build the core content area
  Widget _buildContentArea() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      alignment: Alignment.center,
      child: _buildErrorState(),
    );
  }

  /// 构建错误状态的 UI
  /// 包括一个红色的错误图标和错误信息文本
  ///
  /// Build UI for error state
  Widget _buildErrorState() {
    return Column(
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
