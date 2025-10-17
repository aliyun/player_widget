// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/12
// Brief: 播放器 seek 缩略图控件

import 'package:aliplayer_widget/utils/format_util.dart';
import 'package:flutter/material.dart';

/// 播放器 seek 缩略图控件
///
/// A widget that displays a thumbnail and time information during seeking.
class AliPlayerSeekThumbnailWidget extends StatefulWidget {
  /// 缩略图的图片，可以为空
  ///
  /// Thumbnail image, can be null
  final MemoryImage? thumbnail;

  /// 当前 seek 到的时间
  ///
  /// Current seek time
  final Duration currentSeekTime;

  /// 视频的总时长
  ///
  /// Total video duration
  final Duration totalDuration;

  /// 控制控件的可见性
  ///
  /// Visibility of the widget
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
    // 如果控件不可见，直接返回空组件，避免不必要的构建
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThumbnailImage(),
          const SizedBox(height: 8.0),
          _buildTimeText(),
        ],
      ),
    );
  }

  /// 构建缩略图图片
  ///
  /// Build the thumbnail image
  Widget _buildThumbnailImage() {
    return widget.thumbnail != null
        ? Image(
            width: 90,
            height: 160,
            image: widget.thumbnail!,
            fit: BoxFit.cover,
          )
        : const SizedBox.shrink();
  }

  /// 构建时间文本
  ///
  /// Build the time text
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
