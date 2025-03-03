// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/19
// Brief: 链接设置常量

import 'package:aliplayer_widget_example/constants/page_routes.dart';

/// 定义数据结构来存储每个item的信息
class LinkItem {
  /// 名称
  final String name;

  /// 输入框中的链接
  String link;

  /// 跳转到的目标页面
  String route;

  LinkItem({
    required this.name,
    this.link = '',
    this.route = '',
  });

  @override
  String toString() {
    return 'LinkItem{name: $name, link: $link, route: $route}';
  }
}

/// 链接设置常量
class LinkConstants {
  // 私有构造函数，防止实例化
  LinkConstants._();

  static const String vod = '点播地址';
  static const String thumbnail = '缩略图地址';
  static const String liveLandscape = '横屏直播地址';
  static const String livePortrait = '竖屏直播地址';
  static const String shortVideo = '短视频地址';

  static List<LinkItem> linkItems = [
    LinkItem(
      name: vod,
      route: PageRoutes.longVideo,
    ),
    LinkItem(
      name: thumbnail,
      route: PageRoutes.longVideo,
    ),
    LinkItem(
      name: liveLandscape,
      route: PageRoutes.liveLandscape,
    ),
    LinkItem(
      name: livePortrait,
      route: PageRoutes.livePortrait,
    ),
    LinkItem(
      name: shortVideo,
      route: PageRoutes.shortVideo,
    ),
  ];
}
