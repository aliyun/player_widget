// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/04/15
// Brief: 倍速 / 清晰度 设置面板 （横屏页面）

import 'dart:ui';

import 'package:aliplayer_widget/theme/player_styles.dart';
import 'package:flutter/material.dart';

import '../i18n/player_i18n.dart';
import '../i18n/player_i18n_keys.dart';

/// 倍速 / 清晰度 等设置项的右侧列表面板（横屏页面底部按钮弹出）

class RightWheelSettingPanel<T> extends StatefulWidget {
  /// 设置项列表（展示时会调用 toString）
  final List<T> itemTitles;

  /// 点击某项后的回调
  final ValueChanged<T> onSelected;

  /// 初始选中下标
  final int initialIndex;

  const RightWheelSettingPanel(
    this.itemTitles, {
    super.key,
    required this.onSelected,
    this.initialIndex = 0,
  });

  @override
  State<RightWheelSettingPanel<T>> createState() =>
      _RightWheelSettingPanelState<T>();
}

class _RightWheelSettingPanelState<T> extends State<RightWheelSettingPanel<T>> {
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
          width: PlayerStyles.kRightWheelPanelWidth,
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

/// 以“右侧滑入”的方式展示设置面板。
Future<T?> showRightSettingPanel<T>({
  required Widget panel,
  required BuildContext context,
  double width = PlayerStyles.kRightWheelPanelWidth,
  Duration duration = const Duration(milliseconds: 250),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    // 点击遮罩可关闭
    barrierLabel: 'RightSettingPanel',
    barrierColor: PlayerStyles.colorOnPrimary.withOpacity(0.1),
    transitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) {
      // 点击面板内部不关闭，点击外部遮罩由 showGeneralDialog 处理
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          type: MaterialType.transparency, // 不改变你原本的背景表现
          child: SizedBox(
            width: width,
            height: double.infinity,
            child: panel,
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final offsetTween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOut));

      return SlideTransition(
        position: animation.drive(offsetTween),
        child: child,
      );
    },
  );
}
