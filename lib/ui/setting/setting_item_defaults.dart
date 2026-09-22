// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/09/14
// Brief: 内置默认设置项的注册逻辑

part of 'setting_item_registry.dart';

/// 注册内置默认设置项的定义、构建工厂、可见性工厂和面板动作
///
/// Registers definitions, build factories, visibility factories,
/// and panel actions for the 8 built-in default setting items.
void _registerBuiltInDefaults() {
  // 1. 字幕开关 ---------------------------------------------------------------
  SettingItemRegistry._definitions.add(
    const SettingItemDefinition(
      elementKey: SettingMenuElements.subtitle,
      group: SettingItemGroup.subtitle,
      excludedScenes: {SceneType.live},
    ),
  );
  SettingItemRegistry._visibilityFactories[SettingMenuElements.subtitle] =
      (c, _) => c.externalSubtitleAvailableNotifier;
  SettingItemRegistry._factories[SettingMenuElements.subtitle] =
      (controller, disposeBag) {
    return SettingItem(
      elementKey: SettingMenuElements.subtitle,
      type: SettingItemType.switcher,
      title: PlayerI18n.t(PlayerI18nKeys.subtitle),
      switchListenable: controller.showExternalSubtitleNotifier,
      onSwitchChanged: (v) {
        controller.showExternalSubtitleNotifier.value = v;
      },
    );
  };

  // 2. 倍速 -------------------------------------------------------------------
  SettingItemRegistry._definitions.add(
    const SettingItemDefinition(
      elementKey: SettingMenuElements.speed,
      group: SettingItemGroup.playback,
      excludedScenes: {SceneType.live, SceneType.restricted},
      showInLandscapePanel: false,
    ),
  );
  SettingItemRegistry._factories[SettingMenuElements.speed] =
      (controller, disposeBag) {
    return SettingItem<double>(
      elementKey: SettingMenuElements.speed,
      type: SettingItemType.tags,
      title: PlayerI18n.t(PlayerI18nKeys.speed),
      tags: controller.widgetData?.playbackSpeeds ??
          SettingConstants.speedOptions,
      tagToDisplayText: (tag) {
        if (tag == null || tag is! double) return '';
        return FormatUtil.formatSpeed(tag);
      },
      selectedTagListenable: controller.speedNotifier,
      onTagTap: (tag) {
        if (tag is double) {
          controller.setSpeed(speed: tag);
        }
      },
    );
  };

  // 3. 清晰度 -----------------------------------------------------------------
  SettingItemRegistry._definitions.add(
    const SettingItemDefinition(
      elementKey: SettingMenuElements.trackInfo,
      group: SettingItemGroup.playback,
      showInLandscapePanel: false,
    ),
  );
  SettingItemRegistry._visibilityFactories[SettingMenuElements.trackInfo] =
      (c, disposeBag) {
    // 仅当 trackInfoList 非空且有多条轨道时才显示
    // Only visible when trackInfoList is non-null and has multiple tracks
    final notifier = ValueNotifier<bool>(false);

    void update() {
      final list = c.trackInfoListNotifier.value;
      notifier.value = list != null && list.length > 1;
    }

    update();
    c.trackInfoListNotifier.addListener(update);

    // 注册到 disposeBag，面板关闭时释放 notifier 并移除源监听
    disposeBag.add(
      _DisposableNotifier<bool>(
        wrapped: notifier,
        source: c.trackInfoListNotifier,
        listener: update,
      ),
    );

    return notifier;
  };
  SettingItemRegistry._factories[SettingMenuElements.trackInfo] =
      (controller, disposeBag) {
    final trackInfoList = controller.trackInfoListNotifier.value;

    // 计算显示的清晰度列表
    final displayQualities = (trackInfoList != null && trackInfoList.isNotEmpty)
        ? TrackInfoUtil.getQualitiesFromTrackInfos(trackInfoList)
        : <String>[TrackInfoUtil.autoQualityKey];

    // 包装清晰度 notifier（从 TrackInfo 转换为 String）
    final qualityNotifier = _wrapQualityNotifier(
      controller,
      trackInfoList,
      disposeBag,
    );

    return SettingItem<String>(
      elementKey: SettingMenuElements.trackInfo,
      type: SettingItemType.tags,
      title: PlayerI18n.t(PlayerI18nKeys.quality),
      tags: displayQualities,
      tagToDisplayText: (tag) => _formatQualityLabel(tag),
      selectedTagListenable: qualityNotifier,
      onTagTap: (tag) {
        // 只有非 AUTO 模式才切换清晰度
        if (tag == TrackInfoUtil.autoQualityKey || tag is! String) return;

        // 点击时重新读取，避免使用面板创建时捕获的过期轨道列表。
        final currentTrackInfoList = controller.trackInfoListNotifier.value;
        if (currentTrackInfoList == null || currentTrackInfoList.isEmpty) {
          return;
        }
        final selectedTrack = currentTrackInfoList.firstWhere(
          (track) => TrackInfoUtil.getQuality(track) == tag,
          orElse: () => currentTrackInfoList.first,
        );
        controller.selectTrack(selectedTrack);
      },
    );
  };

  // 4. 循环播放 ---------------------------------------------------------------
  SettingItemRegistry._definitions.add(
    const SettingItemDefinition(
      elementKey: SettingMenuElements.loop,
      group: SettingItemGroup.toggles,
      excludedScenes: {SceneType.live},
    ),
  );
  SettingItemRegistry._factories[SettingMenuElements.loop] =
      (controller, disposeBag) {
    return SettingItem(
      elementKey: SettingMenuElements.loop,
      type: SettingItemType.switcher,
      title: PlayerI18n.t(PlayerI18nKeys.loop),
      switchListenable: controller.isLoopNotifier,
      onSwitchChanged: (v) {
        controller.setLoop(v);
      },
    );
  };

  // 5. 静音 -------------------------------------------------------------------
  SettingItemRegistry._definitions.add(
    const SettingItemDefinition(
      elementKey: SettingMenuElements.mute,
      group: SettingItemGroup.toggles,
    ),
  );
  SettingItemRegistry._factories[SettingMenuElements.mute] =
      (controller, disposeBag) {
    return SettingItem(
      elementKey: SettingMenuElements.mute,
      type: SettingItemType.switcher,
      title: PlayerI18n.t(PlayerI18nKeys.mute),
      switchListenable: controller.isMuteNotifier,
      onSwitchChanged: (v) {
        controller.setMute(v);
      },
    );
  };

  // 6. 镜像模式 ---------------------------------------------------------------
  SettingItemRegistry._definitions.add(
    const SettingItemDefinition(
      elementKey: SettingMenuElements.mirrorMode,
      group: SettingItemGroup.display,
    ),
  );
  SettingItemRegistry._factories[SettingMenuElements.mirrorMode] =
      (controller, disposeBag) {
    final mirrorNotifier = SettingItemRegistry.wrapNotifier<int>(
      controller.mirrorModeNotifier,
      disposeBag,
    );

    return SettingItem(
      elementKey: SettingMenuElements.mirrorMode,
      type: SettingItemType.tags,
      title: PlayerI18n.t(PlayerI18nKeys.mirrorMode),
      tags: SettingConstants.mirrorModeOptions,
      tagToDisplayText: (tag) {
        if (tag == null || tag is! int) return '';
        return FormatUtil.formatMirrorMode(tag);
      },
      selectedTagListenable: mirrorNotifier,
      onTagTap: (tag) {
        if (tag != null && tag is int) {
          controller.setMirrorMode(tag);
        }
      },
    );
  };

  // 7. 渲染填充模式 -----------------------------------------------------------
  SettingItemRegistry._definitions.add(
    const SettingItemDefinition(
      elementKey: SettingMenuElements.scaleMode,
      group: SettingItemGroup.display,
    ),
  );
  SettingItemRegistry._factories[SettingMenuElements.scaleMode] =
      (controller, disposeBag) {
    final scaleNotifier = SettingItemRegistry.wrapNotifier<int>(
      controller.scaleModeNotifier,
      disposeBag,
    );

    return SettingItem(
      elementKey: SettingMenuElements.scaleMode,
      type: SettingItemType.tags,
      title: PlayerI18n.t(PlayerI18nKeys.scaleMode),
      tags: SettingConstants.scaleModeOptions,
      tagToDisplayText: (tag) {
        if (tag == null || tag is! int) return '';
        return FormatUtil.formatScaleMode(tag);
      },
      selectedTagListenable: scaleNotifier,
      onTagTap: (tag) {
        if (tag != null && tag is int) {
          controller.setScaleMode(tag);
        }
      },
    );
  };

  // 8. 旋转角度 ---------------------------------------------------------------
  SettingItemRegistry._definitions.add(
    const SettingItemDefinition(
      elementKey: SettingMenuElements.rotateMode,
      group: SettingItemGroup.display,
    ),
  );
  SettingItemRegistry._factories[SettingMenuElements.rotateMode] =
      (controller, disposeBag) {
    final rotateNotifier = SettingItemRegistry.wrapNotifier<int>(
      controller.rotateModeNotifier,
      disposeBag,
    );

    return SettingItem(
      elementKey: SettingMenuElements.rotateMode,
      type: SettingItemType.tags,
      title: PlayerI18n.t(PlayerI18nKeys.rotateMode),
      tags: SettingConstants.rotateModeOptions,
      tagToDisplayText: (tag) {
        if (tag == null || tag is! int) return '';
        return FormatUtil.formatRotate(tag);
      },
      selectedTagListenable: rotateNotifier,
      onTagTap: (tag) {
        if (tag != null && tag is int) {
          controller.setRotateMode(tag);
        }
      },
    );
  };

  // -------------------------------------------------------------------------
  // 独立面板动作注册（横屏底部栏按钮触发）
  // Independent panel action registrations (triggered by landscape bottom bar buttons)
  // -------------------------------------------------------------------------

  // 倍速面板
  _registerWheelPanel<double>(
    elementKey: SettingMenuElements.speed,
    optionsResolver: (c) =>
        c.widgetData?.playbackSpeeds ?? SettingConstants.speedOptions,
    currentValueResolver: (c) => c.speedNotifier.value,
    onSelected: (c, value) => c.setSpeed(speed: value),
    displayFormatter: (speed) => FormatUtil.formatSpeed(speed),
  );

  // 清晰度面板
  _registerWheelPanel<String>(
    elementKey: SettingMenuElements.trackInfo,
    optionsResolver: (c) {
      final trackInfoList = c.trackInfoListNotifier.value;
      if (trackInfoList == null || trackInfoList.isEmpty) {
        return [TrackInfoUtil.autoQualityKey];
      }
      final qualities = TrackInfoUtil.getQualitiesFromTrackInfos(trackInfoList);
      return qualities.length == 1 ? [TrackInfoUtil.autoQualityKey] : qualities;
    },
    currentValueResolver: (c) {
      final current = c.currentTrackInfoNotifier.value;
      return TrackInfoUtil.getQuality(current);
    },
    onSelected: (c, value) {
      if (value != TrackInfoUtil.autoQualityKey) {
        final trackInfoList = c.trackInfoListNotifier.value;
        if (trackInfoList != null) {
          final selectedTrack = trackInfoList.firstWhere(
            (t) => TrackInfoUtil.getQuality(t) == value,
            orElse: () => trackInfoList.first,
          );
          c.selectTrack(selectedTrack);
        }
      }
    },
    displayFormatter: _formatQualityLabel,
  );
}

