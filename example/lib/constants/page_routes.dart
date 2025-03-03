// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/17
// Brief: 页面路由常量

import 'package:aliplayer_widget_example/pages/home/home_page_item.dart';
import 'package:flutter/material.dart';

/// 页面路由常量
///
/// Page route constants
class PageRoutes {
  // 私有构造函数，防止实例化
  PageRoutes._();

  /// 首页
  static const String home = '/home';

  /// 中长视频页面
  static const String longVideo = '/long_video';

  /// 短视频页面
  static const String shortVideo = '/short_video';

  /// 直播播放页面（横屏）
  static const String liveLandscape = '/live/landscape';

  /// 直播播放页面（竖屏）
  static const String livePortrait = '/live/portrait';

  /// 调试页面
  static const String debug = '/debug';

  /// 设置页面
  static const String settings = '/settings';

  /// 链接页面
  static const String link = '/link';

  /// 首页按钮配置
  ///
  /// A static list of home item configurations
  static final List<HomePageItemConfig> homeItemConfigurations = [
    const HomePageItemConfig(
      name: '中长视频',
      icon: Icons.movie_rounded,
      pageRoute: longVideo,
    ),
    const HomePageItemConfig(
      name: '直播播放（横屏）',
      icon: Icons.live_tv_rounded,
      pageRoute: liveLandscape,
    ),
    const HomePageItemConfig(
      name: '直播播放（竖屏）',
      icon: Icons.interpreter_mode_rounded,
      pageRoute: livePortrait,
    ),
    const HomePageItemConfig(
      name: '短视频',
      icon: Icons.shortcut_rounded,
      pageRoute: shortVideo,
    ),
    const HomePageItemConfig(
      name: '设置页',
      icon: Icons.settings_rounded,
      pageRoute: settings,
    ),
  ];
}
