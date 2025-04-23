// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/19
// Brief: 单个播放项组件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/model/video_info.dart';

import 'package:flutter/material.dart';

/// 单个播放项组件
class ShortVideoItem extends StatefulWidget {
  /// 视频数据源
  final VideoInfo videoInfo;

  /// 是否自动播放
  final bool autoPlay;

  const ShortVideoItem({
    super.key,
    required this.videoInfo,
    this.autoPlay = false,
  });

  @override
  State<ShortVideoItem> createState() => ShortVideoItemState();
}

class ShortVideoItemState extends State<ShortVideoItem> {
  /// 日志标签
  static const String _tag = "ShortVideoItem";

  /// 播放器组件控制器
  late AliPlayerWidgetController _controller;

  @override
  void initState() {
    super.initState();
    debugPrint("[$_tag][lifecycle][initState]: ${widget.videoInfo.id}");

    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController(context);

    // 设置播放器视频源
    final videoSource = VideoSourceFactory.createUrlSource(
      widget.videoInfo.videoUrl,
    );
    // 设置播放器组件数据
    final data = AliPlayerWidgetData(
      sceneType: SceneType.listPlayer,
      videoSource: videoSource,
      coverUrl: widget.videoInfo.coverUrl,
      autoPlay: widget.autoPlay,
    );
    _controller.configure(data);
  }

  @override
  void dispose() {
    debugPrint("[$_tag][lifecycle][dispose]: ${widget.videoInfo.id}");

    // 销毁播放控制器
    _controller.destroy();

    super.dispose();
  }

  /// 暂停播放
  void pause() {
    debugPrint("[$_tag][paused]: ${widget.videoInfo.id}");

    _controller.pause();
  }

  /// 恢复播放
  void resume() {
    debugPrint("[$_tag][resumed]: ${widget.videoInfo.id}");

    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: _buildPlayWidget(),
    );
  }

  /// 构建播放器组件
  Widget _buildPlayWidget() {
    return AliPlayerWidget(_controller);
  }
}
