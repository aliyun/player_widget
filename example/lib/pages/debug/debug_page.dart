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
  /// 播放器组件控制器
  late AliPlayerWidgetController _controller;

  /// 构建主体内容
  ///
  /// Builds the UI of the demo page, including an AppBar and the AliPlayer widget.
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: _buildAppBar(orientation),
          body: _buildContentBody(orientation),
          backgroundColor: Colors.black,
        );
      },
    );
  }

  /// 构建 AppBar，横屏模式下不显示
  AppBar? _buildAppBar(Orientation orientation) {
    return orientation == Orientation.portrait
        ? AppBar(
            title: const Text("Debug Page"),
          )
        : null;
  }

  /// 构建主体内容
  Widget _buildContentBody(Orientation orientation) {
    return orientation == Orientation.portrait
        ? Column(
            children: [
              _buildDescriptionText(),
              _buildPlayWidget(),
              _buildBottomContainer(),
            ],
          )
        : _buildPlayWidget();
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
            DemoConstants.vodComponentDescription,
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

    // 添加观察者
    WidgetsBinding.instance.addObserver(this);

    // 初始化播放器组件控制器
    _controller = AliPlayerWidgetController(context);

    // 设置播放器组件数据
    AliPlayerWidgetData data = AliPlayerWidgetData(
      videoUrl: DemoConstants.sampleVideoUrl,
    );
    _controller.configure(data);
  }

  /// 清理资源
  /// 在 StatefulWidget 被从树中移除并销毁时调用的，这个方法用于清理资源。
  ///
  /// Called when the widget is removed from the tree permanently. Used to release resources.
  @override
  void dispose() {
    // 移除观察者
    WidgetsBinding.instance.removeObserver(this);

    // 销毁播放控制器
    _controller.destroy();

    super.dispose();
  }
}
