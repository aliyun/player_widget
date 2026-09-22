// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: aqi
// Date: 2026/09/09
// Brief: 章节列表面板组件

import 'dart:ui';

import 'package:aliplayer_widget/data/chapter_info.dart';
import 'package:aliplayer_widget/i18n/player_i18n.dart';
import 'package:aliplayer_widget/i18n/player_i18n_keys.dart';
import 'package:aliplayer_widget/theme/player_icons.dart';
import 'package:aliplayer_widget/theme/player_styles.dart';
import 'package:aliplayer_widget/ui/custom/custom_icon_button.dart';
import 'package:aliplayer_widget/utils/format_util.dart';
import 'package:flutter/material.dart';

/// 章节列表面板
///
/// 从右侧滑出的章节选择面板，展示所有章节缩略图、标题与起始时间，
/// 点击某项后跳转到对应章节并关闭面板。
class ChapterPanelWidget extends StatelessWidget {
  /// 章节数据列表
  final List<ChapterInfo> chapters;

  /// 当前选中章节索引
  final int currentIndex;

  /// 章节选中回调
  final ValueChanged<int> onChapterSelected;

  /// 关闭按钮点击回调
  final VoidCallback? onClose;

  const ChapterPanelWidget({
    super.key,
    required this.chapters,
    required this.currentIndex,
    required this.onChapterSelected,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        // 使用较大的模糊半径，增强毛玻璃质感
        filter: ImageFilter.blur(
          sigmaX: PlayerStyles.kChaptersPanelBlurSigma,
          sigmaY: PlayerStyles.kChaptersPanelBlurSigma,
        ),
        child: Container(
          decoration: const BoxDecoration(
            // 渐变遮罩：顶部更通透以露出背后的模糊，底部稍深以保证列表文字可读性
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PlayerStyles.kChaptersPanelOverlayTopColor,
                PlayerStyles.kChaptersPanelOverlayBottomColor,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              Expanded(child: _buildChapterList(context)),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建面板头部
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: PlayerStyles.kChaptersPanelHeaderHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PlayerStyles.kChaptersPanelPadding,
        ),
        child: Row(
          children: [
            Text(
              PlayerI18n.t(PlayerI18nKeys.chaptersPanelTitle),
              style: const TextStyle(
                color: PlayerStyles.colorOnPrimary,
                fontSize: PlayerStyles.fontSizeTitle,
                fontWeight: PlayerStyles.fontWeightTitle,
              ),
            ),
            const SizedBox(
              width: PlayerStyles.kChaptersPanelHeaderItemSpacing,
            ),
            Text(
              PlayerI18n.t(
                PlayerI18nKeys.chaptersPanelCountFormat,
                {'count': chapters.length},
              ),
              style: const TextStyle(
                color: PlayerStyles.colorOnPrimary,
                fontSize: PlayerStyles.commonTextSize,
                fontWeight: PlayerStyles.fontWeightTitle,
              ),
            ),
            const SizedBox(
              width: PlayerStyles.kChaptersPanelHeaderItemSpacing,
            ),
            Expanded(
              child: Text(
                PlayerI18n.t(PlayerI18nKeys.chaptersPanelSubtitle),
                style: const TextStyle(
                  color: PlayerStyles.kLandscapeChapterHintColor,
                  fontSize: PlayerStyles.commonTextSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                onClose?.call();
                Navigator.of(context).pop();
              },
              child: Container(
                width: PlayerStyles.kChaptersPanelCloseButtonSize,
                height: PlayerStyles.kChaptersPanelCloseButtonSize,
                decoration: const BoxDecoration(
                  color: PlayerStyles.kChaptersPanelCloseButtonBackground,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close,
                  color: PlayerStyles.colorOnPrimary,
                  size: PlayerStyles.kChaptersPanelCloseIconSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建章节列表
  Widget _buildChapterList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: PlayerStyles.kChaptersPanelPadding,
      ),
      itemCount: chapters.length,
      separatorBuilder: (_, __) => const SizedBox(
        height: PlayerStyles.kChaptersPanelItemSpacing,
      ),
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final isSelected = index == currentIndex;
        return _buildChapterItem(
          context: context,
          index: index,
          chapter: chapter,
          isSelected: isSelected,
        );
      },
    );
  }

  /// 构建单个章节项
  Widget _buildChapterItem({
    required BuildContext context,
    required int index,
    required ChapterInfo chapter,
    required bool isSelected,
  }) {
    final timeText = FormatUtil.formatDuration(
      Duration(milliseconds: chapter.startMs),
    );

    return GestureDetector(
      onTap: () {
        onChapterSelected(index);
        Navigator.of(context).pop();
      },
      child: Container(
        height: PlayerStyles.kChaptersPanelItemHeight,
        padding: PlayerStyles.kChaptersPanelItemPadding,
        decoration: BoxDecoration(
          color: isSelected
              ? PlayerStyles.kChaptersPanelItemSelectedBackground
              : PlayerStyles.kChaptersPanelItemBackground,
          borderRadius: BorderRadius.circular(
            PlayerStyles.kChaptersPanelItemBorderRadius,
          ),
        ),
        child: Row(
          children: [
            _buildThumbnail(chapter.thumbnailUrl),
            const SizedBox(
              width: PlayerStyles.kChaptersPanelItemContentSpacing,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: const TextStyle(
                      color: PlayerStyles.colorOnPrimary,
                      fontSize: PlayerStyles.commonTextSize,
                      fontWeight: PlayerStyles.fontWeightTitle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: PlayerStyles.kChaptersPanelItemTitleTimeSpacing,
                  ),
                  Text(
                    timeText,
                    style: const TextStyle(
                      color: PlayerStyles.kChaptersPanelSecondaryTextColor,
                      fontSize: PlayerStyles.commonTextSize,
                    ),
                  ),
                ],
              ),
            ),
            const CustomIconButton(
              iconName: PlayerIcons.chapterArrow,
              iconSize: PlayerStyles.kChapterArrowIconSize,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建章节缩略图
  Widget _buildThumbnail(String? thumbnailUrl) {
    final borderRadius = BorderRadius.circular(
      PlayerStyles.kChaptersPanelThumbnailBorderRadius,
    );

    if (thumbnailUrl == null || thumbnailUrl.isEmpty) {
      return Container(
        width: PlayerStyles.kChaptersPanelThumbnailWidth,
        height: double.infinity,
        decoration: BoxDecoration(
          color: PlayerStyles.kChaptersPanelThumbnailPlaceholderBackground,
          borderRadius: borderRadius,
        ),
        child: const Icon(
          Icons.image,
          color: PlayerStyles.kChaptersPanelThumbnailPlaceholderIconColor,
          size: PlayerStyles.kChaptersPanelThumbnailPlaceholderIconSize,
        ),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        thumbnailUrl,
        width: PlayerStyles.kChaptersPanelThumbnailWidth,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: PlayerStyles.kChaptersPanelThumbnailWidth,
            height: double.infinity,
            color: PlayerStyles.kChaptersPanelThumbnailPlaceholderBackground,
            child: const Icon(
              Icons.broken_image,
              color: PlayerStyles.kChaptersPanelThumbnailPlaceholderIconColor,
              size: PlayerStyles.kChaptersPanelThumbnailPlaceholderIconSize,
            ),
          );
        },
      ),
    );
  }
}
