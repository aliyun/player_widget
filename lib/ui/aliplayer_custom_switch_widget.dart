// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 播放器自定义选择器控件

import 'package:flutter/material.dart';

/// 自定义开关控件，用于显示一个带有文本和图标的开关组件。
class AliPlayerCustomSwitchWidget extends StatefulWidget {
  /// 显示的文本
  final String text;

  /// 起始图标
  final IconData startIcon;

  /// 初始值
  final bool initialValue;

  /// 开关状态变化时的回调
  final ValueChanged<bool>? onChanged;

  const AliPlayerCustomSwitchWidget({
    super.key,
    required this.text,
    required this.startIcon,
    required this.initialValue,
    this.onChanged,
  });

  @override
  State<AliPlayerCustomSwitchWidget> createState() =>
      _AliPlayerCustomSwitchWidgetState();
}

class _AliPlayerCustomSwitchWidgetState
    extends State<AliPlayerCustomSwitchWidget> {
  late bool _switchValue;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.initialValue;
  }

  /// 更新开关状态并触发回调
  void _onSwitchChanged(bool value) {
    setState(() {
      _switchValue = value;
    });
    widget.onChanged?.call(value);
  }

  /// 获取 SwitchTheme 数据
  ///
  /// Returns the SwitchThemeData configuration.
  ///
  /// NOTE: Writing style for versions after Flutter 3.19;
  /// If you want to support versions before Flutter 3.19, you need to modify the code like this:
  /// WidgetStateProperty ---> MaterialStateProperty, WidgetState ---> MaterialState
  SwitchThemeData _getSwitchThemeData() {
    return SwitchTheme.of(context).copyWith(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        return states.contains(WidgetState.selected)
            ? Colors.blue
            : Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        return states.contains(WidgetState.selected)
            ? Colors.blue.withOpacity(0.3)
            : Colors.grey.withOpacity(0.3);
      }),
    );
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
        // 开关
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: SwitchTheme(
              data: _getSwitchThemeData(),
              child: Switch(
                value: _switchValue,
                onChanged: _onSwitchChanged,
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// 监听外部状态变化
  @override
  void didUpdateWidget(covariant AliPlayerCustomSwitchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果外部传递的 initialValue 发生变化，则同步更新内部状态
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _switchValue = widget.initialValue;
      });
    }
  }
}
