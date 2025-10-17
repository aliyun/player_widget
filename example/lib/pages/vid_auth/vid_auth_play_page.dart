// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2025/10/11
// Brief: VidAuth播放页面

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/constants/page_routes.dart';
import 'package:aliplayer_widget_example/manager/sp_manager.dart';
import 'package:aliplayer_widget_example/pages/link/link_constants.dart';
import 'package:aliplayer_widget_example/utils/toast_utils.dart';
import 'package:flutter/material.dart';

class VidAuthPlayPage extends StatefulWidget {
  const VidAuthPlayPage({super.key});

  @override
  State<StatefulWidget> createState() => _VidAuthPlayPageState();
}

class _VidAuthPlayPageState extends State<VidAuthPlayPage> {
  /// 播放器组件控制器
  late AliPlayerWidgetController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VidAuth播放'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _buildPlayWidget(),
    );
  }

  /// 构建播放器组件
  Widget _buildPlayWidget() {
    return AliPlayerWidget(_controller);
  }

  @override
  void initState() {
    super.initState();
    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController(context);

    // 获取保存的vid 及 playAuth
    var savedVidLink = SPManager.instance.getString(LinkConstants.vid);
    var savedPlayAuthLink = SPManager.instance.getString(LinkConstants.vidAuth);
    // 如果没有保存的链接，提示用户并跳转到 LinkPage
    if (savedVidLink == null ||
        savedVidLink.isEmpty ||
        savedPlayAuthLink == null ||
        savedPlayAuthLink.isEmpty) {
      final linkVidItem = LinkItem(
        name: LinkConstants.vid,
        route: PageRoutes.vidAuthPlay,
      );
      final linkPlayAuthItem = LinkItem(
        name: LinkConstants.vidAuth,
        route: PageRoutes.vidAuthPlay,
      );
      ToastUtils.showSetUpLinkSnackBar(
        context,
        linkVidItem,
        linkItemTwo: linkPlayAuthItem,
        message: '请先设置视频Vid及PlayAuth',
      );
      return;
    }

    final videoSource = VideoSourceFactory.createVidAuthSource(
        vid: savedVidLink, playAuth: savedPlayAuthLink);

    // 设置播放器组件数据
    final data = AliPlayerWidgetData(
      videoSource: videoSource,
      videoTitle: "VidAuth Play",
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
