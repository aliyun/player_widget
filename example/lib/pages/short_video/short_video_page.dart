// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/19
// Brief: 沉浸式列表播放页面

import 'package:aliplayer_widget_example/constants/demo_constants.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';
import 'package:aliplayer_widget_example/model/video_info.dart';
import 'package:aliplayer_widget_example/pages/short_video/short_video_util.dart';
import 'package:aliplayer_widget_example/preload/ali_player_preload.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'short_video_item.dart';

/// 沉浸式列表播放页面
///
/// 使用 PreloadPageView 或 PageView 来实现沉浸式视频列表播放。
/// 根据 `preload` 参数决定是否启用预加载功能。
///
/// ### PreloadPageView 的优势和劣势
/// - **优势**：
///   1. **预加载支持**：`PreloadPageView` 支持页面的预加载功能，可以提前加载相邻页面的内容（如视频），从而减少用户滑动时的延迟，提升用户体验。
///   2. **流畅性**：由于预加载的存在，滑动切换页面时更加流畅，尤其是在需要加载复杂内容（如视频）的场景下。
///   3. **适合高要求场景**：对于需要快速响应和高性能的场景（如短视频应用），`PreloadPageView` 是一个更好的选择。
/// - **劣势**：
///   1. **内存占用较高**：预加载会增加内存消耗，因为需要同时加载多个页面的内容。
///   2. **依赖第三方库**：`PreloadPageView` 并不是 Flutter 官方提供的组件，而是来自第三方库，可能会引入额外的维护成本或兼容性问题。
///
/// ### PageView 的优势和劣势
/// - **优势**：
///   1. **官方支持**：`PageView` 是 Flutter 官方提供的组件，稳定性高，文档和社区支持丰富。
///   2. **轻量级**：不支持预加载，因此内存占用较低，适合对性能要求不高的场景。
///   3. **简单易用**：接口设计简洁，易于集成和使用。
/// - **劣势**：
///   1. **缺乏预加载**：`PageView` 不支持预加载功能，可能导致用户滑动时出现卡顿或延迟，尤其是在需要加载复杂内容（如视频）的场景下。
///   2. **体验较差**：在需要快速响应的场景中，`PageView` 的表现可能不如 `PreloadPageView` 流畅。
///
/// 如果你需要在性能和资源消耗之间权衡，可以根据具体需求选择合适的组件。
class ShortVideoPage extends StatelessWidget {
  /// 是否启用预加载功能
  ///
  /// - `true`：使用 `PreloadPageView`，支持页面预加载。
  /// - `false`：使用 `PageView`，不支持页面预加载。
  final bool preload;

  const ShortVideoPage({
    super.key,
    this.preload = true, // 默认启用预加载
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShortVideoListPage(preload: preload),
    );
  }
}

/// 沉浸式列表组件
class ShortVideoListPage extends StatefulWidget {
  /// 是否启用预加载
  final bool preload;

  const ShortVideoListPage({
    super.key,
    required this.preload,
  });

  @override
  State<ShortVideoListPage> createState() => _ShortVideoListPageState();
}

class _ShortVideoListPageState extends State<ShortVideoListPage> {
  /// 日志标签
  static const String _tag = "ShortVideoPage";

  /// 视频数据源列表（每个 item 对应一个视频）
  late List<VideoInfo> videoInfoList;

  /// 播放器预加载器
  late AliPlayerPreload _aliPlayerPreload;

  /// PageController 用于监听当前页面和预加载下一个页面
  late PageController _pageController;

  /// PreloadPageController 用于 PreloadPageView
  late PreloadPageController _preloadPageController;

  /// 当前页面索引
  int _currentIndex = 0;

  /// 存储所有 ShortVideoItem 的 GlobalKey
  final List<GlobalKey<ShortVideoItemState>> _itemKeys = [];

  /// 是否正在加载数据
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 初始化预加载器
    _aliPlayerPreload = AliPlayerPreload(
      context: context,
      enableCoverUrlStrategy: true,
    );

