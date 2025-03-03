// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/17
// Brief: The home page item widget of the aliplayer_widget_example app.

import 'package:aliplayer_widget_example/utils/navigate_util.dart';
import 'package:flutter/material.dart';

/// 按钮配置项数据结构
///
/// Represents the configuration for a single button, including its name, icon, and route.
class HomePageItemConfig {
  /// 按钮名称
  final String name;

  /// 按钮图标
  final IconData icon;

  /// 路由路径
  final String pageRoute;

  const HomePageItemConfig({
    required this.name,
    required this.icon,
    required this.pageRoute,
  });
}

/// 首页子项按钮组件
///
/// A reusable button component for home page items, displaying an icon, text, and a trailing arrow.
class HomePageItem extends StatelessWidget {
  const HomePageItem({
    super.key,
    required this.itemConfig,
  });

  /// 按钮配置项
  final HomePageItemConfig itemConfig;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => NavigateUtil.pushWithRoute(context, itemConfig.pageRoute),
      splashColor: Colors.white.withOpacity(0.3),
      highlightColor: Colors.transparent,
      child: Container(
        margin: _buttonMargin,
        padding: _buttonPadding,
        decoration: _buttonDecoration,
        child: Row(
          children: [
            Icon(itemConfig.icon, color: _iconColor),
            const SizedBox(width: _spacing),
            Expanded(
              child: Text(
                itemConfig.name,
                style: _textStyle,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: _trailingIconColor,
            ),
          ],
        ),
      ),
    );
  }

  /// 按钮外边距
  static const EdgeInsetsGeometry _buttonMargin = EdgeInsets.all(6.0);

  /// 按钮内边距
  static const EdgeInsetsGeometry _buttonPadding = EdgeInsets.all(16.0);

  /// 按钮装饰（背景颜色、圆角）
  static const BoxDecoration _buttonDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    boxShadow: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        blurRadius: 4.0,
        offset: Offset(0, 2),
      ),
    ],
  );

  /// 图标颜色
  static const Color _iconColor = Colors.orangeAccent;

  /// 图标与文字之间的间距
  static const double _spacing = 16.0;

  /// 文本样式
  static const TextStyle _textStyle = TextStyle(
    fontSize: 16.0,
    color: Colors.orangeAccent,
    fontWeight: FontWeight.w500,
  );

  /// 右侧箭头图标颜色
  static const Color _trailingIconColor = Colors.orangeAccent;
}
