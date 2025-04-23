// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/18
// Brief: 长视频播放页面

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/constants/demo_constants.dart';
import 'package:aliplayer_widget_example/pages/link/link_constants.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';
import 'package:flutter/material.dart';

/// 长视频播放页面
///
/// A page for playing long videos using AliPlayerWidget.
class LongVideoPage extends StatefulWidget {
  const LongVideoPage({super.key});

  @override
  State<StatefulWidget> createState() => _LongVideoPageState();
}

/// 负责管理长视频播放页面的状态
///
/// Manages the state of the long video playback page.
class _LongVideoPageState extends State<LongVideoPage> {
  /// 播放器组件控制器
  late AliPlayerWidgetController _controller;

  /// 构建主体内容
  ///
  /// Builds the UI of the demo page, including an AppBar and the AliPlayer widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPlayWidget(),
      backgroundColor: Colors.white,
    );
  }

  /// 构建播放器组件
  Widget _buildPlayWidget() {
    return AliPlayerWidget(_controller);
  }

  /// 初始化状态
  /// StatefulWidget 的状态类中第一个被调用的方法，用于初始化状态，可以执行一些一次性的初始化工作
  ///
  /// Called when the state is first created. Used for one-time initialization.
  @override
  void initState() {
    super.initState();

    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController(context);

    // 获取保存的链接
    var savedLink = SPManager.instance.getString(LinkConstants.vod);
    // 如果没有保存的链接，则使用默认链接
    if (savedLink == null || savedLink.isEmpty) {
      savedLink = DemoConstants.sampleVideoUrl;
    }

    // 获取保存的缩略图链接
    final thumbnailUrl = SPManager.instance.getString(LinkConstants.thumbnail);

    // 设置播放器视频源
    final videoSource = VideoSourceFactory.createUrlSource(savedLink);
    // 设置播放器组件数据
    final data = AliPlayerWidgetData(
      videoSource: videoSource,
      thumbnailUrl: thumbnailUrl ?? "",
      videoTitle: "Long Video Title",
    );
    _controller.configure(data);
  }

  /// 清理资源
  ///
  /// Called when the widget is removed from the tree permanently. Used to release resources.
  @override
  void dispose() {
    // 销毁播放控制器
    _controller.destroy();

    super.dispose();
  }
}