// ---------------------------------------------------------------------------
// 滚轮面板声明式注册辅助
// Wheel panel declarative registration helper
// ---------------------------------------------------------------------------

/// 声明式注册滚轮选择面板（数据/显示分离）
///
/// Declaratively registers a wheel selection panel with data/display separation.
///
/// [optionsResolver] — 从 controller 获取选项列表（数据）
/// [currentValueResolver] — 从 controller 获取当前值（数据）
/// [onSelected] — 用户选择后的写回（数据）
/// [displayFormatter] — 选项显示格式化（显示，可选）
void _registerWheelPanel<T>({
  required String elementKey,
  required List<T> Function(AliPlayerWidgetController) optionsResolver,
  required T Function(AliPlayerWidgetController) currentValueResolver,
  required void Function(AliPlayerWidgetController, T) onSelected,
  String Function(T)? displayFormatter,
}) {
  SettingItemRegistry._panelActions[elementKey] = (context, controller) {
    final items = optionsResolver(controller);
    final current = currentValueResolver(controller);

    // 防御性处理：空列表时不展示面板，避免 clamp(0, -1) 异常
    if (items.isEmpty) return Future.value();

    final initialIndex = items.indexOf(current).clamp(0, items.length - 1);

    return showRightSlidePanel<T>(
      context: context,
      panel: RightWheelPanel<T>(
        items,
        initialIndex: initialIndex,
        displayFormatter: displayFormatter,
        onSelected: (value) => Navigator.of(context).pop(value),
      ),
    ).then((value) {
      if (value != null) {
        onSelected(controller, value);
      }
    });
  };
}

