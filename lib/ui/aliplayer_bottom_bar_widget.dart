// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 播放器自定义底部栏组件

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/slot/slot_elements.dart';
import 'package:aliplayer_widget/slot/slot_manager.dart';
import 'package:aliplayer_widget/theme/player_styles.dart';
import 'package:aliplayer_widget/utils/scene_util.dart';
import 'package:flutter/material.dart';

import '../theme/player_icons.dart';
import 'aliplayer_custom_button.dart';
import 'aliplayer_shared_animation_widget.dart';
import '../manager/aliplayer_settings_panel_manager.dart';
import 'aliplayer_video_slider.dart';

/// 播放器自定义底部栏组件
class AliPlayerBottomBarWidget extends AliPlayerSharedAnimationWidget {
  /// 播放器控制器
  final AliPlayerWidgetController controller;

  /// 播放器场景类型
  final SceneType sceneType;

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
  const AliPlayerBottomBarWidget({
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
    return SizedBox(
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
            if (hiddenElements.isElementVisible(BottomBarElements.fullscreen) &&
                !isSceneType(sceneType, [SceneType.listPlayer]))
              _buildIconButton(
                  iconAssetName: PlayerIcons.fullScreen,
                  onTap: onFullScreenPressed),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeWidget(
      BuildContext context, Set<String> hiddenElements) {
    return SafeArea(
      bottom: false, // tips: 防止 iOS 端侧底部出现额外边距
      child: SizedBox(
        height: PlayerStyles.kLandscapeBottomBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PlayerStyles.kLandscapeBottomBarPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSlider(hiddenElements),
              _buildControlButtons(context, hiddenElements),
            ],
          ),
        ),
      ),
    );
  }

  /// 自定义进度条组件
  Widget _buildSlider(Set<String> hiddenElements) {
    return (!isSceneType(sceneType, [SceneType.live])) &&
            (hiddenElements.isElementVisible(BottomBarElements.progress))
        ? Expanded(
            child: AliPlayerVideoSlider(
              currentPosition: currentPosition,
              totalDuration: totalDuration,
              bufferedPosition: bufferedPosition,
              onDragUpdate: onDragUpdate,
              onDragEnd: onDragEnd,
              onSeekEnd: onSeekEnd,
              orientation: orientation,
            ),
          )
        : const Expanded(child: SizedBox.shrink());
  }

  /// 横屏进度条组件，底部Button 栏
  Widget _buildControlButtons(
      BuildContext context, Set<String> hiddenElements) {
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
      leftButtons.add(_buildIconButton(
        iconAssetName: isPlaying ? PlayerIcons.pause : PlayerIcons.play,
        iconAssetSize: const Size(
          PlayerStyles.kBottomBarIconSize,
          PlayerStyles.kBottomBarIconSize,
        ),
        onTap: onPlayIconPressed,
      ));
    }

    // Refresh Button (Live only)
    if (isLiveOnly &&
        hiddenElements.isElementVisible(BottomBarElements.refresh)) {
      leftButtons.add(_buildIconButton(
        iconAssetName: PlayerIcons.refresh,
        onTap: onReplayIconPressed,
      ));
    }

    // Subtitle Button
    if (isShowExternalSubtitleBtn &&
        hiddenElements.isElementVisible(BottomBarElements.subtitle)) {
      leftButtons.add(_buildIconButton(
        iconAssetName: isShowExternalSubtitle
            ? PlayerIcons.subtitleOpen
            : PlayerIcons.subtitleClose,
        onTap: onSubtitlePressed,
      ));
    }

    // 3. 提取右侧按钮列表
    final List<Widget> rightButtons = [];

    // Speed Button (Not Live/Restricted)
    if (!isLiveOrRestricted &&
        hiddenElements.isElementVisible(BottomBarElements.speed)) {
      rightButtons.add(_buildControlButton(
        text: PlayerI18n.t(PlayerI18nKeys.speed),
        onTap: () => AliPlayerSettingsPanelManager.showSpeedPanel(
          context: context,
          controller: controller,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: PlayerStyles.kBottomBarButtonPadding,
          vertical: PlayerStyles.kBottomBarControlBtnPadding,
        ),
      ));
    }

    // Quality Button (Not Live/Restricted)
    if (!isLiveOrRestricted &&
        hiddenElements.isElementVisible(BottomBarElements.quality)) {
      rightButtons.add(_buildControlButton(
        text: PlayerI18n.t(PlayerI18nKeys.quality),
        onTap: () => AliPlayerSettingsPanelManager.showQualityPanel(
          context: context,
          controller: controller,
        ),
        padding: const EdgeInsets.only(
          top: PlayerStyles.kBottomBarControlBtnPadding,
          left: PlayerStyles.kBottomBarControlBtnPadding,
          bottom: PlayerStyles.kBottomBarControlBtnPadding,
        ),
      ));
    }

    // 4. 构建最终布局
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左侧容器
        leftButtons.isEmpty
            ? const SizedBox.shrink()
            : Container(
                padding: (isLiveOrRestricted
                    ? const EdgeInsets.symmetric(
                        vertical: PlayerStyles.kBottomBarControlBtnPadding)
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
          margin: margin ??
              const EdgeInsets.symmetric(
                horizontal: 0,
              ),
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
