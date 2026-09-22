// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: aqi
// Date: 2026/09/09
// Brief: 章节列表面板管理器

import 'package:aliplayer_widget/data/chapter_info.dart';
import 'package:aliplayer_widget/theme/player_styles.dart';
import 'package:aliplayer_widget/ui/chapter/chapter_panel_widget.dart';
import 'package:aliplayer_widget/ui/common/right_slide_panel.dart';
import 'package:flutter/material.dart';

/// 章节列表面板管理器
///
/// 统一封装章节列表面板的显示逻辑，复用右侧滑入面板动画。
class ChaptersPanelManager {
  ChaptersPanelManager._();

  /// 显示章节列表面板
  ///
  /// [context] 构建上下文
  /// [chapters] 章节数据列表
  /// [currentIndex] 当前播放位置对应的章节索引
  /// [onChapterSelected] 章节选中回调，返回选中章节索引
  static Future<void> showChaptersPanel({
    required BuildContext context,
    required List<ChapterInfo> chapters,
    required int currentIndex,
    required ValueChanged<int> onChapterSelected,
  }) {
    return showRightSlidePanel<void>(
      context: context,
      width: PlayerStyles.kChaptersPanelWidth,
      panel: ChapterPanelWidget(
        chapters: chapters,
        currentIndex: currentIndex,
        onChapterSelected: onChapterSelected,
      ),
    );
  }
}
