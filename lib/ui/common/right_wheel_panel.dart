// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/04/15
// Brief: 右侧列表选择面板（通用）

import 'dart:ui';

import 'package:aliplayer_widget/theme/theme.dart';
import 'package:aliplayer_widget/i18n/i18n.dart';
import 'package:flutter/material.dart';

/// 右侧列表选择面板（横屏页面底部按钮弹出）
class RightWheelPanel<T> extends StatefulWidget {
  /// 设置项列表（展示时优先使用 [displayFormatter]，未提供时回退到 toString()）。
  ///
  /// List of options (displayed via [displayFormatter] if provided, otherwise toString()).
  final List<T> itemTitles;

  /// 点击某项后的回调
  final ValueChanged<T> onSelected;

  /// 初始选中下标
  final int initialIndex;

  /// 选项显示格式化函数（允许为空，为空时使用默认的 toString() 方法）。
  ///
  /// Formatter for displaying options (falls back to toString() if null).
  final String Function(T item)? displayFormatter;

  const RightWheelPanel(
    this.itemTitles, {
    super.key,
    required this.onSelected,
    this.initialIndex = 0,
    this.displayFormatter,
  });

  @override
  State<RightWheelPanel<T>> createState() => _RightWheelPanelState<T>();
}

class _RightWheelPanelState<T> extends State<RightWheelPanel<T>> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();

    // 空列表时，默认选中 -1（表示无选中项）
    if (widget.itemTitles.isEmpty) {
      _selectedIndex = -1;
      return;
    }

    // 初始下标安全处理
    _selectedIndex = widget.initialIndex.clamp(0, widget.itemTitles.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          color: Colors.black.withOpacity(0.7),
          child: widget.itemTitles.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      PlayerI18n.t(PlayerI18nKeys.emptyOption),
                      style:
                          const TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                )
              : Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.itemTitles.length,
                    itemBuilder: (context, i) {
                      final bool selected = _selectedIndex == i;

                      return Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedIndex = i);
                            widget.onSelected(widget.itemTitles[i]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Semantics(
                                // 无障碍：标注选中状态
                                selected: selected,
                                child: Text(
                                  widget.displayFormatter
                                          ?.call(widget.itemTitles[i]) ??
                                      widget.itemTitles[i].toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: selected
                                        ? PlayerStyles.colorOnPrimary
                                        : PlayerStyles.colorOnPrimary
                                            .withOpacity(0.5),
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
