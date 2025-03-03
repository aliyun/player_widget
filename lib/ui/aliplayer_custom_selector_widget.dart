// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 自定义选择器控件，用于显示一个带有文本和图标的选项选择组件。

import 'package:flutter/material.dart';

/// A customizable selector widget for displaying a list of options with text and icons.
///
/// 自定义选择器控件，用于显示一组带有文本和图标的选项。
class AliPlayerCustomSelectorWidget<T> extends StatefulWidget {
  /// 显示的文本
  ///
  /// Displayed text
  final String text;

  /// 起始图标
  ///
  /// Leading icon
  final IconData startIcon;

  /// 可选项列表
  ///
  /// List of selectable options
  final List<T>? options;

  /// 初始值
  ///
  /// Initial selected value
  final T? initialValue;

  /// 值变化时的回调
  ///
  /// Callback when the value changes
  final ValueChanged<T>? onChanged;

  /// 选项显示格式化函数（允许为空，为空时使用默认的 toString() 方法）。
  ///
  /// Formatter for displaying options (falls back to toString() if null).
  final String Function(T option)? displayFormatter;

  const AliPlayerCustomSelectorWidget({
    super.key,
    required this.text,
    required this.startIcon,
    required this.options,
    required this.initialValue,
    this.onChanged,
    this.displayFormatter,
  });

  @override
  State<AliPlayerCustomSelectorWidget<T>> createState() =>
      _AliPlayerCustomSelectorWidgetState<T>();
}

class _AliPlayerCustomSelectorWidgetState<T>
    extends State<AliPlayerCustomSelectorWidget<T>> {
  late T? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  /// 更新当前值并触发回调
  ///
  /// Updates the current value and triggers the callback.
  void _onValueChanged(T newValue) {
    if (_currentValue != newValue) {
      setState(() {
        _currentValue = newValue;
      });
      widget.onChanged?.call(newValue);
    }
  }

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
        _buildOptions(),
        const SizedBox(width: 4),
      ],
    );
  }

  /// 构建选项列表
  ///
  /// Builds the option list.
  Widget _buildOptions() {
    // 默认显示内容
    final bool isEmpty = widget.initialValue == null ||
        widget.options == null ||
        widget.options!.isEmpty;

    return // 如果为空，显示默认内容
        isEmpty
            ? const Expanded(
                child: Text(
                  "No options available",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              )
            :
            // 横滑列表
            Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.options!
                        .map((option) => _buildSingleItem(option))
                        .toList(),
                  ),
                ),
              );
  }

  /// 构建单个选项项
  ///
  /// Builds a single option item.
  Widget _buildSingleItem(T option) {
    final isSelected = option == _currentValue;

    // 如果 displayFormatter 为空，使用默认的 toString() 方法
    final displayText = widget.displayFormatter != null
        ? widget.displayFormatter!(option)
        : option.toString();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onValueChanged(option),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          displayText,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// 监听外部状态变化
  ///
  /// Listen for external state changes.
  @override
  void didUpdateWidget(covariant AliPlayerCustomSelectorWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger rebuild if properties changes
    if (widget.initialValue != oldWidget.initialValue ||
        !identical(widget.options, oldWidget.options)) {
      setState(() {
        _currentValue = widget.initialValue;
      });
    }
  }
}
