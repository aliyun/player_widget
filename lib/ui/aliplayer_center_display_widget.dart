// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/14
// Brief: 自定义居中展示控件
import 'package:aliplayer_widget/theme/player_styles.dart';
import 'package:flutter/material.dart';

/// 自定义居中展示控件
class AliPlayerCenterDisplayWidget extends StatelessWidget {
  /// 内容组件
  final Widget contentWidget;

  const AliPlayerCenterDisplayWidget({
    super.key,
    required this.contentWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: PlayerStyles.kTopBarHeight +
            PlayerStyles.kCenterDisplayTopExtraPadding,
      ),
      child: Container(
        alignment: Alignment.topCenter,
        child: IntrinsicWidth(
          child: IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                color: PlayerStyles.kControlWidgetColor,
                // 设置圆角半径
                borderRadius: BorderRadius.circular(
                  PlayerStyles.kCenterDisplayBorderRadius,
                ),
              ),
              alignment: Alignment.center,
              child: contentWidget,
            ),
          ),
        ),
      ),
    );
  }
}

/// 定义中心显示控件的内容类型
enum ContentViewType {
  none, // 不显示
  brightness, // 显示亮度滑块
  volume, // 显示音量滑块
  speed, // 显示倍速
}
