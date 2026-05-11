// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 播放器自定义顶部横栏组件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/slot/slot_elements.dart';
import 'package:aliplayer_widget/slot/slot_manager.dart';
import 'package:flutter/material.dart';

import 'package:aliplayer_widget/theme/player_theme.dart';
import 'aliplayer_custom_button.dart';
import 'aliplayer_shared_animation_widget.dart';

/// 自定义顶部横栏组件
class AliPlayerTopBarWidget extends AliPlayerSharedAnimationWidget {
  /// 标题文本
  final String? title;

  /// 返回按钮点击回调
  final VoidCallback? onBackPressed;

  /// 设置按钮点击回调
  final VoidCallback? onSettingsPressed;

  /// 是否已下载，可选
  final bool? isDownload;

  /// 下载按钮点击回调
  final ValueChanged<bool>? onDownloadPressed;

  /// 截图按钮点击回调
  final VoidCallback? onSnapshotPressed;

  /// PIP 按钮点击回调
  final VoidCallback? onPIPPressed;

  /// 构造函数
  const AliPlayerTopBarWidget({
    super.key,
    required super.animationManager,
    this.title,
    this.onBackPressed,
    this.onSettingsPressed,
    this.isDownload,
    this.onDownloadPressed,
    this.onSnapshotPressed,
    this.onPIPPressed,
  });

  @override
  Widget buildWrapper(BuildContext context, Widget child) {
    return Positioned(top: 0, left: 0, right: 0, child: child);
  }

  @override
  Widget buildContent(BuildContext context) {
    // 一次性获取隐藏配置，避免重复遍历 widget tree
    // Get hidden config once to avoid repeated widget tree traversal
    final hiddenElements = SlotManager.getHiddenElements(
      context,
      SlotType.topBar,
    );

    // 获取屏幕方向，用于区分横竖屏布局
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // 横屏时：左侧按钮左间距34，右侧按钮之间间距34
    // 竖屏时：保持原有样式，水平间距20
    final horizontalMargin = isLandscape
        ? PlayerStyles.kTopBarLandscapeHorizontalMargin
        : PlayerStyles.kTopBarPortraitHorizontalMargin;
    final leftButtonLeftMargin =
        isLandscape ? PlayerStyles.kTopBarLandscapeBackButtonLeftMargin : 0.0;
    final rightButtonRightMargin =
        isLandscape ? PlayerStyles.kTopBarLandscapeRightButtonRightMargin : 0.0;
    const rightButtonsSpacing = PlayerStyles.kIconHorizontalMargin;

    // 根据配置构建可见元素，避免过早创建 Widget
    // Build visible elements based on config, avoiding premature Widget creation
    final slotElements = <Widget>[];

    // 返回按钮
    if (hiddenElements.isElementVisible(TopBarElements.back)) {
      slotElements.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBackPressed,
          child: Container(
            margin: EdgeInsets.only(
              left: leftButtonLeftMargin,
              right: isLandscape ? 0.0 : 6.0,
            ),
            child: Image.asset(
              PlayerAssetsScope.iconPath(context, PlayerIcons.back),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    // 标题
    if (hiddenElements.isElementVisible(TopBarElements.title)) {
      slotElements.add(
        Expanded(
          child: title == null || title!.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    title!,
                    style: TextStyle(
                      color: PlayerStyles.colorOnPrimary,
                      fontSize: PlayerStyles.fontSizeTitle,
                      fontWeight: PlayerStyles.fontWeightTitle,
                      shadows: [
                        Shadow(
                          offset: Offset.zero,
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      );
    } else {
      // 隐藏时仍需保持弹性布局
      // Must maintain flex layout when hidden
      slotElements.add(const Expanded(child: SizedBox.shrink()));
    }

    // 截图按钮，可选
    if (onSnapshotPressed != null &&
        hiddenElements.isElementVisible(TopBarElements.snapshot)) {
      slotElements.add(
        CustomIconButton(
          iconName: PlayerIcons.snapshot,
          margin: const EdgeInsets.symmetric(
            horizontal: rightButtonsSpacing,
          ),
          onPressed: () => onSnapshotPressed?.call(),
        ),
      );
    }

    // 下载按钮，可选
    if (isDownload != null &&
        onDownloadPressed != null &&
        hiddenElements.isElementVisible(TopBarElements.download)) {
      slotElements.add(
        CustomIconButton(
          iconName: PlayerIcons.download,
          margin: const EdgeInsets.symmetric(
            horizontal: rightButtonsSpacing,
          ),
          onPressed: () => onDownloadPressed?.call(isDownload!),
        ),
      );
    }

    // PIP 按钮，可选
    if (onPIPPressed != null &&
        hiddenElements.isElementVisible(TopBarElements.pip)) {
      // TODO: PIP 按钮
    }

    // 设置按钮，可选（最右侧按钮，使用右边距）
    if (onSettingsPressed != null &&
        hiddenElements.isElementVisible(TopBarElements.settings)) {
      slotElements.add(
        CustomIconButton(
          iconName: PlayerIcons.settings,
          margin: EdgeInsets.only(
            left: rightButtonsSpacing,
            right: rightButtonRightMargin,
          ),
          onPressed: () => onSettingsPressed?.call(),
        ),
      );
    }

    return SafeArea(
      child: Container(
        height: PlayerStyles.kTopBarHeight,
        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: slotElements,
        ),
      ),
    );
  }
}
