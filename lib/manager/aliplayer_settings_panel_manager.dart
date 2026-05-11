// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/05/06
// Brief: 设置面板管理器，统一处理横竖屏设置面板切换逻辑

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/base/safe_value_notifier.dart';
import 'package:aliplayer_widget/constants/setting_constants.dart';
import 'package:aliplayer_widget/theme/player_styles.dart';
import 'package:aliplayer_widget/ui/aliplayer_right_wheel_panel_widget.dart';
import 'package:aliplayer_widget/ui/aliplayer_settings_panel_widget.dart';
import 'package:aliplayer_widget/utils/track_info_util.dart';
import 'package:flutter/material.dart';

import '../ui/setting_item_builder.dart';

/// 设置面板管理器
///
/// 统一管理播放器设置面板的显示逻辑，支持横竖屏自动切换。
/// 所有设置相关的状态直接使用 [AliPlayerWidgetController] 的 notifier，
/// 确保横竖屏数据一致性。
class AliPlayerSettingsPanelManager {
  AliPlayerSettingsPanelManager._();

  /// 显示设置面板（自动根据 orientation 选择横竖屏样式）
  ///
  /// [context] 构建上下文
  /// [controller] 播放器控制器，用于获取状态和控制播放器
  /// [sceneType] 播放场景类型，用于过滤不适用的设置项
  /// [hiddenSlotElements] 需要隐藏的元素配置
  /// [isShowExternalSubtitle] 外挂字幕显示状态 notifier
  static Future<void> showSettingsPanel({
    required BuildContext context,
    required AliPlayerWidgetController controller,
    required SceneType sceneType,
    required Map<SlotType, Set<String>>? hiddenSlotElements,
    required SafeValueNotifier<bool> isShowExternalSubtitle,
  }) {
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      return _showPortraitPanel(
        context: context,
        controller: controller,
        sceneType: sceneType,
        hiddenSlotElements: hiddenSlotElements,
        isShowExternalSubtitle: isShowExternalSubtitle,
      );
    } else {
      return _showLandscapePanel(
        context: context,
        controller: controller,
        sceneType: sceneType,
        hiddenSlotElements: hiddenSlotElements,
        isShowExternalSubtitle: isShowExternalSubtitle,
      );
    }
  }

  /// 显示倍速面板（横屏底部按钮触发）
  ///
  /// 使用右侧滑入面板展示倍速选项
  static Future<void> showSpeedPanel({
    required BuildContext context,
    required AliPlayerWidgetController controller,
  }) {
    final items = SettingConstants.speedOptions;
    final currentSpeed = controller.speedNotifier.value;
    final initialIndex = items.indexOf(currentSpeed).clamp(0, items.length - 1);

    return showRightSettingPanel<double>(
      context: context,
      panel: RightWheelSettingPanel(
        items,
        initialIndex: initialIndex,
        onSelected: (value) {
          Navigator.of(context).pop(value);
        },
      ),
    ).then((value) {
      if (value != null) {
        controller.setSpeed(speed: value);
      }
    });
  }

  /// 显示清晰度面板（横屏底部按钮触发）
  ///
  /// 使用右侧滑入面板展示清晰度选项
  static Future<void> showQualityPanel({
    required BuildContext context,
    required AliPlayerWidgetController controller,
  }) {
    final trackInfoList = controller.trackInfoListNotifier.value;
    final List<String> qualities =
        trackInfoList != null && trackInfoList.isNotEmpty
            ? TrackInfoUtil.getQualitiesFromTrackInfos(trackInfoList)
            : [];

    // 如果是单码率流，显示 AUTO
    final List<String> items = qualities.length == 1 ? ['AUTO'] : qualities;

    // 获取当前清晰度
    final currentTrackInfo = controller.currentTrackInfoNotifier.value;
    final currentQuality = currentTrackInfo != null
        ? TrackInfoUtil.getQuality(currentTrackInfo)
        : (items.isNotEmpty ? items.first : 'AUTO');

    final initialIndex = items.indexOf(currentQuality).clamp(0, items.length - 1);

    return showRightSettingPanel<String>(
      context: context,
      panel: RightWheelSettingPanel(
        items,
        initialIndex: initialIndex,
        onSelected: (value) {
          Navigator.of(context).pop(value);
        },
      ),
    ).then((value) {
      if (value != null && value != 'AUTO' && trackInfoList != null) {
        final selectedTrack = trackInfoList.firstWhere(
          (track) => TrackInfoUtil.getQuality(track) == value,
          orElse: () => trackInfoList.first,
        );
        controller.selectTrack(selectedTrack);
      }
    });
  }

  /// 竖屏设置面板（底部 ModalBottomSheet）
  static Future<void> _showPortraitPanel({
    required BuildContext context,
    required AliPlayerWidgetController controller,
    required SceneType sceneType,
    required Map<SlotType, Set<String>>? hiddenSlotElements,
    required SafeValueNotifier<bool> isShowExternalSubtitle,
  }) {
    final hiddenElements = hiddenSlotElements?[SlotType.settingMenu];
    final itemBuilder = SettingItemBuilder(
      controller: controller,
      sceneType: sceneType,
      hiddenElements: hiddenElements,
      isShowExternalSubtitle: isShowExternalSubtitle,
    );

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) {
        // 使用 StatefulBuilder 确保在面板关闭时 dispose itemBuilder
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              top: true,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: PlayerStyles.kPortraitSettingPanelTopMargin,
                      ),
                      child: _buildPortraitSubtitleSection(itemBuilder, controller),
                    ),
                    _buildPortraitSettingsSection(itemBuilder, controller),
                    _buildPortraitTogglesSection(itemBuilder),
                    _buildPortraitDisplayModeSection(itemBuilder),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // 面板关闭时释放资源
      itemBuilder.dispose();
    });
  }

  /// 竖屏 - 外挂字幕设置区块
  static Widget _buildPortraitSubtitleSection(
    SettingItemBuilder itemBuilder,
    AliPlayerWidgetController controller,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.externalSubtitleAvailableNotifier,
      builder: (context, available, _) {
        if (!available) return const SizedBox.shrink();

        final items = itemBuilder.filterVisibleSettingItems([
          itemBuilder.buildSubtitleItem(),
        ]);
        if (items.isEmpty) return const SizedBox.shrink();

        return AliPlayerPortraitPanel(settingItems: items);
      },
    );
  }

  /// 竖屏 - 倍速/清晰度设置区块
  static Widget _buildPortraitSettingsSection(
    SettingItemBuilder itemBuilder,
    AliPlayerWidgetController controller,
  ) {
    return ValueListenableBuilder<List<AVPTrackInfo>?>(
      valueListenable: controller.trackInfoListNotifier,
      builder: (context, trackInfoList, _) {
        final List<String> qualities =
            trackInfoList != null && trackInfoList.isNotEmpty
                ? TrackInfoUtil.getQualitiesFromTrackInfos(trackInfoList)
                : [];

        final List<String> displayQualities =
            qualities.length == 1 ? ['AUTO'] : qualities;

        final items = itemBuilder.filterVisibleSettingItems([
          itemBuilder.buildSpeedItem(),
          itemBuilder.buildQualityItem(displayQualities, trackInfoList),
        ]);
        if (items.isEmpty) return const SizedBox.shrink();

        return AliPlayerPortraitPanel(settingItems: items);
      },
    );
  }

  /// 竖屏 - 循环/静音设置区块
  static Widget _buildPortraitTogglesSection(SettingItemBuilder itemBuilder) {
    final items = itemBuilder.filterVisibleSettingItems([
      itemBuilder.buildLoopItem(),
      itemBuilder.buildMuteItem(),
    ]);
    if (items.isEmpty) return const SizedBox.shrink();

    return AliPlayerPortraitPanel(settingItems: items);
  }

  /// 竖屏 - 镜像/渲染/旋转设置区块
  static Widget _buildPortraitDisplayModeSection(SettingItemBuilder itemBuilder) {
    final items = itemBuilder.filterVisibleSettingItems([
      itemBuilder.buildMirrorItem(),
      itemBuilder.buildRenderItem(),
      itemBuilder.buildRotateItem(),
    ]);
    if (items.isEmpty) return const SizedBox.shrink();

    return AliPlayerPortraitPanel(settingItems: items);
  }

  /// 横屏设置面板（右侧滑入）
  static Future<void> _showLandscapePanel({
    required BuildContext context,
    required AliPlayerWidgetController controller,
    required SceneType sceneType,
    required Map<SlotType, Set<String>>? hiddenSlotElements,
    required SafeValueNotifier<bool> isShowExternalSubtitle,
  }) {
    final hiddenElements = hiddenSlotElements?[SlotType.settingMenu];
    final itemBuilder = SettingItemBuilder(
      controller: controller,
      sceneType: sceneType,
      hiddenElements: hiddenElements,
      isShowExternalSubtitle: isShowExternalSubtitle,
    );

    // 根据外挂字幕可用性动态构建设置项列表
    final bool hasExternalSubtitle =
        controller.externalSubtitleAvailableNotifier.value;

    final items = itemBuilder.filterVisibleSettingItems([
      if (hasExternalSubtitle) itemBuilder.buildSubtitleItem(),
      itemBuilder.buildLoopItem(),
      itemBuilder.buildMuteItem(),
      itemBuilder.buildMirrorItem(),
      itemBuilder.buildRenderItem(),
      itemBuilder.buildRotateItem(),
    ]);

    return showRightSettingPanel<void>(
      width: PlayerStyles.kLandscapeSettingPanelWidth,
      context: context,
      panel: AliPlayerLandScapeSettingsPanel(settingItems: items),
    ).whenComplete(() {
      // 面板关闭时释放资源
      itemBuilder.dispose();
    });
  }
}