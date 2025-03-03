// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/28
// Brief: AliPlayer Preload

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_aliplayer/flutter_aliplayer_medialoader.dart';
import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/model/video_info.dart';
import 'package:path_provider/path_provider.dart';

import 'ali_sliding_window.dart';

/// A class that manages video and cover preloading logic using the sliding window concept.
/// By using the idea of sliding windows, handle the logic of MediaLoader preloading to ensure the effect of full screen second opening
///
/// 使用滑动窗口概念管理视频和封面预加载逻辑的类。
class AliPlayerPreload {
  /// The tag for logging purposes.
  ///
  /// 日志标签
  static const String _logTag = 'AliPlayerPreload';

  /// Preload buffer duration in milliseconds.
  ///
  /// 预加载缓冲时长（毫秒）
  static const int _preloadBufferDuration = 3 * 1000;

  /// Preload bandwidth in bits per second.
  ///
  /// 预加载带宽（比特每秒）
  static const int _preloadBandwidth = 3 * 1024 * 1024;

  /// Media preload window configuration.
  ///
  /// 媒体预加载窗口配置
  static const List<int> _mediaPreloadWindows = [-1, 1, 2];

  /// Cover preload left window size.
  ///
  /// 封面预加载左侧窗口大小
  static const int _coverPreloadLeftWindowSize = 3;

  /// Cover preload right window size.
  ///
  /// 封面预加载右侧窗口大小
  static const int _coverPreloadRightWindowSize = 10;

  /// Video preloader instance.
  ///
  /// 视频预加载器实例
  late final AliSlidingWindow<String> _videoPreloader;

  /// Cover preloader instance.
  ///
  /// 封面预加载器实例
  late final AliSlidingWindow<String>? _coverPreloader;

  /// Build context.
  ///
  /// Flutter 的 BuildContext 上下文
  final BuildContext _context;

  /// Whether to enable cover URL strategy.
  ///
  /// 是否启用封面 URL 策略
  final bool _isCoverUrlStrategyEnabled;

  /// Media loader instance.
  ///
  /// 媒体加载器实例
  final FlutterAliPlayerMediaLoader _mediaLoader =
      FlutterAliPlayerMediaLoader();

  /// Constructor for AliPlayerPreload.
  ///
  /// 构造函数，初始化 AliPlayerPreload 实例
  AliPlayerPreload({
    required BuildContext context,
    required bool enableCoverUrlStrategy,
  })  : _context = context,
        _isCoverUrlStrategyEnabled = enableCoverUrlStrategy {
    _log("[init]");
    _initializeSlidingWindows();
    _initMediaLoader();
  }

  /// Initialize sliding windows after the instance is created.
  ///
  /// 初始化滑动窗口实例
  void _initializeSlidingWindows() {
    // Initialize the video preloader.
    _videoPreloader = AliSlidingWindow.withCustomItems(
      _mediaPreloadWindows,
      _preloadMedia,
      _cancelPreloadMedia,
      isValid: _isValidUrl,
      extra: 'VIDEO',
    );

    // Initialize the cover preloader if enabled.
    _coverPreloader = _isCoverUrlStrategyEnabled
        ? AliSlidingWindow.withWindowSize(
            _coverPreloadLeftWindowSize,
            _coverPreloadRightWindowSize,
            _preloadImage,
            null,
            isValid: _isValidUrl,
            extra: 'COVER',
          )
        : null;
  }

  /// Initialize media loader.
  ///
  /// 初始化媒体加载器
  Future<void> _initMediaLoader() async {
    // Setup global configuration.
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    AliPlayerWidgetGlobalSetting.setupMediaLoaderConfig(appDocumentsDir.path);

    // Set the listener for media loader events.
    _mediaLoader.setOnLoadStatusListener(
      (String url) {
        // OnCompletion block
        _log("[cbk][video][completion], $url", isError: false);
      },
      (String url) {
        // OnCancel block
        _log("[cbk][video][cancel], $url", isError: false);
      },
      (String url, int code, String msg) {
        // OnError block
      },
      (String url, String code, String msg) {
        // OnErrorV2 block
        _log("[cbk][video][errorV2], $url, $code, $msg", isError: true);
      },
    );
  }

  /// Release resources and clean up.
  ///
  /// 释放资源并清理
  void destroy() {
    _log("[api][destroy]");
    _videoPreloader.release();
    _coverPreloader?.release();

    _releaseMediaLoader();
  }

  /// Release media loader resources.
  ///
  /// 释放媒体加载器资源
  void _releaseMediaLoader() {
    // Clear the listener to avoid unnecessary callbacks.
    _mediaLoader.setOnLoadStatusListener(null, null, null, null);
  }

  /// Set video items (replace existing items).
  ///
  /// 设置视频项（替换现有项）
  void setItems(List<VideoInfo> items) {
    _log("[api][set], ${items.length}");
    _updateItems(items, overwrite: true);
  }

  /// Add video items (append to existing items).
  ///
  /// 添加视频项（追加到现有项）
  void addItems(List<VideoInfo> items) {
    _log("[api][add], ${items.length}");
    _updateItems(items, overwrite: false);
  }

  /// Move to a specific position in the item list.
  ///
  /// 移动到指定位置
  void moveTo(int position) {
    _log("[api][moveTo], $position");
    _videoPreloader.moveTo(position);
    _coverPreloader?.moveTo(position);
  }

  /// Update video and cover items.
  ///
  /// 更新视频和封面项
  void _updateItems(
    List<VideoInfo> items, {
    required bool overwrite,
  }) {
    if (items.isEmpty) return;

    final videoUrls = <String>[];
    final coverUrls = <String>[];

    for (final item in items) {
      if (_isValidUrl(item.videoUrl)) {
        videoUrls.add(item.videoUrl);
      }
      if (_isValidUrl(item.coverUrl)) {
        coverUrls.add(item.coverUrl);
      }
    }

    if (overwrite) {
      _videoPreloader.setItems(videoUrls);
      _coverPreloader?.setItems(coverUrls);
    } else {
      _videoPreloader.addItems(videoUrls);
      _coverPreloader?.addItems(coverUrls);
    }
  }

  /// Validate if a URL is valid.
  ///
  /// 验证 URL 是否有效
  static bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute;
  }

  /// Preload media using MediaLoader.
  ///
  /// 使用 MediaLoader 预加载媒体资源
  void _preloadMedia(String url) {
    Future.microtask(() async {
      try {
        _log("[preload][video][load], $url");
        // FIXME keria: Why do int values need to be passed as strings??? Niubility..
        _mediaLoader.load(url, "$_preloadBufferDuration");
      } catch (e) {
        _log("[preload][video][load][error], $e", isError: true);
      }
    });
  }

  /// Cancel media preloading.
  ///
  /// 取消媒体预加载
  void _cancelPreloadMedia(String url) {
    Future.microtask(() async {
      try {
        _log("[preload][video][cancel], $url");
        _mediaLoader.cancel(url);
      } catch (e) {
        _log("[preload][video][cancel][error], $e", isError: true);
      }
    });
  }

  /// Preload image using precacheImage.
  ///
  /// 使用 precacheImage 预加载图片
  void _preloadImage(String url) {
    Future.microtask(() async {
      _log("[preload][image], $url");
      await precacheImage(NetworkImage(url), _context, onError: (_, __) {
        _log("[cbk][image][error], $url", isError: true);
      });
    });
  }

  /// Log information with a consistent format.
  ///
  /// 使用统一格式记录日志信息。
  static void _log(String message, {bool isError = false}) {
    debugPrint("[$_logTag][${isError ? 'E' : 'I'}] $message");
  }
}
