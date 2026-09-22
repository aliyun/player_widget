// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/12
// Brief: 播放器进度条控件

import 'package:aliplayer_widget/theme/theme.dart';
import 'package:aliplayer_widget/utils/vibration_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 播放器进度条控件，用于显示视频播放进度和缓冲进度
///
/// 提供拖拽和点击功能以调整播放位置，并支持边界振动反馈。
/// 内部使用 CustomPaint 绘制，不依赖 Material Slider。
class CustomVideoSlider extends StatefulWidget {
  /// 当前播放位置
  final Duration currentPosition;

  /// 视频总时长
  final Duration totalDuration;

  /// 已缓冲的位置
  final Duration bufferedPosition;

  /// 拖拽过程中触发的回调
  final ValueChanged<Duration>? onDragUpdate;

  /// 拖拽结束时触发的回调
  final ValueChanged<Duration>? onDragEnd;

  /// seek结束时触发的回调
  final ValueChanged<Duration>? onSeekEnd;

  /// orientation 默认样式控制
  final Orientation orientation;

  /// 章节标记点归一化位置列表（0.0 ~ 1.0）
  ///
  /// Normalized positions (0.0 ~ 1.0) of chapter markers on the progress bar.
  final List<double>? chapterMarkerPositions;

  /// 章节标记点击回调（传入归一化位置 0.0 ~ 1.0）
  ///
  /// Callback when a chapter marker is tapped, with the normalized position.
  final ValueChanged<double>? onMarkerTap;

  const CustomVideoSlider({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.bufferedPosition,
    this.onDragUpdate,
    this.onDragEnd,
    this.onSeekEnd,
    this.orientation = Orientation.portrait,
    this.chapterMarkerPositions,
    this.onMarkerTap,
  });

  @override
  State<CustomVideoSlider> createState() => _CustomVideoSliderState();
}

class _CustomVideoSliderState extends State<CustomVideoSlider> {
  // 当前拖拽的进度百分比
  double _dragPositionPercent = 0.0;

  // 是否正在拖拽
  bool _isDragging = false;

  // 缓存计算结果
  late int _totalDurationInMillis;
  late int _currentPositionInMillis;
  late int _bufferedPositionInMillis;

  @override
  void initState() {
    super.initState();
    _updateCachedValues();
  }

  /// 更新缓存的毫秒数值
  void _updateCachedValues() {
    _totalDurationInMillis = widget.totalDuration.inMilliseconds;
    _currentPositionInMillis = widget.currentPosition.inMilliseconds;
    _bufferedPositionInMillis = widget.bufferedPosition.inMilliseconds;
  }

  /// 当前 thumb 半径
  double get _thumbRadius => widget.orientation == Orientation.portrait
      ? PlayerStyles.kSliderPortraitThumbRadius
      : PlayerStyles.kSliderLandscapeThumbRadius;

  /// 当前进度百分比
  double get _progressPercent => _totalDurationInMillis > 0
      ? (_currentPositionInMillis / _totalDurationInMillis).clamp(0.0, 1.0)
      : 0.0;

  /// 当前缓冲百分比
  double get _bufferPercent => _totalDurationInMillis > 0
      ? (_bufferedPositionInMillis / _totalDurationInMillis).clamp(0.0, 1.0)
      : 0.0;

