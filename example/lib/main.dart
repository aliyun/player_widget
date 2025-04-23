// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/6
// Brief: The home page of the aliplayer_widget_example app.

import 'dart:async';
import 'package:aliplayer_widget_example/constants/page_routes.dart';
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
    runApp(const MyApp());
  }, (error, stackTrace) {
    debugPrint('[AliPlayerWidget][fatal][error]: $error, $stackTrace');
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
        PageRoutes.home: (_) => const HomePage(),
        PageRoutes.longVideo: (_) => const LongVideoPage(),
        PageRoutes.shortVideo: (_) => const ShortVideoPage(preload: false),
        PageRoutes.preloadShortVideo: (_) => const ShortVideoPage(),
        PageRoutes.liveLandscape: (_) => const LivePage(),
        PageRoutes.livePortrait: (_) => const LivePage(isPortrait: true),
        PageRoutes.debug: (_) => const DebugPage(),
        PageRoutes.settings: (_) => const SettingsPage(),
        PageRoutes.link: (_) => const LinkPage(),
      },
    );
  }
}
