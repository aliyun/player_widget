// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 提供工具方法来显示不同样式的 SnackBar 消息。

import 'package:flutter/material.dart';

/// A utility class for displaying SnackBar messages in Flutter.
///
/// 提供便捷方法来显示不同样式的 SnackBar 消息。
class SnackBarUtil {
  /// Default duration for showing SnackBar messages.
  static const Duration _defaultShowDuration = Duration(seconds: 2);

  // 私有构造函数，防止实例化
  SnackBarUtil._();

  /// Displays a plain SnackBar message.
  ///
  /// 显示普通文本的 SnackBar 消息。
  ///
  /// [context] The BuildContext to display the SnackBar.
  /// [message] The message to be displayed.
  /// [duration] Optional duration for how long the SnackBar should be shown.
  static void show(
    BuildContext context,
    String message, {
    Duration duration = _defaultShowDuration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        duration: duration,
      ),
    );
  }

  /// Displays a success-themed SnackBar message.
  ///
  /// 显示带有成功主题的 SnackBar 消息。
  static void success(
    BuildContext context,
    String message, {
    Duration duration = _defaultShowDuration,
  }) {
    _showStyledSnackBar(
      context,
      message,
      Colors.green,
      Icons.check_circle,
      duration,
    );
  }

  /// Displays a warning-themed SnackBar message.
  ///
  /// 显示带有警告主题的 SnackBar 消息。
  static void warning(
    BuildContext context,
    String message, {
    Duration duration = _defaultShowDuration,
  }) {
    _showStyledSnackBar(
      context,
      message,
      Colors.orange,
      Icons.warning,
      duration,
    );
  }

  /// Displays an error-themed SnackBar message.
  ///
  /// 显示带有错误主题的 SnackBar 消息。
  static void error(
    BuildContext context,
    String message, {
    Duration duration = _defaultShowDuration,
  }) {
    _showStyledSnackBar(
      context,
      message,
      Colors.red,
      Icons.error,
      duration,
    );
  }

  /// Helper method to build styled SnackBar messages.
  ///
  /// 构建带有图标的样式化 SnackBar 消息。
  static void _showStyledSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData iconData,
    Duration duration,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildSnackBar(
        content: Row(
          children: [
            Icon(iconData, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  /// Builds a SnackBar with the given content and options.
  ///
  /// 构建一个带有指定内容和选项的 SnackBar。
  static SnackBar _buildSnackBar({
    required Widget content,
    required Color backgroundColor,
    required Duration duration,
  }) {
    return SnackBar(
      content: content,
      backgroundColor: backgroundColor,
      duration: duration,
    );
  }
}
