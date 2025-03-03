// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/6
// Brief: The home page of the aliplayer_widget_example app.

import 'dart:async';
import 'package:aliplayer_widget_example/constants/page_routes.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';
import 'package:aliplayer_widget_example/pages/debug/debug_page.dart';
import 'package:aliplayer_widget_example/pages/home/home_page.dart';
import 'package:aliplayer_widget_example/pages/link/link_page.dart';
import 'package:aliplayer_widget_example/pages/live/live_page.dart';
import 'package:aliplayer_widget_example/pages/long_video/long_video_page.dart';
import 'package:aliplayer_widget_example/pages/settings/settings_page.dart';
import 'package:aliplayer_widget_example/pages/short_video/short_video_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() {
    // 初始化SharedPreferences
    SPManager.initialize();

    runApp(const MyApp());
  }, (error, stackTrace) {
    print('[AliPlayerWidget][fatal][error]: $error, $stackTrace');
  });
}

/// 主应用入口
///
/// This is the root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AliPlayer Widget Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      initialRoute: PageRoutes.home,
      routes: {
        PageRoutes.home: (context) => const HomePage(),
        PageRoutes.longVideo: (context) => const LongVideoPage(),
        PageRoutes.shortVideo: (context) => const ShortVideoPage(),
        PageRoutes.liveLandscape: (context) => const LivePage(),
        PageRoutes.livePortrait: (context) => const LivePage(isPortrait: true),
        PageRoutes.debug: (context) => const DebugPage(),
        PageRoutes.settings: (context) => const SettingsPage(),
        PageRoutes.link: (context) => const LinkPage(),
      },
    );
  }
}
