// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/05/06
// Brief: 设置项构建器，直接使用 controller notifier 构建设置项

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/base/safe_value_notifier.dart';
import 'package:aliplayer_widget/constants/setting_constants.dart';
import 'package:aliplayer_widget/slot/slot_constants.dart';
import 'package:aliplayer_widget/slot/slot_elements.dart';
import 'package:aliplayer_widget/slot/slot_manager.dart';
import 'package:aliplayer_widget/ui/aliplayer_settings_panel_widget.dart';
import 'package:aliplayer_widget/utils/track_info_util.dart';
import 'package:flutter/foundation.dart';

/// 设置项构建器
///
/// 将设置项构建逻辑从 [AliPlayerWidget] 中剥离，直接使用
/// [AliPlayerWidgetController] 的 notifier，确保横竖屏数据一致性。
///
/// 对于 int 类型的状态（镜像、旋转、渲染），自动转换为 String 用于 UI 显示。
///
/// **重要**: 使用完毕后必须调用 [dispose] 释放资源，移除注册的 listener。
class SettingItemBuilder {
  final AliPlayerWidgetController controller;
  final SceneType sceneType;
  final Set<String>? hiddenElements;
  final SafeValueNotifier<bool> isShowExternalSubtitle;

  /// 包装 Notifier 的 dispose 列表
  final List<ValueNotifier> _wrappedNotifiers = [];

  /// 保存 listener 函数引用，用于 dispose 时移除
  final List<void Function()> _listenerRemovers = [];

  /// 标记是否已 dispose
  bool _disposed = false;

  SettingItemBuilder({
    required this.controller,
    required this.sceneType,
    required this.hiddenElements,
    required this.isShowExternalSubtitle,
  });

  /// 释放包装 Notifier 和移除 listener
  void dispose() {
    _disposed = true;

    // 移除所有注册的 listener
    for (final remover in _listenerRemovers) {
      remover();
    }
    _listenerRemovers.clear();

    // dispose 包装的 ValueNotifier
    for (final notifier in _wrappedNotifiers) {
      notifier.dispose();
    }
    _wrappedNotifiers.clear();
  }

