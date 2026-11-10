// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: aqi
// Date: 2026/09/01
// Brief: 章节 Chip 列表组件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/utils/format_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 章节 Chip 列表
///
/// 横向展示章节标题，支持点击跳转和高亮当前章节。
class ChapterChipListWidget extends StatefulWidget {
  /// 章节数据列表
  final List<ChapterInfo> chapters;

  /// 当前章节索引
  final int currentIndex;

  /// 章节点击回调
  final ValueChanged<int> onChapterSelected;

  const ChapterChipListWidget({
    super.key,
    required this.chapters,
    required this.currentIndex,
    required this.onChapterSelected,
  });

  @override
  State<ChapterChipListWidget> createState() => _ChapterChipListWidgetState();
}

class _ChapterChipListWidgetState extends State<ChapterChipListWidget> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _currentItemKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollToCurrentIndex();
  }

  @override
  void didUpdateWidget(covariant ChapterChipListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当前章节切换，或章节数据整体替换后，重新定位到当前章节
    if (oldWidget.currentIndex != widget.currentIndex ||
        !listEquals(oldWidget.chapters, widget.chapters)) {
      _scrollToCurrentIndex();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentIndex() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // 当前位置不在任何章节内时回到列表开头，避免章节替换后残留旧偏移
      if (widget.currentIndex < 0) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        return;
      }
      final context = _currentItemKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PlayerStyles.kChapterChipListHeight,
      child: ListView.separated(
        key: const PageStorageKey('chapter_chip_list'),
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: PlayerStyles.kBottomBarPortraitHorizontalPadding,
        ),
        itemCount: widget.chapters.length,
        separatorBuilder: (_, __) => const SizedBox(
          width: PlayerStyles.kChapterChipSpacing,
        ),
        itemBuilder: (context, index) {
          final chapter = widget.chapters[index];
          final isSelected = index == widget.currentIndex;
          final timeText = FormatUtil.formatDuration(
            Duration(milliseconds: chapter.startMs),
          );
          return _buildChip(
            key: isSelected ? _currentItemKey : null,
            title: chapter.title,
            timeText: timeText,
            isSelected: isSelected,
            onTap: () => widget.onChapterSelected(index),
          );
        },
      ),
    );
  }

  Widget _buildChip({
    Key? key,
    required String title,
    required String timeText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: PlayerStyles.kChapterChipMaxWidth,
        ),
        child: Container(
          height: PlayerStyles.kChapterChipListHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: PlayerStyles.kChapterChipHorizontalPadding,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? PlayerStyles.kChapterChipSelectedBackground
                : PlayerStyles.kChapterChipUnselectedBackground,
            borderRadius: BorderRadius.circular(
              PlayerStyles.kChapterChipBorderRadius,
            ),
          ),
          child: Text(
            '$timeText $title',
            style: const TextStyle(
              fontSize: PlayerStyles.commonTextSize,
              color: PlayerStyles.kChapterChipSelectedTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