/// 将清晰度标识转换为本地化显示文案。
///
/// Converts a quality identifier into localized display text.
String _formatQualityLabel(Object? quality) {
  return switch (quality) {
    TrackInfoUtil.autoQualityKey => PlayerI18n.t(PlayerI18nKeys.qualityAuto),
    TrackInfoUtil.unknownQualityKey =>
      PlayerI18n.t(PlayerI18nKeys.qualityUnknown),
    _ => quality?.toString() ?? '',
  };
}

// ---------------------------------------------------------------------------
// 清晰度 notifier 包装工具
// Quality notifier wrapping utility
// ---------------------------------------------------------------------------

/// 包装清晰度 notifier（从 TrackInfo 转换为 String）
///
/// Wraps the quality notifier, converting from TrackInfo to String.
ValueNotifier<String> _wrapQualityNotifier(
  AliPlayerWidgetController controller,
  List<AVPTrackInfo>? trackInfoList,
  List<ChangeNotifier> disposeBag,
) {
  String initial = TrackInfoUtil.autoQualityKey;
  final currentTrack = controller.currentTrackInfoNotifier.value;
  if (currentTrack != null) {
    initial = TrackInfoUtil.getQuality(currentTrack);
  } else if (trackInfoList != null && trackInfoList.isNotEmpty) {
    initial = TrackInfoUtil.getQuality(trackInfoList.first);
  }

  final wrapped = ValueNotifier<String>(initial);

  void listener() {
    final track = controller.currentTrackInfoNotifier.value;
    if (track != null) {
      wrapped.value = TrackInfoUtil.getQuality(track);
    }
  }

  controller.currentTrackInfoNotifier.addListener(listener);

  // 使用 _DisposableNotifier<String> 确保 dispose 时移除监听
  disposeBag.add(
    _DisposableNotifier<String>(
      wrapped: wrapped,
      source: controller.currentTrackInfoNotifier,
      listener: listener,
    ),
  );

  return wrapped;
}
