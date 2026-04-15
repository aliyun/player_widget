// Copyright © 2025 Alibaba Cloud. All rights reserved.

// @author junHuiYe
// @date 2025/6/4 17:59
// @brief 全屏模式UI控件

part of 'package:aliplayer_widget/aliplayer_widget_lib.dart';

/// 播放器全屏视图
late AliPlayerWidgetController _fullController;

class AliPlayerFullScreenWidget extends StatefulWidget {
  final AliPlayerWidgetData data;

  final AliPlayerWidgetController controller;

  // 支持插槽配置
  final Map<SlotType, Function?> slotBuilders;

  /// 控制默认插槽中单个 UI 元素的显示与隐藏。
  ///
  /// 用于在不替换整个插槽的情况下，对插槽内部元素进行细粒度控制。
  /// 与 [slotBuilders] 不同，后者会完全替换整个插槽，
  /// [hiddenSlotElements] 仅对默认实现中的部分元素进行隐藏。
  ///
  /// Key 为插槽类型 [SlotType]，Value 为需要隐藏的元素 key 集合。
  /// 元素 key 由常量类定义，例如：[TopBarElements]、[BottomBarElements] 等。
  final Map<SlotType, Set<String>> hiddenSlotElements;

  const AliPlayerFullScreenWidget(
    this.controller,
    this.data, {
    super.key,
    this.slotBuilders = const {},
    this.hiddenSlotElements = const {},
  });

  @override
  State<AliPlayerFullScreenWidget> createState() =>
      AliPlayerScreenFullWidgetState();
}

class AliPlayerScreenFullWidgetState extends State<AliPlayerFullScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPip) {
        if (didPip) {
          return; // 如果已经处理了返回操作，则直接返回
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(color: Colors.black),
          width: double.infinity,
          child: AliPlayerWidget(
            _fullController,
            slotBuilders: widget.slotBuilders,
            hiddenSlotElements: widget.hiddenSlotElements,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 使用 FullScreenUtil 统一处理全屏系统 UI 设置
    FullScreenUtil.enterFullScreen();

    _fullController = AliPlayerWidgetController(context);
    _fullController.configure(widget.data).then((_) {
      widget.controller.syncStateTo(_fullController).then((_) {
        // 以指定位置起播
        _fullController._aliPlayer.setStartTime(
          widget.data.startTime,
          widget.data.seekMode,
        );
        _fullController.play();
      });
    });

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
