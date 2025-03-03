// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/12
// Brief: 播放器进度条控件

import 'package:aliplayer_widget/utils/format_util.dart';
import 'package:aliplayer_widget/utils/vibration_util.dart';
import 'package:flutter/material.dart';

/// 播放器进度条控件，用于显示视频播放进度和缓冲进度
///
/// 提供拖拽功能以调整播放位置，并支持边界振动反馈
class AliPlayerVideoSlider extends StatefulWidget {
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

  const AliPlayerVideoSlider({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.bufferedPosition,
    this.onDragUpdate,
    this.onDragEnd,
    this.onSeekEnd,
  });

  @override
  State<AliPlayerVideoSlider> createState() => _AliPlayerVideoSliderState();
}

class _AliPlayerVideoSliderState extends State<AliPlayerVideoSlider> {
  // 初始化颜色管理
  static const Map<String, Color> _colors = {
    'background': Colors.grey,
    'buffered': Colors.blueGrey,
    'progress': Colors.blueAccent,
    'thumb': Colors.blue,
  };

  // 当前拖拽的进度百分比
  double _dragPositionPercent = 0.0;

  // 是否正在拖拽
  bool _isDragging = false;

  // 缓存 SliderThemeData
  late SliderThemeData _sliderThemeData;

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

  /// 构建播放器视图
  ///
  /// Builds the main player view.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Row(
        children: [
          _buildVideoSlider(),
          const SizedBox(width: 8),
          _buildTimeText(),
        ],
      ),
    );
  }

  /// 构建视频进度条
  Widget _buildVideoSlider() {
    // 预计算进度百分比和缓冲百分比
    final progressPercent = _totalDurationInMillis > 0
        ? (_currentPositionInMillis / _totalDurationInMillis).clamp(0.0, 1.0)
        : 0.0;
    final bufferPercent = _totalDurationInMillis > 0
        ? (_bufferedPositionInMillis / _totalDurationInMillis).clamp(0.0, 1.0)
        : 0.0;

    return Expanded(
      child: SliderTheme(
        data: _sliderThemeData, // 使用缓存的 SliderThemeData
        child: Slider(
          value: _isDragging ? _dragPositionPercent : progressPercent,
          min: 0.0,
          max: 1.0,
          secondaryTrackValue: bufferPercent,
          onChanged: (value) => _updateDragPosition(value),
          onChangeEnd: (value) => _endDrag(value),
        ),
      ),
    );
  }

  /// 获取 SliderTheme 数据
  SliderThemeData _getSliderThemeData(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 4.0,
        elevation: 2.0,
      ),
      overlayShape: const RoundSliderOverlayShape(
        overlayRadius: 8.0,
      ),
      overlayColor: _colors['progress']!.withAlpha(32),
      activeTrackColor: _colors['progress']!,
      thumbColor: _colors['thumb']!,
      inactiveTrackColor: _colors['background']!,
      secondaryActiveTrackColor: _colors['buffered']!,
    );
  }

  /// 构建时间文本
  Widget _buildTimeText() {
    return Text(
      '${FormatUtil.formatDuration(widget.currentPosition)} / ${FormatUtil.formatDuration(widget.totalDuration)}',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
    );
  }

  /// 更新拖拽位置并触发回调
  void _updateDragPosition(double value) {
    // 如果 onDragUpdate 回调为空，则不响应拖拽操作
    if (widget.onDragUpdate == null) return;

    final lastValue = _dragPositionPercent;
    setState(() {
      _isDragging = true;
      _dragPositionPercent = value;
    });
    if ((value - lastValue).abs() > 0.05) {
      VibrationUtil.vibrateOnEdge(value); // Vibrate on significant change
    }
    // Calculate time in milliseconds
    final dragTimeInMillis = (value * _totalDurationInMillis).toInt();
    widget.onDragUpdate?.call(Duration(milliseconds: dragTimeInMillis));
  }

  /// 结束拖拽并触发回调
  void _endDrag(double value) {
    // 如果 onDragEnd 或 onSeekEnd 回调为空，则不响应拖拽结束操作
    if (widget.onDragEnd == null && widget.onSeekEnd == null) return;

    setState(() {
      _isDragging = false;
    });
    VibrationUtil.vibrateOnEdge(value);
    // Calculate time in milliseconds
    final dragTimeInMillis = (value * _totalDurationInMillis).toInt();
    widget.onDragEnd?.call(Duration(milliseconds: dragTimeInMillis));
    widget.onSeekEnd?.call(Duration(milliseconds: dragTimeInMillis));
  }

  /// 状态更新回调
  /// 当 Widget 的状态被更新时，该方法被调用。
  ///
  /// Called when the state of the widget is updated.
  @override
  void didUpdateWidget(covariant AliPlayerVideoSlider oldWidget) {
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始化并缓存 SliderThemeData
    _sliderThemeData = _getSliderThemeData(context);
  }
}