  /// 实际用于显示进度的百分比（拖拽时显示拖拽位置）
  double get _displayPercent =>
      _isDragging ? _dragPositionPercent : _progressPercent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: _onTapUp,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: CustomPaint(
            painter: _CustomVideoSliderPainter(
              progressPercent: _displayPercent,
              bufferPercent: _bufferPercent,
              thumbRadius: _thumbRadius,
              chapterMarkerPositions: widget.chapterMarkerPositions,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        );
      },
    );
  }

  /// 将本地 x 坐标转换为归一化进度（0.0 ~ 1.0）
  double _percentFromLocalDx(double dx, double width) {
    if (width <= _thumbRadius * 2) return 0.0;
    final effectiveWidth = width - _thumbRadius * 2;
    final clampedDx = dx.clamp(_thumbRadius, width - _thumbRadius);
    return ((clampedDx - _thumbRadius) / effectiveWidth).clamp(0.0, 1.0);
  }

  /// 检查点击位置是否命中某个章节标记点
  ///
  /// 当多个标记点命中区域重叠时，返回距离点击位置最近的那个。
  double? _hitMarkerPosition(double dx, double width) {
    final positions = widget.chapterMarkerPositions;
    if (positions == null || positions.isEmpty || width <= 0) return null;

    const hitRadius = PlayerStyles.kChapterMarkerHitRadius;
    double? closestPosition;
    var minDistance = double.infinity;

    for (final position in positions) {
      final markerX = _thumbRadius + position * (width - _thumbRadius * 2);
      final distance = (dx - markerX).abs();
      if (distance <= hitRadius && distance < minDistance) {
        minDistance = distance;
        closestPosition = position;
      }
    }
    return closestPosition;
  }

  /// 点击轨道时 seek
  ///
  /// 在 tap-up 时触发（而非 tap-down）：若手势被水平拖拽识别器认领，
  /// [onTapUp] 不会回调，因此拖拽与点击不会重复 seek。若在 tap-down 即 seek，
  /// 拖拽开始时会先跳到按下点、拖拽结束再 seek 一次，产生双重 seek。
  void _onTapUp(TapUpDetails details) {
    final width = context.size?.width ?? 0.0;
    if (width <= 0) return;

    final markerPosition = _hitMarkerPosition(details.localPosition.dx, width);
    if (markerPosition != null) {
      widget.onMarkerTap?.call(markerPosition);
      return;
    }

    final percent = _percentFromLocalDx(details.localPosition.dx, width);
    final duration = Duration(
      milliseconds: (percent * _totalDurationInMillis).toInt(),
    );
    widget.onSeekEnd?.call(duration);
  }

  /// 开始拖拽
  void _onDragStart(DragStartDetails details) {
    final width = context.size?.width ?? 0.0;
    if (width <= 0) return;

    setState(() {
      _isDragging = true;
      _dragPositionPercent =
          _percentFromLocalDx(details.localPosition.dx, width);
    });
    _notifyDragUpdate(_dragPositionPercent);
  }

  /// 更新拖拽位置
  void _onDragUpdate(DragUpdateDetails details) {
    final width = context.size?.width ?? 0.0;
    if (width <= 0) return;

    final lastValue = _dragPositionPercent;
    final newValue = _percentFromLocalDx(details.localPosition.dx, width);

    // 仅当进度变化超过 1 像素对应的百分比时才 setState，
    // 避免拖拽过程中频繁重建 Widget，同时保持视觉跟手。
    final pixelThreshold = 1.0 / width;
    if ((newValue - lastValue).abs() < pixelThreshold) {
      _dragPositionPercent = newValue;
      _notifyDragUpdate(newValue);
      return;
    }

    setState(() {
      _isDragging = true;
      _dragPositionPercent = newValue;
    });

    if ((newValue - lastValue).abs() > 0.05) {
      VibrationUtil.vibrateOnEdge(newValue);
    }
    _notifyDragUpdate(newValue);
  }

  /// 结束拖拽
  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final value = _dragPositionPercent;
    setState(() {
      _isDragging = false;
    });
    VibrationUtil.vibrateOnEdge(value);

    final dragTimeInMillis = (value * _totalDurationInMillis).toInt();
    widget.onDragEnd?.call(Duration(milliseconds: dragTimeInMillis));
    widget.onSeekEnd?.call(Duration(milliseconds: dragTimeInMillis));
  }

  /// 触发拖拽更新回调
  void _notifyDragUpdate(double percent) {
    if (widget.onDragUpdate == null) return;
    final dragTimeInMillis = (percent * _totalDurationInMillis).toInt();
    widget.onDragUpdate?.call(Duration(milliseconds: dragTimeInMillis));
  }

  /// 状态更新回调
  @override
  void didUpdateWidget(covariant CustomVideoSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 比较秒级差异，只有当秒级发生变化时才更新缓存
    final oldTotalSeconds = oldWidget.totalDuration.inSeconds;
    final newTotalSeconds = widget.totalDuration.inSeconds;

    final oldCurrentSeconds = oldWidget.currentPosition.inSeconds;
    final newCurrentSeconds = widget.currentPosition.inSeconds;

    final oldBufferedSeconds = oldWidget.bufferedPosition.inSeconds;
    final newBufferedSeconds = widget.bufferedPosition.inSeconds;

    if (oldTotalSeconds != newTotalSeconds ||
        oldCurrentSeconds != newCurrentSeconds ||
        oldBufferedSeconds != newBufferedSeconds) {
      _updateCachedValues();
    }
  }
}

