// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/19
// Brief: 沉浸式列表播放页面

import 'package:aliplayer_widget_example/constants/demo_constants.dart';
import 'package:aliplayer_widget_example/model/video_info.dart';
import 'package:aliplayer_widget_example/preload/ali_player_preload.dart';
import 'package:aliplayer_widget_example/utils/http_util.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';

import 'short_video_item.dart';

/// 沉浸式列表播放页面
///
/// 使用 PreloadPageView 代替 PageView 来实现列表播放，
/// 因为 PreloadPageView 支持 item 的预加载，而 PageView 不能。
///
/// Use PreloadPageView instead of PageView to implement list playback,
/// because PreloadPageView supports preloading of items, while PageView cannot.
///
/// 如果你想尽可能多地使用Flutter原生解决方案而不是第三方库，
/// 你可以用PageView替换PreloadPageView，因为两者之间的接口差异相对较小。
///
/// If you want to use Flutter native solutions as much as possible instead of third-party libraries,
/// you can replace PreloadPageView with PageView, as the interface difference between the two is relatively small.
class ShortVideoPage extends StatelessWidget {
  const ShortVideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ShortVideoListPage());
  }
}

/// 沉浸式列表组件
class ShortVideoListPage extends StatefulWidget {
  const ShortVideoListPage({super.key});

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
  final PreloadPageController _pageController = PreloadPageController();

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

    // 监听页面变化
    _pageController.addListener(_onPageChanged);

    // 加载视频数据
    _loadVideoInfoList();
  }

  @override
  void dispose() {
    // 释放预加载器
    _aliPlayerPreload.destroy();

    // 释放资源
    _pageController.dispose();

    super.dispose();
  }

  /// 加载视频数据
  Future<void> _loadVideoInfoList() async {
    // 发起 HTTP 请求获取视频数据
    final response = await HTTPUtil.instance.get(
      DemoConstants.defaultVideoInfoListUrl,
    );

    if (response != null && response is List) {
      print("[$_tag][response]: $response");
      final List<dynamic> jsonData = response;
      setState(() {
        videoInfoList = jsonData
            .map((json) => VideoInfo(
                  id: json['id'],
                  videoUrl: json['url'],
                  coverUrl: json['coverUrl'],
                  type: json['type'] ?? "video",
                ))
            .toList();

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
      });
    } else {
      print("[$_tag][error]: Error loading video info list");
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 页面变化监听器
  void _onPageChanged() {
    // 获取当前页面索引
    final newPageIndex = _pageController.page?.round() ?? 0;

    // 如果当前页面索引和新页面索引相同，则不执行任何操作
    if (_currentIndex == newPageIndex) {
      return;
    }

    print("[$_tag]${'-' * 30}[index][$_currentIndex->$newPageIndex]");

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return PreloadPageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: videoInfoList.length,
      itemBuilder: (context, index) {
        final videoItem = videoInfoList[index];
        print("[$_tag][item][lifecycle][create][${videoItem.id}]");
        return ShortVideoItem(
          key: _itemKeys[index],
          videoInfo: videoItem,
          autoPlay: index == _currentIndex,
        );
      },
      preloadPagesCount: 1,
    );
  }
}
