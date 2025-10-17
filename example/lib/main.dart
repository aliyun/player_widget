// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/6
// Brief: The home page of the aliplayer_widget_example app.

import 'dart:async';
import 'dart:io';
import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/constants/page_routes.dart';
import 'package:aliplayer_widget_example/pages/debug/debug_page.dart';
import 'package:aliplayer_widget_example/pages/external_subtitle/external_subtitle_page.dart';
import 'package:aliplayer_widget_example/pages/home/home_page.dart';
import 'package:aliplayer_widget_example/pages/link/link_page.dart';
import 'package:aliplayer_widget_example/pages/live/live_page.dart';
import 'package:aliplayer_widget_example/pages/long_video/long_video_page.dart';
import 'package:aliplayer_widget_example/pages/settings/settings_page.dart';
import 'package:aliplayer_widget_example/pages/short_video/short_video_page.dart';
import 'package:aliplayer_widget_example/pages/vid_auth/vid_auth_play_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 AliPlayer Widget 全局设置
  initializeGlobalSettings();

  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stackTrace) {
    debugPrint('[AliPlayerWidget][fatal][error]: $error, $stackTrace');
  });
}

/// 初始化 aliplayer_widget 全局配置，包括存储路径和基础设置。
///
/// 根据运行平台智能选择存储目录：
/// - **Android**：优先使用外部存储（[getExternalCacheDirectories] 和 [getExternalStorageDirectory]），
///   以支持更大缓存空间和共享访问（需注意 Android 10+ 分区存储限制）。
/// - **iOS**：使用应用沙盒内的 [getApplicationCacheDirectory] 和 [getApplicationDocumentsDirectory]，
///   符合 Apple 安全规范，确保应用合规上架。
///
/// 此函数应在应用启动早期调用，且仅执行一次。
Future<void> initializeGlobalSettings() async {
  // 初始化全局配置
  await AliPlayerWidgetGlobalSetting.setupConfig();

  String? cachePath;
  String? filesPath;

  if (Platform.isAndroid) {
    // Android: 尝试使用外部存储
    final externalCacheDirs = await getExternalCacheDirectories();
    cachePath = externalCacheDirs?.isNotEmpty == true
        ? externalCacheDirs?.first.path
        : null;

    final externalStorageDir = await getExternalStorageDirectory();
    filesPath = externalStorageDir?.path;

    // 若外部存储不可用，回退到内部应用目录（兜底）
    if (cachePath == null || filesPath == null) {
      final internalCache = await getApplicationCacheDirectory();
      final internalDocs = await getApplicationDocumentsDirectory();
      cachePath ??= internalCache.path;
      filesPath ??= internalDocs.path;
    }
  } else {
    // iOS / 其他平台：使用标准应用沙盒目录
    final cacheDir = await getApplicationCacheDirectory();
    final docsDir = await getApplicationDocumentsDirectory();
    cachePath = cacheDir.path;
    filesPath = docsDir.path;
  }

  // 设置全局存储路径
  AliPlayerWidgetGlobalSetting.setStoragePaths(
    cachePath: cachePath,
    filesPath: filesPath,
  );
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
        PageRoutes.vidAuthPlay: (_) => const VidAuthPlayPage(),
        PageRoutes.externalSubtitle: (_) => const ExternalSubtitlePage(),
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
