// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/12
// Brief: 播放器 seek 缩略图控件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/utils/format_util.dart';
import 'package:flutter/material.dart';

/// 播放器 seek 缩略图控件
///
/// A widget that displays a thumbnail and time information during seeking.
class SeekThumbnailWidget extends StatefulWidget {
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

  /// 获取播放器视图宽高
  final Size? videoSize;

  /// 是否启用底部边距
  final bool hasBottomMargin;

  /// 是否是横竖屏
  final Orientation orientation;

  const SeekThumbnailWidget({
    required this.isVisible,
    required this.currentSeekTime,
    required this.totalDuration,
    required this.orientation,
    this.thumbnail,
    this.videoSize,
    this.hasBottomMargin = false,
    super.key,
  });

  @override
  State<SeekThumbnailWidget> createState() => _SeekThumbnailWidgetState();
}

class _SeekThumbnailWidgetState extends State<SeekThumbnailWidget> {
  @override
  Widget build(BuildContext context) {
    // 如果控件不可见，直接返回空组件，避免不必要的构建
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    // 一次性获取隐藏配置，避免重复遍历 widget tree
    // Get hidden config once to avoid repeated widget tree traversal
    final hiddenElements = SlotManager.getHiddenElements(
      context,
      SlotType.seekThumbnail,
    );

    // 检查元素是否可见
    final showThumbnail = hiddenElements.isElementVisible(
      SeekThumbnailElements.thumbnail,
    );
    final showTimeText = hiddenElements.isElementVisible(
      SeekThumbnailElements.timeText,
    );

    // 如果所有元素都被隐藏，返回空组件
    if (!showThumbnail && !showTimeText) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: PlayerStyles.kSeekThumbnailBottomOffset,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showThumbnail) _buildThumbnailImage(),
            // 只有当缩略图和时间文本都显示时才添加间距
            // Only add spacing when both thumbnail and time text are visible
            if (showThumbnail && showTimeText)
              const SizedBox(height: PlayerStyles.kThumbnailTimeSpacing),
            if (showTimeText) _buildTimeText(),

            // 底部边距要求，适配 BottomBar 显示/隐藏
            // Add bottom margin for BottomBar show/hide adaptation
            if ((widget.orientation == Orientation.landscape) &&
                widget.hasBottomMargin)
              const SizedBox(
                height: PlayerStyles.kBottomBarHeight,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建缩略图图片
  ///
  /// Build the thumbnail image
  Widget _buildThumbnailImage() {
    double aspectRatio = PlayerStyles.kDefaultThumbnailAspectRatio;
    final size = widget.videoSize;
    if (size != null && size.width > 0 && size.height > 0) {
      aspectRatio = size.width / size.height;
    }

    if (widget.thumbnail == null) {
      return const SizedBox.shrink();
    }

    // 3. 构建带圆角的缩略图
    return ClipRRect(
      borderRadius: BorderRadius.circular(PlayerStyles.kThumbnailBorderRadius),
      child: SizedBox(
        width: PlayerStyles.kThumbnailWidth,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image(
            image: widget.thumbnail!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  /// 构建时间文本
  ///
  /// Build the time text
  Widget _buildTimeText() {
    return Text(
      '${FormatUtil.formatDuration(widget.currentSeekTime)}\u00A0/\u00A0${FormatUtil.formatDuration(widget.totalDuration)}',
      style: const TextStyle(
        fontSize: PlayerStyles.kSeekThumbnailTimeFontSize,
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
  void didUpdateWidget(covariant SeekThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update if visibility changes or if any other relevant property changes
    if (oldWidget.isVisible != widget.isVisible ||
        oldWidget.currentSeekTime != widget.currentSeekTime ||
        oldWidget.thumbnail != widget.thumbnail) {
      setState(() {});
    }
  }
}

/// 构建 seek 缩略图插槽的默认实现。
/// Builds the default seek thumbnail slot content.
///
/// 监听播放进度、总时长、拖拽状态、缩略图等变化，
/// 在拖拽进度条时显示对应时间点的缩略图和时间文本。
///
/// Listens to playback progress, duration, drag state, and thumbnail changes;
/// displays a thumbnail and time text at the corresponding seek position.
Widget buildSeekThumbnailSlot(
  SlotBuildContext ctx,
  double width,
  double height,
) {
  // 监听播放进度、总时长、是否正在拖拽、当前拖拽进度等
  Listenable listener = Listenable.merge([
    ctx.controller.totalDurationNotifier,
    ctx.controller.thumbnailNotifier,
    ctx.controller.isDraggingNotifier,
    ctx.controller.currentSeekTimeNotifier,
    ctx.controller.videoSizeNotifier,
  ]);
  return ListenableBuilder(
    listenable: listener,
    builder: (context, _) {
      final totalDuration = ctx.controller.totalDurationNotifier.value;
      final thumbnail = ctx.controller.thumbnailNotifier.value;
      final isDragging = ctx.controller.isDraggingNotifier.value;
      final currentSeekTime = ctx.controller.currentSeekTimeNotifier.value;
      final videoWidthHeight = ctx.controller.videoSizeNotifier.value;

      return SeekThumbnailWidget(
        isVisible: isDragging,
        currentSeekTime: currentSeekTime,
        totalDuration: totalDuration,
        thumbnail: thumbnail,
        orientation: MediaQuery.of(context).orientation,
        videoSize: videoWidthHeight,
        hasBottomMargin: ctx.animationManager.isVisible,
      );
    },
  );
}
