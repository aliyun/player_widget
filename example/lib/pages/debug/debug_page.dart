// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/10
// Brief: A demo page for AliPlayerWidget, showcasing how to integrate and use it in a Flutter app.

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget_example/constants/demo_constants.dart';
import 'package:flutter/material.dart';

/// AliPlayerWidget 演示页面，用于展示如何在 Flutter 应用中集成和使用 AliPlayerWidget 组件
///
/// This widget demonstrates the integration of the AliPlayerWidget in a Flutter app.
/// It provides a simple UI with an AppBar and the AliPlayerWidget embedded in the body.
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<StatefulWidget> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> with WidgetsBindingObserver {
  /// 描述 VOD 组件的功能和特点
  ///
  /// A detailed description of the VOD component's features and capabilities.
  static const String _vodComponentDescription =
      'A powerful and flexible VOD component for Flutter applications.\n'
      'It integrates with flutter_aliplayer to provide high-quality video playback, seamless streaming, '
      'and a rich set of features for both live and on-demand video content.\n'
      'Whether you are building a video playback solution for education, entertainment, or any other application, '
      'it makes it easy to deliver an engaging video experience.\n';

  /// 播放器组件控制器
  late AliPlayerWidgetController _controller;

  /// 构建主体内容
  ///
  /// Builds the UI of the demo page, including an AppBar and the AliPlayer widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Debug Page"),
      ),
      body: Column(
        children: [
          _buildDescriptionText(),
          _buildPlayWidget(),
          _buildBottomContainer(),
        ],
      ),
      backgroundColor: Colors.black,
    );
  }

  /// 构建播放器组件
  Widget _buildPlayWidget() {
    return AliPlayerWidget(_controller);
  }

  /// 构建描述文本
  Widget _buildDescriptionText() {
    return Expanded(
      child: Container(
        color: Colors.blue,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 20,
          ),
          child: Text(
            _vodComponentDescription,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建底部容器
  Widget _buildBottomContainer() {
    /// Add a Container with blue color for 20dp spacing below the AliPlayerWidget
    return Container(
      height: 90.0,
      color: Colors.yellow,
    );
  }

  /// 初始化状态
  /// StatefulWidget 的状态类中第一个被调用的方法，用于初始化状态，可以执行一些一次性的初始化工作
  ///
  /// Called when the state is first created. Used for one-time initialization.
  @override
  void initState() {
    super.initState();

    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController();

    // 设置播放器视频源
    final videoSource = VideoSourceFactory.createVidAuthSource(
      vid: DemoConstants.sampleVid,
      playAuth: DemoConstants.samplePlayAuth,
    );
    // 设置播放器组件数据
    final data = AliPlayerWidgetData(videoSource: videoSource);
    _controller.configure(data);
  }

  /// 清理资源
  /// 在 StatefulWidget 被从树中移除并销毁时调用的，这个方法用于清理资源。
  ///
  /// Called when the widget is removed from the tree permanently. Used to release resources.
  @override
  void dispose() {
    // 销毁播放控制器
    _controller.destroy();

    super.dispose();
  }
}
