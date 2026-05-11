// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/04/03
// Brief: Unified export for aliplayer_widget UI theme.

/// 播放器 UI 主题
///
/// # 使用示例
///
/// ```dart
/// import 'package:aliplayer_widget/theme/player_theme.dart';
///
/// // 图标
/// SvgPicture.asset(
///   PlayerAssetsScope.iconPath(context, PlayerIcons.back),
///   width: PlayerStyles.iconSizeTopBar,
/// )
///
/// // 文字
/// Text(
///   'Title',
///   style: TextStyle(
///     fontSize: PlayerStyles.fontSizeTitle,
///     color: PlayerStyles.colorOnPrimary,
///   ),
/// )
/// ```
library player_theme;

export 'player_icons.dart';
export 'player_assets_scope.dart';
export 'player_styles.dart';