    // 根据 preload 参数初始化控制器
    if (widget.preload) {
      _preloadPageController = PreloadPageController();
      _preloadPageController.addListener(_onPageChanged);
    } else {
      _pageController = PageController();
      _pageController.addListener(_onPageChanged);
    }

    // 加载视频数据
    _loadData();
  }

  @override
  void dispose() {
    // 释放预加载器
    _aliPlayerPreload.destroy();

    // 根据 preload 参数释放控制器
    if (widget.preload) {
      _preloadPageController.dispose();
    } else {
      _pageController.dispose();
    }

    super.dispose();
  }

  /// 加载视频数据
  Future<void> _loadData() async {
    try {
      // 从本地存储中获取视频数据列表的 URL
      final savedLink = SPManager.instance.getString(
        DemoConstants.keyDramaInfoListUrl,
      );

      if (savedLink != null) {
        // 加载剧集信息列表数据
        final dramaInfoList = await ShortVideoUtil.loadDramaInfoList(savedLink);
        // 从剧集信息列表中提取视频列表
        final videoList = ShortVideoUtil.getVideoInfoListFromDramaInfo(
          dramaInfoList?.firstOrNull,
        );

        setState(() {
          videoInfoList = videoList;
          _completeLoading();
        });
      } else {
        // 加载普通视频列表数据
        final videoList = await ShortVideoUtil.loadVideoInfoList(
          DemoConstants.defaultVideoInfoListUrl,
        );

        setState(() {
          videoInfoList = videoList;
          _completeLoading();
        });
      }
    } catch (e) {
      _handleLoadingError("Exception: $e");
    }
  }

  /// 完成加载后的公共操作
  void _completeLoading() {
    // 设置预加载器数据
    _aliPlayerPreload.setItems(videoInfoList);
    _aliPlayerPreload.moveTo(_currentIndex);

    // 动态初始化 GlobalKey
    _itemKeys.clear();
    _itemKeys.addAll(
      List.generate(
        videoInfoList.length,
        (_) => GlobalKey<ShortVideoItemState>(),
      ),
    );

    _isLoading = false;
  }

  /// 处理加载错误
  void _handleLoadingError(String errorMessage) {
    debugPrint("[$_tag][error]: $errorMessage");
    setState(() {
      _isLoading = false;
    });
  }

  /// 页面变化监听器
  void _onPageChanged() {
    // 获取当前页面索引
    final newPageIndex = widget.preload
        ? _preloadPageController.page?.round() ?? 0
        : _pageController.page?.round() ?? 0;

    // 如果当前页面索引和新页面索引相同，则不执行任何操作
    if (_currentIndex == newPageIndex) {
      return;
    }

    debugPrint("[$_tag]${'-' * 30}[index][$_currentIndex->$newPageIndex]");

    // 更新当前页面索引
    _currentIndex = newPageIndex;

    // 更新预加载器浮标
    _aliPlayerPreload.moveTo(newPageIndex);

    // 暂停所有后台 item
    _pauseAllExceptCurrent(newPageIndex);
  }

  /// 暂停所有后台 item
  void _pauseAllExceptCurrent(int currentIndex) {
    for (int i = 0; i < _itemKeys.length; i++) {
      if (i != currentIndex) {
        // 暂停非当前 item
        _itemKeys[i].currentState?.pause();
      } else if (i == currentIndex) {
        // 恢复当前 item
        _itemKeys[i].currentState?.resume();
      }
    }
  }

  // 提取公共的 itemBuilder 逻辑
  Widget _buildItem(BuildContext context, int index) {
    final videoItem = videoInfoList[index];
    debugPrint("[$_tag][item][lifecycle][create][${videoItem.id}]");
    return ShortVideoItem(
      key: _itemKeys[index],
      videoInfo: videoItem,
      autoPlay: index == _currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    // 根据 preload 参数选择使用 PreloadPageView 或 PageView
    return widget.preload
        ? PreloadPageView.builder(
            controller: _preloadPageController,
            scrollDirection: Axis.vertical,
            itemCount: videoInfoList.length,
            itemBuilder: _buildItem,
            preloadPagesCount: 1,
          )
        : PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videoInfoList.length,
            itemBuilder: _buildItem,
          );
  }
}
