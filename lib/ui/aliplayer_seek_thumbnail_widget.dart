// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/12
// Brief: 播放器 seek 缩略图控件

import 'package:aliplayer_widget/utils/format_util.dart';
import 'package:flutter/material.dart';

/// 播放器 seek 缩略图控件
class AliPlayerSeekThumbnailWidget extends StatefulWidget {
  // 缩略图的图片，可以为空
  final MemoryImage? thumbnail;

  // 当前 seek 到的时间
  final Duration currentSeekTime;

  // 视频的总时长
  final Duration totalDuration;

  // 控制控件的可见性
  final bool isVisible;

  const AliPlayerSeekThumbnailWidget({
    required this.isVisible,
    required this.currentSeekTime,
    required this.totalDuration,
    this.thumbnail,
    super.key,
  });

  @override
  State<AliPlayerSeekThumbnailWidget> createState() =>
      _AliPlayerSeekThumbnailWidgetState();
}

class _AliPlayerSeekThumbnailWidgetState
    extends State<AliPlayerSeekThumbnailWidget> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThumbnailImage(),
            const SizedBox(height: 8.0),
            _buildTimeText(),
          ],
        ),
      ),
    );
  }

  /// 构建缩略图图片
  Widget _buildThumbnailImage() {
    return widget.thumbnail != null
        ? Image(
            image: widget.thumbnail!,
            fit: BoxFit.cover,
          )
        : const SizedBox.shrink();
  }

  /// 构建时间文本
  Widget _buildTimeText() {
    return Text(
      '${FormatUtil.formatDuration(widget.currentSeekTime)} / ${FormatUtil.formatDuration(widget.totalDuration)}',
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 状态更新回调
  /// 当 Widget 的状态被更新时，该方法被调用。
  ///
  /// Called when the state of the widget is updated.
  @override
  void didUpdateWidget(covariant AliPlayerSeekThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update if visibility changes or if any other relevant property changes
    if (oldWidget.isVisible != widget.isVisible ||
        oldWidget.currentSeekTime != widget.currentSeekTime ||
        oldWidget.thumbnail != widget.thumbnail) {
      setState(() {});
    }
  }
}
