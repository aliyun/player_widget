/**
 * Copyright © 2025 Alibaba Cloud. All rights reserved.
 * @author junhuiYe
 * @date 2025/6/4 17:59
 * @brief 全屏模式UI控件
 */
part of '../aliplayer_widget_lib.dart';

/// 播放器全屏视图
class AliPlayerFullScreenWidget extends StatefulWidget {
  late AliPlayerWidgetData data;

  final AliPlayerWidgetController controller;

  AliPlayerFullScreenWidget(
    this.controller,
    this.data, {
    super.key,
  });

  State<AliPlayerFullScreenWidget> createState() =>
      AliPlayerScreenFullWidgetState();
}

class AliPlayerScreenFullWidgetState extends State<AliPlayerFullScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(color: Colors.black),
          width: double.infinity,
          child: AliPlayerWidget(_fullController),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 隐藏状态栏和导航栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 锁定屏幕方向为横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // 左横屏
      DeviceOrientation.landscapeRight, // 右横屏
    ]);

    _fullController = AliPlayerWidgetController(context);
    _fullController.configure(widget.data);

    // 以指定位置起播
    _fullController._aliPlayer
        .setStartTime(widget.data.startTime, widget.data.seekMode);
    _fullController.play();
    // 暂停竖屏页面视频
    widget.controller.pause();
  }

  /// 清理资源
  /// 在 StatefulWidget 被从树中移除并销毁时调用的，这个方法用于清理资源。
  ///
  /// Called when the widget is removed from the tree permanently. Used to release resources.
  @override
  void dispose() {
    logi("[lifecycle] dispose");
    super.dispose();
  }
}
