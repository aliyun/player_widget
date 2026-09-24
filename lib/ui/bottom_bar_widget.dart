// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 播放器自定义底部栏组件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/constants/setting_constants.dart';
import 'package:aliplayer_widget/ui/play_state_overlay.dart';
import 'package:aliplayer_widget/ui/play_state_widget.dart';
import 'package:aliplayer_widget/utils/scene_util.dart';
import 'package:aliplayer_widget/ui/chapter/chapter_chip_list_widget.dart';
import 'package:aliplayer_widget/ui/chapter/chapters_panel_manager.dart';
import 'package:aliplayer_widget/ui/custom/custom_icon_button.dart';
import 'package:aliplayer_widget/ui/custom/custom_video_slider.dart';
import 'package:aliplayer_widget/ui/common/shared_animation_widget.dart';
import 'package:aliplayer_widget/ui/setting/setting_panel_manager.dart';
import 'package:aliplayer_widget/utils/format_util.dart';
import 'package:flutter/material.dart';

/// 播放器自定义底部栏组件
class BottomBarWidget extends SharedAnimationWidget {
  /// 播放器控制器
  final AliPlayerWidgetController controller;

  /// 播放器场景类型
  final SceneType sceneType;

  /// 章节数据
  final List<ChapterInfo> chapterInfoList;

  /// 播放/暂停按钮的状态
  final bool isPlaying;

  /// 外挂字幕的显示状态
  final bool isShowExternalSubtitle;

  /// 外挂字幕按钮显示状态
  final bool isShowExternalSubtitleBtn;

  /// 播放/暂停按钮点击回调
  final VoidCallback? onPlayIconPressed;

  /// 全屏切换按钮点击回调
  final VoidCallback? onFullScreenPressed;

  /// 刷新按钮点击回调
  final VoidCallback? onReplayIconPressed;

  /// 外挂字幕显示回调
  final VoidCallback? onSubtitlePressed;

  /// 当前播放位置
  final Duration currentPosition;

  /// 视频总时长
  final Duration totalDuration;

  /// 已缓冲的位置
  final Duration bufferedPosition;

  /// 拖拽过程中触发的回调
  final ValueChanged<Duration>? onDragUpdate;

  /// 拖拽结束时触发的回调
  final ValueChanged<Duration>? onDragEnd;

  /// seek 结束时触发的回调
  final ValueChanged<Duration>? onSeekEnd;

  /// orientation
  final Orientation orientation;

  /// 构造函数
  const BottomBarWidget({
    super.key,
    required super.animationManager,
    required this.controller,
    required this.sceneType,
    required this.isPlaying,
    required this.isShowExternalSubtitle,
    required this.currentPosition,
    required this.totalDuration,
    required this.bufferedPosition,
    required this.onSubtitlePressed,
    this.chapterInfoList = const [],
    this.onPlayIconPressed,
    this.onReplayIconPressed,
    this.onFullScreenPressed,
    this.onDragUpdate,
    this.onDragEnd,
    this.onSeekEnd,
    required this.isShowExternalSubtitleBtn,
    this.orientation = Orientation.portrait,
  });

  @override
  Widget buildWrapper(BuildContext context, Widget child) {
    return Positioned(bottom: 0, left: 0, right: 0, child: child);
  }

  @override
  Widget buildContent(BuildContext context) {
    // 一次性获取隐藏配置，避免重复遍历 widget tree
    // Get hidden config once to avoid repeated widget tree traversal
    final hiddenElements = SlotManager.getHiddenElements(
      context,
      SlotType.bottomBar,
    );

    return orientation == Orientation.portrait
        ? _buildPortraitWidget(hiddenElements)
        : _buildLandscapeWidget(context, hiddenElements);
  }