/// 播放器进度条绘制器
///
/// 绘制背景轨道、缓冲进度、播放进度、章节标记点和拖拽 thumb。
class _CustomVideoSliderPainter extends CustomPainter {
  final double progressPercent;
  final double bufferPercent;
  final double thumbRadius;
  final List<double>? chapterMarkerPositions;

  _CustomVideoSliderPainter({
    required this.progressPercent,
    required this.bufferPercent,
    required this.thumbRadius,
    this.chapterMarkerPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    const trackHeight = PlayerStyles.commonSliderHeight;
    final trackTop = (size.height - trackHeight) / 2;
    final trackBottom = trackTop + trackHeight;
    const trackRadius = PlayerStyles.kSliderTrackBorderRadius;

    final effectiveTrackWidth = size.width - thumbRadius * 2;
    final trackLeft = thumbRadius;
    final trackRight = size.width - thumbRadius;

    // 1. 背景轨道始终绘制，即使有效宽度不足也保证可见性
    final backgroundPaint = Paint()
      ..color = PlayerStyles.kSliderBackgroundColor
      ..style = PaintingStyle.fill;
    final backgroundRect = effectiveTrackWidth > 0
        ? Rect.fromLTRB(trackLeft, trackTop, trackRight, trackBottom)
        : Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width,
            height: trackHeight,
          );
    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, trackRadius),
      backgroundPaint,
    );

    if (effectiveTrackWidth <= 0) return;

    // 2. 缓冲进度
    if (bufferPercent > 0) {
      final bufferRight = trackLeft + bufferPercent * effectiveTrackWidth;
      final bufferPaint = Paint()
        ..color = PlayerStyles.kSliderBufferColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(trackLeft, trackTop, bufferRight, trackBottom),
          trackRadius,
        ),
        bufferPaint,
      );
    }

    // 3. 播放进度
    if (progressPercent > 0) {
      final progressRight = trackLeft + progressPercent * effectiveTrackWidth;
      final progressPaint = Paint()
        ..color = PlayerStyles.kSliderProgressColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(trackLeft, trackTop, progressRight, trackBottom),
          trackRadius,
        ),
        progressPaint,
      );
    }

    // 4. 章节标记点
    _paintChapterMarkers(canvas, trackTop, trackBottom, effectiveTrackWidth);

    // 5. thumb
    final thumbCenterX = trackLeft + progressPercent * effectiveTrackWidth;
    final thumbPaint = Paint()
      ..color = PlayerStyles.kSliderThumbColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(thumbCenterX, size.height / 2),
      thumbRadius,
      thumbPaint,
    );
  }

  /// 绘制章节标记竖线
  void _paintChapterMarkers(
    Canvas canvas,
    double trackTop,
    double trackBottom,
    double effectiveTrackWidth,
  ) {
    final positions = chapterMarkerPositions;
    if (positions == null || positions.isEmpty || effectiveTrackWidth <= 0) {
      return;
    }

    final markerPaint = Paint()
      ..color = PlayerStyles.kChapterMarkerColor
      ..strokeWidth = PlayerStyles.kChapterMarkerWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final position in positions) {
      final x = thumbRadius + position * effectiveTrackWidth;
      canvas.drawLine(
        Offset(x, trackTop),
        Offset(x, trackBottom),
        markerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CustomVideoSliderPainter oldDelegate) {
    return oldDelegate.progressPercent != progressPercent ||
        oldDelegate.bufferPercent != bufferPercent ||
        oldDelegate.thumbRadius != thumbRadius ||
        !listEquals(oldDelegate.chapterMarkerPositions, chapterMarkerPositions);
  }
}
