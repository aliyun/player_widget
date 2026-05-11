// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: junhuiYe
// Date: 2026/4/7
// Brief: 自定义按钮控件，用于显示各类UI控件。

import 'package:aliplayer_widget/theme/player_assets_scope.dart';
import 'package:aliplayer_widget/theme/player_styles.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  /// 图标名称
  final String iconName;

  /// 图标大小，默认值为 30x30
  final Size iconSize;

  /// 可自定义 margin
  final EdgeInsets margin;

  /// 响应点击事件
  final VoidCallback? onPressed;

  const CustomIconButton({
    super.key,
    required this.iconName,
    this.iconSize = const Size(
      PlayerStyles.commonIconSize,
      PlayerStyles.commonIconSize,
    ),
    this.margin = const EdgeInsets.symmetric(
      horizontal: 0,
    ),
    this.onPressed,
  });

  /// 构建自定义图标按钮组件
  ///
  /// Builds the custom icon button widget.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: iconSize.width,
        height: iconSize.height,
        margin: margin,
        alignment: Alignment.center,
        child: Image.asset(
          PlayerAssetsScope.iconPath(context, iconName),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