  Widget _buildPortraitWidget(Set<String> hiddenElements) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChapterChipList(),
        SizedBox(
          height: PlayerStyles.kBottomBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PlayerStyles.kBottomBarPortraitHorizontalPadding,
              vertical: PlayerStyles.kBottomBarPortraitVerticalPadding,
            ),
            child: Row(
              children: [
                if (hiddenElements.isElementVisible(BottomBarElements.play))
                  _buildIconButton(
                    iconAssetName: isPlaying
                        ? PlayerIcons.pausePortrait
                        : PlayerIcons.playPortrait,
                    onTap: onPlayIconPressed,
                  ),
                _buildSlider(hiddenElements),
                if (!isSceneType(sceneType, [SceneType.live]))
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PlayerStyles.kVideoSliderHorizontalPadding,
                    ),
                    child: _buildTimeText(),
                  ),
                if (hiddenElements
                        .isElementVisible(BottomBarElements.fullscreen) &&
                    !isSceneType(sceneType, [SceneType.listPlayer]))
                  _buildIconButton(
                    iconAssetName: PlayerIcons.fullScreen,
                    onTap: onFullScreenPressed,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建章节 Chip 列表
  Widget _buildChapterChipList() {
    if (!isSceneType(sceneType, [SceneType.vod, SceneType.aiVod]) ||
        chapterInfoList.length < 2) {
      return const SizedBox.shrink();
    }

    return ChapterChipListWidget(
      chapters: chapterInfoList,
      currentIndex: _currentChapterIndexForChips,
      onChapterSelected: _onChapterSelected,
    );
  }

  Widget _buildLandscapeWidget(
    BuildContext context,
    Set<String> hiddenElements,
  ) {
    return SafeArea(
      bottom: false, // tips: 防止 iOS 端侧底部出现额外边距
      child: SizedBox(
        height: PlayerStyles.kLandscapeBottomBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PlayerStyles.kLandscapeBottomBarPadding,
          ),
          child: Column(
            children: [
              _buildLandscapeInfoRow(context),
              const SizedBox(height: 4),
              _buildSlider(hiddenElements),
              _buildControlButtons(context, hiddenElements),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建横屏信息行（有章节数据时显示章节信息，否则非直播场景显示时间，直播不显示）
  Widget _buildLandscapeInfoRow(BuildContext context) {
    final bool showChapterInfo = _effectiveChapters != null;
    final Widget child;
    if (showChapterInfo) {
      child = _buildLandscapeChapterInfoRow(context);
    } else if (!isSceneType(sceneType, [SceneType.live])) {
      child = _buildLandscapeTimeTextRow();
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PlayerStyles.kVideoSliderHorizontalPadding,
      ),
      child: child,
    );
  }

  /// 构建横屏时间文本行（无章节数据且非直播场景）
  Widget _buildLandscapeTimeTextRow() {
    return Row(
      children: [
        _buildTimeText(),
      ],
    );
  }

  /// 构建时间文本
  Widget _buildTimeText() {
    return Text(
      '${FormatUtil.formatDuration(currentPosition)}\u00A0/\u00A0${FormatUtil.formatDuration(totalDuration)}',
      style: const TextStyle(
        fontSize: PlayerStyles.commonTextSize,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: PlayerStyles.kProgressBarTimeShadowBlurRadius,
            color: PlayerStyles.kColorProgressBarTimeShadow,
          ),
        ],
      ),
    );
  }

  /// 构建横屏章节信息标题行
  Widget _buildLandscapeChapterInfoRow(BuildContext context) {
    final chapters = _effectiveChapters;
    final currentIndex = _currentChapterIndex;
    if (chapters == null ||
        currentIndex < 0 ||
        currentIndex >= chapters.length) {
      return const SizedBox.shrink();
    }

    final currentChapter = chapters[currentIndex];
    final titleText = PlayerI18n.t(PlayerI18nKeys.chapterTitleFormat, {
      'index': currentIndex + 1,
      'title': currentChapter.title,
    });
    final timeText =
        '${FormatUtil.formatDuration(currentPosition)}/${FormatUtil.formatDuration(totalDuration)}';

    return Row(
      children: [
        Text(
          timeText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: PlayerStyles.commonTextSize,
          ),
        ),
        const SizedBox(width: PlayerStyles.kLandscapeChapterInfoSpacing),
        GestureDetector(
          onTap: () => _showChaptersPanel(context),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: PlayerStyles.kLandscapeChapterTitleMaxWidth,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    titleText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: PlayerStyles.commonTextSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  width: PlayerStyles.kLandscapeChapterTitleIconSpacing,
                ),
                const CustomIconButton(
                  iconName: PlayerIcons.chapterArrow,
                  iconSize: PlayerStyles.kChapterArrowIconSize,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: PlayerStyles.kLandscapeChapterInfoSpacing),
        const Text(
          '|',
          style: TextStyle(
            color: Colors.white,
            fontSize: PlayerStyles.commonTextSize,
          ),
        ),
        const SizedBox(width: PlayerStyles.kLandscapeChapterInfoSpacing),
        GestureDetector(
          onTap: _seekToNextChapter,
          child: Text(
            PlayerI18n.t(PlayerI18nKeys.nextChapter),
            style: const TextStyle(
              color: Colors.white,
              fontSize: PlayerStyles.commonTextSize,
            ),
          ),
        ),
      ],
    );
  }

  /// 跳转到下一章节
  void _seekToNextChapter() {
    final chapters = _effectiveChapters;
    final currentIndex = _currentChapterIndex;
    if (chapters == null || currentIndex < 0) return;
    if (currentIndex >= chapters.length - 1) return;
    onSeekEnd?.call(Duration(milliseconds: chapters[currentIndex + 1].startMs));
  }

  /// 显示章节列表面板
  void _showChaptersPanel(BuildContext context) {
    final chapters = _effectiveChapters;
    final currentIndex = _currentChapterIndex;
    if (chapters == null ||
        currentIndex < 0 ||
        currentIndex >= chapters.length) {
      return;
    }

    ChaptersPanelManager.showChaptersPanel(
      context: context,
      chapters: chapters,
      currentIndex: currentIndex,
      onChapterSelected: _onChapterSelected,
    );
  }

  /// 自定义进度条组件
  Widget _buildSlider(Set<String> hiddenElements) {
    return hiddenElements.isElementVisible(BottomBarElements.progress)
        ? Expanded(
            child: CustomVideoSlider(
              currentPosition: currentPosition,
              totalDuration: totalDuration,
              bufferedPosition: bufferedPosition,
              onDragUpdate: onDragUpdate,
              onDragEnd: onDragEnd,
              onSeekEnd: onSeekEnd,
              orientation: orientation,
              chapterMarkerPositions: _chapterMarkerPositions,
              onMarkerTap: _onMarkerTap,
            ),
          )
        : const Expanded(child: SizedBox.shrink());
  }

  /// 当前有效的章节数据（仅 AI_VOD 场景且章节数 >= 2）
  ///
  /// 用于横屏章节信息行、进度条章节标记点、下一章节跳转和章节列表面板。
  List<ChapterInfo>? get _effectiveChapters {
    if (sceneType != SceneType.aiVod) return null;
    return chapterInfoList.length >= 2 ? chapterInfoList : null;
  }

  /// 当前播放位置在 Chip 列表中对应的章节索引
  int get _currentChapterIndexForChips {
    final positionMs = currentPosition.inMilliseconds;
    if (!isSceneType(sceneType, [SceneType.vod, SceneType.aiVod]) ||
        chapterInfoList.length < 2 ||
        positionMs < 0) {
      return -1;
    }
    return ChapterInfo.findIndexByPosition(chapterInfoList, positionMs);
  }

  /// 计算章节标记点在进度条上的归一化位置
  List<double>? get _chapterMarkerPositions {
    final chapters = _effectiveChapters;
    final totalMs = totalDuration.inMilliseconds;
    if (chapters == null || totalMs <= 0) return null;

    return chapters
        .map((chapter) => chapter.startMs / totalMs)
        .where((pos) => pos > 0.0 && pos < 1.0)
        .toList();
  }

  /// 当前播放位置对应的章节索引
  int get _currentChapterIndex {
    final chapters = _effectiveChapters;
    final positionMs = currentPosition.inMilliseconds;
    if (chapters == null || positionMs < 0) return -1;
    return ChapterInfo.findIndexByPosition(chapters, positionMs);
  }

  /// 章节 Chip 点击处理
  void _onChapterSelected(int index) {
    if (index < 0 || index >= chapterInfoList.length) return;
    onSeekEnd?.call(Duration(milliseconds: chapterInfoList[index].startMs));
  }

  /// 进度条章节标记点击处理
  ///
  /// [normalizedPosition] 归一化位置 (0.0 ~ 1.0)
  void _onMarkerTap(double normalizedPosition) {
    final totalMs = totalDuration.inMilliseconds;
    if (totalMs <= 0) return;
    final seekTimeMs = (normalizedPosition * totalMs).toInt();
    onSeekEnd?.call(Duration(milliseconds: seekTimeMs));
  }

  /// 横屏进度条组件，底部Button 栏
  Widget _buildControlButtons(
    BuildContext context,
    Set<String> hiddenElements,
  ) {
    // 1. 提取状态判断，避免重复计算和魔法字符串/枚举比较
    final bool isLiveOrRestricted = isSceneType(sceneType, [
      SceneType.live,
      SceneType.restricted,
    ]);
    final bool isLiveOnly = isSceneType(sceneType, [SceneType.live]);

    // 2. 提取左侧按钮列表，使主结构更清晰
    final List<Widget> leftButtons = [];

    // Play/Pause Button
    if (hiddenElements.isElementVisible(BottomBarElements.play)) {
      leftButtons.add(
        _buildIconButton(
          iconAssetName: isPlaying ? PlayerIcons.pause : PlayerIcons.play,
          iconAssetSize: const Size(
            PlayerStyles.kBottomBarIconSize,
            PlayerStyles.kBottomBarIconSize,
          ),
          onTap: onPlayIconPressed,
        ),
      );
    }

    // Refresh Button (Live only)
    if (isLiveOnly &&
        hiddenElements.isElementVisible(BottomBarElements.refresh)) {
      leftButtons.add(
        _buildIconButton(
          iconAssetName: PlayerIcons.refresh,
          onTap: onReplayIconPressed,
        ),
      );
    }

    // Subtitle Button
    if (isShowExternalSubtitleBtn &&
        hiddenElements.isElementVisible(BottomBarElements.subtitle)) {
      leftButtons.add(
        _buildIconButton(
          iconAssetName: isShowExternalSubtitle
              ? PlayerIcons.subtitleOpen
              : PlayerIcons.subtitleClose,
          onTap: onSubtitlePressed,
        ),
      );
    }

    // 3. 提取右侧按钮列表
    final List<Widget> rightButtons = [];

    // Speed Button (Not Live/Restricted)
    if (!isLiveOrRestricted &&
        hiddenElements.isElementVisible(BottomBarElements.speed)) {
      rightButtons.add(
        _buildControlButton(
          text: PlayerI18n.t(PlayerI18nKeys.speed),
          onTap: () => SettingPanelManager.showItemPanel(
            context: context,
            controller: controller,
            elementKey: SettingMenuElements.speed,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: PlayerStyles.kBottomBarButtonPadding,
            vertical: PlayerStyles.kBottomBarControlBtnPadding,
          ),
        ),
      );
    }

    // Quality Button (Not Live/Restricted)
    if (!isLiveOrRestricted &&
        hiddenElements.isElementVisible(BottomBarElements.quality)) {
      rightButtons.add(
        _buildControlButton(
          text: PlayerI18n.t(PlayerI18nKeys.quality),
          onTap: () => SettingPanelManager.showItemPanel(
            context: context,
            controller: controller,
            elementKey: SettingMenuElements.trackInfo,
          ),
          padding: const EdgeInsets.only(
            top: PlayerStyles.kBottomBarControlBtnPadding,
            left: PlayerStyles.kBottomBarControlBtnPadding,
            bottom: PlayerStyles.kBottomBarControlBtnPadding,
          ),
        ),
      );
    }

    // 4. 构建最终布局
    return Row(
      children: [
        leftButtons.isEmpty
            ? const SizedBox.shrink()
            : Container(
                padding: (isLiveOrRestricted
                    ? const EdgeInsets.symmetric(
                        vertical: PlayerStyles.kBottomBarControlBtnPadding,
                      )
                    : null),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: leftButtons,
                ),
              ),
        const Spacer(),
        // 右侧按钮组
        Row(
          mainAxisSize: MainAxisSize.min,
          children: rightButtons,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required String iconAssetName,
    VoidCallback? onTap,
    EdgeInsets? margin,
    Size? iconAssetSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: PlayerStyles.commonIconSize,
        height: PlayerStyles.commonIconSize,
        child: CustomIconButton(
          iconName: iconAssetName,
          iconSize: iconAssetSize ??
              const Size(
                PlayerStyles.commonIconSize,
                PlayerStyles.commonIconSize,
              ),
          margin: margin ?? const EdgeInsets.symmetric(),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String text,
    VoidCallback? onTap,
    EdgeInsetsGeometry? padding,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // 确保点击区域完整
      child: Container(
        padding: padding,
        alignment: Alignment.center,
        // 如果需要背景色
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: PlayerStyles.commonTextSize,
          ),
        ),
      ),
    );
  }
}

// ── 拖拽回调（文件级私有） ────────────────────────────────────────────

/// 进度条拖拽更新回调。
void _onDragUpdate(
  SlotBuildContext ctx,
  Duration duration,
) {
  ctx.controller.requestThumbnailBitmap(duration);
  ctx.dragStartPosition ??= ctx.controller.currentPositionNotifier.value;
  ctx.controller.isDraggingNotifier.value = true;
  ctx.controller.currentSeekTimeNotifier.value = duration;
}

/// 进度条拖拽结束回调。
void _onDragEnd(
  SlotBuildContext ctx,
  Duration duration,
) {
  final startPosition = ctx.dragStartPosition ?? Duration.zero;
  final dragDistance = (duration - startPosition).abs();

  ctx.controller.isDraggingNotifier.value = false;
  ctx.controller.currentSeekTimeNotifier.value = Duration.zero;
  ctx.dragStartPosition = null;

  // 只有拖拽距离超过阈值时间, 才认为是真正的拖拽操作
  const threshold = Duration(seconds: 1);
  if (dragDistance > threshold && ctx.animationManager.isVisible) {
    Future.delayed(SettingConstants.defaultAutoHideControlsDuration, () {
      if (ctx.animationManager.isDisposed) return;
      if (!ctx.controller.isDraggingNotifier.value &&
          ctx.animationManager.isVisible) {
        ctx.animationManager.hide();
        ctx.controller.controlBarVisibleNotifier.value = false;
      }
    });
  }
}

/// 外挂字幕显示切换回调。
void _toggleSubtitleShow(
  BuildContext buildContext,
  AliPlayerWidgetController controller,
) {
  controller.showExternalSubtitleNotifier.value =
      !controller.showExternalSubtitleNotifier.value;

  PlayStateShowUtil.show(
    buildContext,
    widgetStatus: PlayStatus.info,
    statusMessage: PlayerI18n.t(
      controller.showExternalSubtitleNotifier.value
          ? PlayerI18nKeys.subtitleOn
          : PlayerI18nKeys.subtitleOff,
    ),
  );
}

/// 构建底部栏插槽的默认实现。
/// Builds the default bottom bar slot content.
///
/// 监听播放状态、进度、缓冲、总时长、字幕等状态变化，
/// 提供完整的底部播放控制栏 UI。
///
/// Listens to play state, position, buffering, duration, and subtitle state;
/// provides the full bottom playback control bar UI.
Widget buildBottomBarSlot(
  SlotBuildContext ctx,
  double width,
  double height,
) {
  // 监听播放状态、当前播放位置、缓冲位置、总时长、场景类型等
  final listenable = Listenable.merge([
    ctx.controller.playStateNotifier,
    ctx.controller.currentPositionNotifier,
    ctx.controller.bufferedPositionNotifier,
    ctx.controller.totalDurationNotifier,
    ctx.controller.externalSubtitleAvailableNotifier,
    ctx.controller.showExternalSubtitleNotifier,
    ctx.controller.sceneTypeNotifier,
  ]);

  return ListenableBuilder(
    listenable: listenable,
    builder: (context, _) {
      final sceneType = ctx.controller.sceneTypeNotifier.value;
      final enableDrag = isNotSceneType(sceneType, [
        SceneType.live,
        SceneType.restricted,
      ]);
      final enableSeek = isNotSceneType(sceneType, [
        SceneType.live,
        SceneType.restricted,
      ]);

      // 获取播放状态
      final playState = ctx.controller.playStateNotifier.value;
      // 获取当前播放位置、缓冲位置、总时长
      final currentPosition = ctx.controller.currentPositionNotifier.value;
      final bufferedPosition = ctx.controller.bufferedPositionNotifier.value;
      final totalDuration = ctx.controller.totalDurationNotifier.value;
      // 初始化章节信息（章节数需 >= 2 才展示）
      final chapters = ctx.controller.widgetData?.chapters ?? const [];
      final chapterInfoList =
          chapters.length >= 2 ? chapters : const <ChapterInfo>[];

      return BottomBarWidget(
        animationManager: ctx.animationManager,
        controller: ctx.controller,
        sceneType: sceneType,
        chapterInfoList: chapterInfoList,
        orientation: MediaQuery.of(context).orientation,
        isPlaying: playState == FlutterAvpdef.started,
        currentPosition: currentPosition,
        bufferedPosition: bufferedPosition,
        totalDuration: totalDuration,
        onPlayIconPressed: () {
          if (ctx.controller.isDraggingNotifier.value) return;
          final wasVisible = ctx.animationManager.isVisible;
          ctx.animationManager.toggle();
          ctx.controller.controlBarVisibleNotifier.value = !wasVisible;
          ctx.controller.togglePlayState();
        },
        onReplayIconPressed: ctx.controller.replay,
        onFullScreenPressed: ctx.controller.toggleFullscreen,
        onSubtitlePressed: () => _toggleSubtitleShow(
          context,
          ctx.controller,
        ),
        onDragUpdate:
            enableDrag ? (duration) => _onDragUpdate(ctx, duration) : null,
        onDragEnd: enableDrag ? (duration) => _onDragEnd(ctx, duration) : null,
        onSeekEnd:
            enableSeek ? (duration) => ctx.controller.seek(duration) : null,
        isShowExternalSubtitle:
            ctx.controller.showExternalSubtitleNotifier.value,
        isShowExternalSubtitleBtn:
            ctx.controller.externalSubtitleAvailableNotifier.value,
      );
    },
  );
}
