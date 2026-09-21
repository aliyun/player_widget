// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: wyq
// Date: 2026/9/4
// Brief: AI 教育场景章节按钮插槽

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:flutter/material.dart';

/// AI 教育场景章节按钮插槽
///
/// 位于播放器左下角区域，点击后通过 [onTap] 回调通知父组件展开/收起章节面板。
/// 仅当章节或 AI 解析数据可用、控制栏可见且非全屏时显示。
class ChapterButtonWidget extends StatefulWidget {
  /// 播放器组件控制器
  final AliPlayerWidgetController controller;

  /// 按钮点击回调
  final VoidCallback? onTap;

  const ChapterButtonWidget({
    super.key,
    required this.controller,
    this.onTap,
  });

  @override
  State<ChapterButtonWidget> createState() => _ChapterButtonWidgetState();
}

class _ChapterButtonWidgetState extends State<ChapterButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.controller.isFullScreenNotifier,
        widget.controller.controlBarVisibleNotifier,
      ]),
      builder: (context, _) {
        final isFullScreen = widget.controller.isFullScreenNotifier.value;

        final isControlBarVisible =
            widget.controller.controlBarVisibleNotifier.value;

        // 仅当章节数据可用、控制栏可见且非全屏时显示按钮
        if (!isControlBarVisible || isFullScreen) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 96,
          left: 20,
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: Image.asset(
              'assets/icons/ic_chapter_show.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
