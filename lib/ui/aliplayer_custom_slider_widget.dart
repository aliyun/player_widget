// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/12
// Brief: 自定义滑块控件

import 'package:flutter/material.dart';

/// 自定义滑块控件，用于显示一个带有文本和图标的滑块组件。
class AliPlayerCustomSliderWidget extends StatefulWidget {
  /// 显示的文本
  final String text;

  /// 起始图标
  final IconData startIcon;

  /// 结束图标
  final IconData endIcon;

  /// 初始值
  final double initialValue;

  /// 滑块值变化时的回调（仅在可交互模式下有效）
  final ValueChanged<double>? onChanged;

  /// 是否可交互（可拖动）
  final bool isInteractive;

  const AliPlayerCustomSliderWidget({
    super.key,
    required this.text,
    required this.startIcon,
    required this.endIcon,
    required this.initialValue,
    this.onChanged,
    this.isInteractive = true, // 默认为可交互
  });

  @override
  State<AliPlayerCustomSliderWidget> createState() =>
      _AliPlayerCustomSliderWidgetState();
}

class _AliPlayerCustomSliderWidgetState
    extends State<AliPlayerCustomSliderWidget> {
  // 当前滑块的值
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = _roundToTwoDecimals(widget.initialValue);
  }

  /// 更新滑块值并触发回调
  void _onSliderChanged(double value) {
    if (!widget.isInteractive) return; // 如果不可交互，则直接返回

    // 将滑块值保留两位小数
    final roundedValue = _roundToTwoDecimals(value);

    setState(() {
      _sliderValue = roundedValue;
    });
    widget.onChanged?.call(roundedValue); // 触发回调
  }

  /// 将数值保留两位小数
  static double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }

  /// 构建自定义滑块控件
  ///
  /// Builds the custom slider widget.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          widget.startIcon,
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: SliderTheme(
            data: _getSliderThemeData(),
            child: Slider(
              value: _sliderValue,
              onChanged: widget.isInteractive ? _onSliderChanged : null,
              // 根据状态决定是否允许拖动
              min: 0.0,
              max: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          widget.endIcon,
          size: 16,
        ),
      ],
    );
  }

  /// 获取 SliderTheme 数据
  ///
  /// Returns the SliderThemeData configuration.
  SliderThemeData _getSliderThemeData() {
    return SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
      thumbShape: widget.isInteractive
          ? const RoundSliderThumbShape(
              enabledThumbRadius: 4.0,
              elevation: 2.0,
            )
          : const RoundSliderThumbShape(
              enabledThumbRadius: 0.0,
              elevation: 0.0,
            ),
      activeTrackColor: Colors.grey,
      inactiveTrackColor: Colors.grey[300],
      thumbColor: widget.isInteractive ? Colors.grey : Colors.transparent,
      overlayColor: widget.isInteractive
          ? Colors.grey[400]?.withAlpha(32)
          : Colors.transparent,
    );
  }

  /// 状态更新回调
  ///
  /// Called when the state of the widget is updated.
  @override
  void didUpdateWidget(covariant AliPlayerCustomSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果外部传递的 initialValue 发生变化，则同步更新内部状态
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _sliderValue = _roundToTwoDecimals(widget.initialValue);
      });
    }
  }
}
