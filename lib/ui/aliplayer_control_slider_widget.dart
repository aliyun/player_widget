// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/12
// Brief: 自定义滑块控件

import 'package:flutter/material.dart';

import '../theme/player_styles.dart';
import 'aliplayer_custom_button.dart';
import 'aliplayer_slider_shape.dart';

/// 自定义滑块控件，用于显示一个带有文本和图标的滑块组件。
class AliPlayerControlSliderWidget extends StatefulWidget {
  /// 显示的文本
  final String text;

  /// 起始图标
  final String startIconName;

  /// 结束图标
  final String? endIconName;

  /// 初始值
  final double initialValue;

  /// 滑块值变化时的回调（仅在可交互模式下有效）
  final ValueChanged<double>? onChanged;

  /// 是否可交互（可拖动）
  final bool isInteractive;

  const AliPlayerControlSliderWidget({
    super.key,
    required this.text,
    required this.startIconName,
    required this.initialValue,
    this.endIconName,
    this.onChanged,
    this.isInteractive = true, // 默认为可交互
  });

  @override
  State<AliPlayerControlSliderWidget> createState() =>
      _AliPlayerControlSliderWidgetState();
}

class _AliPlayerControlSliderWidgetState
    extends State<AliPlayerControlSliderWidget> {
  // 当前滑块的值
  late double _sliderValue;

  // SliderShape
  // 确保在 state 生命周期中只初始化一次
  final AliPlayerCommonSliderShape sliderShape = AliPlayerCommonSliderShape();

  @override
  void initState() {
    super.initState();

    // 在初始化阶段直接设置值，无需 setState，因为此时 widget 尚未构建
    _sliderValue = _roundToTwoDecimals(widget.initialValue.clamp(0.0, 1.0));
  }

  /// 更新滑块值并触发回调
  void _onSliderChanged(double value) {
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

  static int _roundToProgressValue(double value) {
    return (value * 100).roundToDouble().toInt();
  }

  /// 构建自定义滑块控件
  ///
  /// Builds the custom slider widget.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PlayerStyles.kControlWidgetWidth,
      height: PlayerStyles.kControlWidgetHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: PlayerStyles.kControlVerticalInsets,
          horizontal: PlayerStyles.kControlHorizontalInsets,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomIconButton(
              iconName: widget.startIconName,
              iconSize: const Size.square(PlayerStyles.iconSizeTopBar),
            ),
            SizedBox(
              width: PlayerStyles.kControlSlideWidth,
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
            if (widget.endIconName != null)
              CustomIconButton(
                iconName: widget.endIconName!,
                iconSize: const Size.square(PlayerStyles.iconSizeTopBar),
              ),
            SizedBox(
              width: PlayerStyles.kControlValueWidth,
              child: Text(
                "${_roundToProgressValue(_sliderValue)}",
                style: const TextStyle(
                  fontSize: PlayerStyles.commonTextSize,
                  color: PlayerStyles.colorOnPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取 SliderTheme 数据
  ///
  /// Returns the SliderThemeData configuration.
  SliderThemeData _getSliderThemeData() {
    return SliderTheme.of(context).copyWith(
      trackHeight: PlayerStyles.commonSliderHeight,
      trackShape: sliderShape,
      thumbShape: widget.isInteractive
          ? const RoundSliderThumbShape(
              enabledThumbRadius: PlayerStyles.kControlSliderThumbRadius,
              elevation: PlayerStyles.kControlSliderElevation,
            )
          : const RoundSliderThumbShape(
              enabledThumbRadius: 0.0,
              elevation: 0.0,
            ),
      activeTrackColor: PlayerStyles.kSliderProgressColor,
      inactiveTrackColor: PlayerStyles.kSliderBackgroundColor,
      thumbColor: widget.isInteractive
          ? PlayerStyles.kSliderThumbColor
          : Colors.transparent,
      // 去除默认的 overlay 半径干扰
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 8.0),
      disabledActiveTrackColor: PlayerStyles.kSliderThumbColor,
      disabledInactiveTrackColor: PlayerStyles.kSliderBackgroundColor,
      disabledInactiveTickMarkColor: PlayerStyles.kSliderThumbColor,
    );
  }

  /// 状态更新回调
  ///
  /// Called when the state of the widget is updated.
  @override
  void didUpdateWidget(covariant AliPlayerControlSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果外部传递的 initialValue 发生变化，则同步更新内部状态
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _sliderValue = _roundToTwoDecimals(widget.initialValue.clamp(0.0, 1.0));
      });
    }
  }
}
