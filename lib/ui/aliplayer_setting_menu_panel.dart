// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/12
// Brief: 播放器设置面板控件

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'aliplayer_custom_selector_widget.dart';
import 'aliplayer_custom_slider_widget.dart';
import 'aliplayer_custom_switch_widget.dart';

/// 设置项类型枚举
enum SettingItemType {
  slider, // 滑块类型
  selector, // 选择器类型
  switcher, // 开关类型
}

/// 设置项数据模型
class SettingItem<T> {
  /// 设置项类型
  final SettingItemType type;

  /// 设置项名称
  final String? text;

  /// 左侧图标
  final IconData? startIcon;

  /// 右侧图标
  final IconData? endIcon;

  /// 可选项（仅用于选择器）
  final List<T>? options;

  /// 初始值
  final T initialValue;

  /// 值变化时的回调
  final ValueChanged<T>? onChanged;

  /// 格式化显示内容（仅用于选择器）
  final String Function(T)? displayFormatter;

  const SettingItem({
    required this.type,
    required this.text,
    required this.initialValue,
    required this.onChanged,
    this.startIcon,
    this.endIcon,
    this.options,
    this.displayFormatter,
  });

  /// 比较两个 SettingItem 是否相等
  bool isEqualTo(SettingItem<T> other) {
    return this.type == other.type &&
        this.text == other.text &&
        this.initialValue == other.initialValue &&
        this.startIcon == other.startIcon &&
        this.endIcon == other.endIcon &&
        listEquals(this.options, other.options);
  }
}

/// 播放器设置面板控件
class AliPlayerSettingMenuPanel extends StatefulWidget {
  /// 面板是否可见
  final bool isVisible;

  /// 面板可见性变化时的回调
  final ValueChanged<bool>? onVisibilityChanged;

  /// 设置项列表
  final List<SettingItem> settingItems;

  const AliPlayerSettingMenuPanel({
    super.key,
    required this.isVisible,
    required this.onVisibilityChanged,
    required this.settingItems,
  });

  @override
  State<AliPlayerSettingMenuPanel> createState() =>
      _AliPlayerSettingMenuPanelState();
}

class _AliPlayerSettingMenuPanelState extends State<AliPlayerSettingMenuPanel>
    with SingleTickerProviderStateMixin {
  /// 控制面板的动画
  late AnimationController _controller;
  late Animation<Offset> _animation;

  /// 设置面板是否可见
  bool _isSettingPanelVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isSettingPanelVisible)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePanelVisibility,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        SlideTransition(
          position: _animation,
          child: Align(
            alignment: Alignment.centerRight,
            child: _isSettingPanelVisible ? _buildSettingPanel(context) : null,
          ),
        ),
      ],
    );
  }

  /// 构建设置面板的内容
  ///
  /// Builds the content of the setting panel.
  Widget _buildSettingPanel(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: double.infinity,
      color: Colors.white.withOpacity(0.3),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.settingItems.map(_buildSettingItem).toList(),
          ),
        ),
      ),
    );
  }

  /// 构建设置项
  ///
  /// Build the setting item.
  Widget _buildSettingItem(SettingItem item) {
    switch (item.type) {
      case SettingItemType.slider:
        return _buildSliderItem(item);
      case SettingItemType.selector:
        return _buildSelectorItem(item);
      case SettingItemType.switcher:
        return _buildSwitcherItem(item);
    }
  }

  /// 构建滑块类型的设置项
  ///
  /// Build the slider type setting item.
  Widget _buildSliderItem(SettingItem item) {
    return AliPlayerCustomSliderWidget(
      text: item.text ?? "Unknown",
      startIcon: item.startIcon ?? Icons.settings_rounded,
      endIcon: item.endIcon ?? Icons.settings_rounded,
      initialValue: item.initialValue,
      onChanged: item.onChanged as ValueChanged<double>?,
    );
  }

  /// 构建选择器类型的设置项
  ///
  /// Build the selector type setting item.
  Widget _buildSelectorItem(SettingItem item) {
    return AliPlayerCustomSelectorWidget(
      text: item.text ?? "Unknown",
      startIcon: item.startIcon ?? Icons.settings_rounded,
      options: item.options,
      initialValue: item.initialValue,
      onChanged: item.onChanged,
      displayFormatter: item.displayFormatter,
    );
  }

  /// 构建开关类型的设置项
  ///
  /// Build the switch type setting item.
  Widget _buildSwitcherItem(SettingItem item) {
    return AliPlayerCustomSwitchWidget(
      text: item.text ?? "Unknown",
      startIcon: item.startIcon ?? Icons.settings_rounded,
      initialValue: item.initialValue,
      onChanged: item.onChanged,
    );
  }

  /// 切换面板的显示状态
  ///
  /// Toggles the visibility of the setting panel.
  void _togglePanelVisibility({bool? isVisible}) {
    setState(() {
      // 如果传入了显式的 isVisible 值，则直接使用它；否则切换当前状态
      final shouldShow = isVisible ?? !_isSettingPanelVisible;

      if (shouldShow) {
        _controller.forward();
      } else {
        _controller.reverse();
      }

      _isSettingPanelVisible = shouldShow;

      // 通知外部可见性变化
      widget.onVisibilityChanged?.call(_isSettingPanelVisible);
    });
  }

  /// 状态更新回调
  /// 当 Widget 的状态被更新时，该方法被调用。
  ///
  /// Called when the state of the widget is updated.
  @override
  void didUpdateWidget(covariant AliPlayerSettingMenuPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果 isVisible 发生变化，更新面板的显示状态
    if (oldWidget.isVisible != widget.isVisible) {
      _togglePanelVisibility(isVisible: widget.isVisible);
    }

    // 如果 settingItems 发生变化，触发刷新
    if (!_areSettingItemsEqual(oldWidget.settingItems, widget.settingItems)) {
      setState(() {});
    }
  }

  /// 检查两个 settingItems 列表是否相等
  ///
  /// Checks if two setting item lists are equal.
  bool _areSettingItemsEqual(
    List<SettingItem>? oldItems,
    List<SettingItem>? newItems,
  ) {
    // Handle null values.
    if (oldItems == null || newItems == null) {
      return oldItems == newItems; // Both null or one is null.
    }

    // Return true if the references are identical.
    if (identical(oldItems, newItems)) return true;

    // Return false if lengths differ.
    if (oldItems.length != newItems.length) return false;

    // Compare each element using Iterable.every.
    return oldItems
        .asMap()
        .entries
        .every((entry) => entry.value.isEqualTo(newItems[entry.key]));
  }
}
