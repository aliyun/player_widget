// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/14
// Brief: 自定义居中展示控件
import 'package:flutter/material.dart';

/// 自定义居中展示控件
class AliPlayerCenterDisplayWidget extends StatefulWidget {
  /// 内容组件
  final Widget contentWidget;

  const AliPlayerCenterDisplayWidget({
    super.key,
    required this.contentWidget,
  });

  @override
  State<AliPlayerCenterDisplayWidget> createState() =>
      _AliPlayerCenterDisplayWidgetState();
}

class _AliPlayerCenterDisplayWidgetState
    extends State<AliPlayerCenterDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Center(
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: widget.contentWidget, // 动态传入的内容
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 状态更新回调
  /// 当 Widget 的状态被更新时，该方法被调用。
  ///
  /// Called when the state of the widget is updated.
  @override
  void didUpdateWidget(covariant AliPlayerCenterDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contentWidget != widget.contentWidget) {
      setState(() {});
    }
  }
}

/// 定义中心显示控件的内容类型
enum ContentViewType {
  none, // 不显示
  brightness, // 显示亮度滑块
  volume, // 显示音量滑块
  speed, // 显示倍速
}