  /// 过滤可见的设置项
  ///
  /// 根据 SceneType 和 hiddenSlotElements 配置过滤设置项
  List<SettingItem> filterVisibleSettingItems(List<SettingItem> items) {
    // Capture hiddenElements to a local variable for null safety promotion inside closure
    final localHiddenElements = hiddenElements;

    return items.where((item) {
      final key = item.elementKey;
      if (key == null) return true;

      // 1. SceneType 过滤
      final elementConfig = SlotConstants.settingElementConfigs[key];
      if (elementConfig != null &&
          elementConfig.excludedScenes.contains(sceneType)) {
        return false;
      }

      // 2. hiddenSlotElements 过滤
      if (localHiddenElements != null &&
          localHiddenElements.isNotEmpty &&
          !localHiddenElements.isElementVisible(key)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// 构建字幕设置项
  SettingItem buildSubtitleItem() {
    return SettingItem(
      elementKey: SettingMenuElements.subtitle,
      type: SettingItemType.switcher,
      title: PlayerI18n.t(PlayerI18nKeys.subtitle),
      switchListenable: isShowExternalSubtitle,
      onSwitchChanged: (v) {
        isShowExternalSubtitle.value = v;
      },
    );
  }

  /// 构建倍速设置项
  SettingItem<double> buildSpeedItem() {
    return SettingItem<double>(
      elementKey: SettingMenuElements.speed,
      type: SettingItemType.tags,
      title: PlayerI18n.t(PlayerI18nKeys.speed),
      tags: SettingConstants.speedOptions,
      tagToDisplayText: (tag) {
        if (tag == null || tag is! double) return '';
        return PlayerI18n.t(PlayerI18nKeys.speedFormat, {'speed': tag});
      },
      selectedTagListenable: controller.speedNotifier,
      onTagTap: (tag) {
        controller.setSpeed(speed: tag as double);
      },
    );
  }

  /// 构建清晰度设置项
  ///
  /// [displayQualities] 显示的清晰度列表（单码率时为 ['AUTO'])
  /// [trackInfoList] 原始清晰度信息列表
  SettingItem<String> buildQualityItem(
    List<String> displayQualities,
    List<AVPTrackInfo>? trackInfoList,
  ) {
    // 创建当前清晰度的 String notifier
    final qualityNotifier = _wrapQualityNotifier(trackInfoList);
    _wrappedNotifiers.add(qualityNotifier);

    return SettingItem<String>(
      elementKey: SettingMenuElements.trackInfo,
      type: SettingItemType.tags,
      title: PlayerI18n.t(PlayerI18nKeys.quality),
      tags: displayQualities,
      selectedTagListenable: qualityNotifier,
      onTagTap: (tag) {
        // 只有非 AUTO 模式才切换清晰度
        if (tag != 'AUTO' && tag is String && trackInfoList != null) {
          final selectedTrack = trackInfoList.firstWhere(
            (track) => TrackInfoUtil.getQuality(track) == tag,
            orElse: () => trackInfoList.first,
          );
          controller.selectTrack(selectedTrack);
        }
      },
    );
  }

  /// 构建循环播放设置项
  SettingItem buildLoopItem() {
    return SettingItem(
      elementKey: SettingMenuElements.loop,
      type: SettingItemType.switcher,
      title: PlayerI18n.t(PlayerI18nKeys.loop),
      switchListenable: controller.isLoopNotifier,
      onSwitchChanged: (v) {
        controller.setLoop(v);
      },
    );
  }

  /// 构建静音设置项
  SettingItem buildMuteItem() {
    return SettingItem(
      elementKey: SettingMenuElements.mute,
      type: SettingItemType.switcher,
      title: PlayerI18n.t(PlayerI18nKeys.mute),
      switchListenable: controller.isMuteNotifier,
      onSwitchChanged: (v) {
        controller.setMute(v);
      },
    );
  }

  /// 构建镜像模式设置项
  SettingItem buildMirrorItem() {
    final mirrorNotifier = _wrapMirrorNotifier();
    _wrappedNotifiers.add(mirrorNotifier);

    return SettingItem(
      elementKey: SettingMenuElements.mirrorMode,
      type: SettingItemType.tags,
      title: PlayerI18n.t(PlayerI18nKeys.mirrorMode),
      tags: SettingConstants.mirrorModeOptions,
      tagToDisplayText: (tag) {
        if (tag == null || tag is! int) return '';
        switch (tag) {
          case MirrorMode.MIRROR_MODE_NONE:
            return PlayerI18n.t(PlayerI18nKeys.mirrorNone);
          case MirrorMode.MIRROR_MODE_HORIZONTAL:
            return PlayerI18n.t(PlayerI18nKeys.mirrorHorizontal);
          case MirrorMode.MIRROR_MODE_VERTICAL:
            return PlayerI18n.t(PlayerI18nKeys.mirrorVertical);
          default:
            return '';
        }
      },
      selectedTagListenable: mirrorNotifier,
      onTagTap: (tag) {
        if (tag != null && tag is int) {
          controller.setMirrorMode(tag);
        }
      },
    );
  }

  /// 构建渲染模式设置项
  SettingItem buildRenderItem() {
    final scaleNotifier = _wrapScaleNotifier();
    _wrappedNotifiers.add(scaleNotifier);

    return SettingItem(
      elementKey: SettingMenuElements.scaleMode,
      type: SettingItemType.tags,
      title: PlayerI18n.t(PlayerI18nKeys.scaleMode),
      tags: SettingConstants.scaleModeOptions,
      tagToDisplayText: (tag) {
        if (tag == null || tag is! int) return '';
        switch (tag) {
          case ScaleMode.SCALE_TO_FILL:
            return PlayerI18n.t(PlayerI18nKeys.scaleFill);
          case ScaleMode.SCALE_ASPECT_FIT:
            return PlayerI18n.t(PlayerI18nKeys.scaleFit);
          case ScaleMode.SCALE_ASPECT_FILL:
            return PlayerI18n.t(PlayerI18nKeys.scaleCrop);
          default:
            return '';
        }
      },
      selectedTagListenable: scaleNotifier,
      onTagTap: (tag) {
        if (tag != null && tag is int) {
          controller.setScaleMode(tag);
        }
      },
    );
  }

  /// 构建旋转角度设置项
  SettingItem buildRotateItem() {
    final rotateNotifier = _wrapRotateNotifier();
    _wrappedNotifiers.add(rotateNotifier);

    return SettingItem(
      elementKey: SettingMenuElements.rotateMode,
      type: SettingItemType.tags,
      title: PlayerI18n.t(PlayerI18nKeys.rotateMode),
      tags: SettingConstants.rotateModeOptions,
      tagToDisplayText: (tag) {
        if (tag == null || tag is! int) return '';
        return PlayerI18n.t(PlayerI18nKeys.rotateFormat, {'degree': tag});
      },
      selectedTagListenable: rotateNotifier,
      onTagTap: (tag) {
        if (tag != null && tag is int) {
          controller.setRotateMode(tag);
        }
      },
    );
  }

  /// 包装镜像模式
  ValueNotifier _wrapMirrorNotifier() {
    final result = ValueNotifier(controller.mirrorModeNotifier.value);

    void listener() {
      if (_disposed) return;
      result.value = controller.mirrorModeNotifier.value;
    }

    controller.mirrorModeNotifier.addListener(listener);

    _listenerRemovers.add(() {
      controller.mirrorModeNotifier.removeListener(listener);
    });

    return result;
  }

  /// 包装旋转角度
  ValueNotifier _wrapRotateNotifier() {
    final result = ValueNotifier(controller.rotateModeNotifier.value);

    void listener() {
      if (_disposed) return;
      result.value = controller.rotateModeNotifier.value;
    }

    controller.rotateModeNotifier.addListener(listener);

    _listenerRemovers.add(() {
      controller.rotateModeNotifier.removeListener(listener);
    });

    return result;
  }

  /// 包装渲染模式 notifier（int → String）
  ValueNotifier _wrapScaleNotifier() {
    final result = ValueNotifier(controller.scaleModeNotifier.value);

    void listener() {
      if (_disposed) return;
      result.value = controller.scaleModeNotifier.value;
    }

    controller.scaleModeNotifier.addListener(listener);

    _listenerRemovers.add(() {
      controller.scaleModeNotifier.removeListener(listener);
    });

    return result;
  }

  /// 包装清晰度 notifier（从 trackInfo 获取 String）
  ValueNotifier<String> _wrapQualityNotifier(
    List<AVPTrackInfo>? trackInfoList,
  ) {
    String initial = 'AUTO';
    final currentTrack = controller.currentTrackInfoNotifier.value;
    if (currentTrack != null) {
      initial = TrackInfoUtil.getQuality(currentTrack);
    } else if (trackInfoList != null && trackInfoList.isNotEmpty) {
      initial = TrackInfoUtil.getQuality(trackInfoList.first);
    }

    final result = ValueNotifier<String>(initial);

    void listener() {
      if (_disposed) return;
      final track = controller.currentTrackInfoNotifier.value;
      if (track != null) {
        result.value = TrackInfoUtil.getQuality(track);
      }
    }

    controller.currentTrackInfoNotifier.addListener(listener);
    _listenerRemovers.add(() {
      controller.currentTrackInfoNotifier.removeListener(listener);
    });

    return result;
  }
}
