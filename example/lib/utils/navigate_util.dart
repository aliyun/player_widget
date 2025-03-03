// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/17
// Brief: 导航工具类

import 'package:flutter/material.dart';

/// 导航工具类
class NavigateUtil {
  // 私有构造函数，防止实例化
  NavigateUtil._();

  /// 导航到指定页面
  ///
  /// Navigates to the specified page using the Navigator.push method.
  static void push(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// 使用路由名称导航到指定页面，并支持动画
  ///
  /// Navigates to the specified page using the Navigator.pushNamed method with custom animation.
  static void pushWithRoute(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  /// 返回上一页
  ///
  /// Navigates back to the previous page using the Navigator.pop method.
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
