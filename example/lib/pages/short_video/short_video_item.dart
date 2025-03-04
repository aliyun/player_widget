// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/19
// Brief: 单个播放项组件

import 'dart:math';

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
    print("[$_tag][lifecycle][initState]: ${widget.videoInfo.id}");

    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController(context);

    final data = AliPlayerWidgetData(
      sceneType: SceneType.listPlayer,
      videoUrl: widget.videoInfo.videoUrl,
      coverUrl: widget.videoInfo.coverUrl,
      autoPlay: widget.autoPlay,
    );
    _controller.configure(data);
  }

  @override
  void dispose() {
    print("[$_tag][lifecycle][dispose]: ${widget.videoInfo.id}");

    // 销毁播放控制器
    _controller.destroy();

    super.dispose();
  }

  /// 暂停播放
  void pause() {
    print("[$_tag][paused]: ${widget.videoInfo.id}");

    _controller.pause();
  }

  /// 恢复播放
  void resume() {
    print("[$_tag][resumed]: ${widget.videoInfo.id}");

    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: _buildPlayWidget(),
          ),
        ],
      ),
    );
  }

  /// 构建播放器组件
  Widget _buildPlayWidget() {
    return AliPlayerWidget(
      _controller,
      overlays: [
        _buildRightActionPanel(),
      ],
    );
  }

  /// 构建右侧操作栏
  Widget _buildRightActionPanel() {
    final random = Random();
    const maxValue = 2 ^ 63 - 1;
    return Positioned(
      right: 16,
      bottom: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildActionButton(
            Icons.favorite_outline,
            random.nextInt(maxValue),
            () {
              // TODO: favorite feature need to be implemented.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('favorite feature need to be implemented.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            Icons.comment_rounded,
            random.nextInt(maxValue),
            () {
              // TODO: comment feature need to be implemented.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('comment feature need to be implemented.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildActionButton(
            Icons.share,
            random.nextInt(maxValue),
            () {
              // TODO: share feature need to be implemented.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('share feature need to be implemented.'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 构建单个操作按钮
  Widget _buildActionButton(IconData icon, int count, VoidCallback? onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            icon,
            size: 36,
            color: Colors.white,
          ),
          onPressed: onTap,
        ),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
