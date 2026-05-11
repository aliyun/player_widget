// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/04/03
// Brief: InheritedWidget for providing assets path to descendants.

import 'package:flutter/material.dart';

/// 用于在 Widget 树中传递资源路径
///
/// # 自定义皮肤
///
/// 1. 创建资源目录：
///    ```
///    your_app/assets/player_icons/
///    ├── ic_back.png
///    ├── ic_settings.png
///    └── ...
///    ```
///
/// 2. 注册资源（pubspec.yaml）：
///    ```yaml
///    flutter:
///      assets:
///        - assets/player_icons/
///    ```
///
/// 3. 传入路径：
///    ```dart
///    AliPlayerWidget(controller, assetsPath: 'assets/player_icons')
///    ```
class PlayerAssetsScope extends InheritedWidget {
  /// 资源路径
  final String assetsPath;

  /// 默认资源路径（包内）
  static const String defaultAssetsPath =
      'packages/aliplayer_widget/assets/icons';

  const PlayerAssetsScope({
    super.key,
    required this.assetsPath,
    required super.child,
  });

  /// 从 context 获取资源路径，未找到则返回默认路径
  static String of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<PlayerAssetsScope>();
    return scope?.assetsPath ?? defaultAssetsPath;
  }

  /// 获取完整图标路径
  ///
  /// ```dart
  /// final path = PlayerAssetsScope.iconPath(context, PlayerIcons.back);
  /// SvgPicture.asset(path)
  /// ```
  static String iconPath(BuildContext context, String iconName) =>
      '${of(context)}/$iconName';

  @override
  bool updateShouldNotify(PlayerAssetsScope oldWidget) =>
      assetsPath != oldWidget.assetsPath;
}
