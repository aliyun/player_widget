// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/04/15
// Brief: 右侧滑入面板通用工具函数

import 'package:aliplayer_widget/theme/theme.dart';
import 'package:flutter/material.dart';

/// 以"右侧滑入"的方式展示面板。
Future<T?> showRightSlidePanel<T>({
  required Widget panel,
  required BuildContext context,
  double width = PlayerStyles.kRightWheelPanelWidth,
  Duration duration = const Duration(milliseconds: 250),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    // 点击遮罩可关闭
    barrierLabel: 'RightSlidePanel',
    barrierColor: PlayerStyles.colorOnPrimary.withOpacity(0.1),
    transitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) {
      // 点击面板内部不关闭，点击外部遮罩由 showGeneralDialog 处理
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          type: MaterialType.transparency, // 不改变原本的背景表现
          child: SizedBox(
            width: width,
            height: double.infinity,
            child: panel,
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offsetTween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));

      return SlideTransition(
        position: animation.drive(offsetTween),
        child: child,
      );
    },
  );
}
