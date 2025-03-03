// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 播放器自定义顶部横栏组件

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
    return Container(
      height: kToolbarHeight,
      color: Colors.black.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 返回按钮
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: onBackPressed,
          ),

          // 标题
          Expanded(
            child: title == null || title!.isEmpty
                ? const SizedBox.shrink()
                : Center(
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),

          // 下载按钮，可选
          if (isDownload != null && onDownloadPressed != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                isDownload!
                    ? Icons.download_done_rounded
                    : Icons.download_rounded,
                color: Colors.white,
              ),
              onPressed: () => onDownloadPressed?.call(isDownload!),
            ),
          ],

          // 截图按钮，可选
          if (onSnapshotPressed != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
              ),
              onPressed: onSnapshotPressed,
            )
          ],

          // PIP 按钮，可选
          if (onPIPPressed != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.picture_in_picture_alt_rounded,
                color: Colors.white,
              ),
              onPressed: onPIPPressed,
            )
          ],

          // 设置按钮，仅当 onSettingsPressed 不为空时显示
          if (onSettingsPressed != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: onSettingsPressed,
            ),
          ],
        ],
      ),
    );
  }
}
