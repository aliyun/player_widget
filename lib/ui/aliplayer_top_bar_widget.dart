// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 播放器自定义顶部横栏组件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/slot/slot_elements.dart';
import 'package:aliplayer_widget/slot/slot_manager.dart';
import 'package:flutter/material.dart';

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
  Widget buildContent(BuildContext context) {
    // 一次性获取隐藏配置，避免重复遍历 widget tree
    // Get hidden config once to avoid repeated widget tree traversal
    final hiddenElements = SlotManager.getHiddenElements(
      context,
      SlotType.topBar,
    );

    // 根据配置构建可见元素，避免过早创建 Widget
    // Build visible elements based on config, avoiding premature Widget creation
    final slotElements = <Widget>[];

    // 返回按钮
    if (hiddenElements.isElementVisible(TopBarElements.back)) {
      slotElements.add(IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: onBackPressed,
      ));
    }

    // 标题
    if (hiddenElements.isElementVisible(TopBarElements.title)) {
      slotElements.add(Expanded(
        child: title == null || title!.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title!,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
      ));
    } else {
      // 隐藏时仍需保持弹性布局
      // Must maintain flex layout when hidden
      slotElements.add(const Expanded(child: SizedBox.shrink()));
    }

    // 下载按钮，可选
    if (isDownload != null &&
        onDownloadPressed != null &&
        hiddenElements.isElementVisible(TopBarElements.download)) {
      slotElements.add(Padding(
        padding: const EdgeInsets.only(left: 4),
        child: IconButton(
          icon: Icon(
            isDownload! ? Icons.download_done_rounded : Icons.download_rounded,
            color: Colors.white,
          ),
          onPressed: () => onDownloadPressed?.call(isDownload!),
        ),
      ));
    }

    // 截图按钮，可选
    if (onSnapshotPressed != null &&
        hiddenElements.isElementVisible(TopBarElements.snapshot)) {
      slotElements.add(Padding(
        padding: const EdgeInsets.only(left: 4),
        child: IconButton(
          icon: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
          ),
          onPressed: onSnapshotPressed,
        ),
      ));
    }

    // PIP 按钮，可选
    if (onPIPPressed != null &&
        hiddenElements.isElementVisible(TopBarElements.pip)) {
      slotElements.add(Padding(
        padding: const EdgeInsets.only(left: 4),
        child: IconButton(
          icon: const Icon(
            Icons.picture_in_picture_alt_rounded,
            color: Colors.white,
          ),
          onPressed: onPIPPressed,
        ),
      ));
    }

    // 设置按钮，可选
    if (onSettingsPressed != null &&
        hiddenElements.isElementVisible(TopBarElements.settings)) {
      slotElements.add(Padding(
        padding: const EdgeInsets.only(left: 4),
        child: IconButton(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
          ),
          onPressed: onSettingsPressed,
        ),
      ));
    }

    return Container(
      height: kToolbarHeight,
      color: Colors.black.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: slotElements,
      ),
    );
  }
}
