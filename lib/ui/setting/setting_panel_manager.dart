// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/05/06
// Brief: 设置面板管理器，基于注册表驱动的通用引擎

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/ui/common/right_slide_panel.dart';
import 'setting_panel_widget.dart';
import 'setting_item.dart';
import 'setting_item_definition.dart';
import 'setting_item_registry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 设置面板管理器（注册表驱动）
///
/// 从 [SettingItemRegistry] 查询设置项定义，动态构建横竖屏设置面板，
/// 自身不包含任何硬编码的业务逻辑。
///
/// Registry-driven settings panel manager.
///
/// Queries [SettingItemRegistry] for setting item definitions and dynamically
/// builds portrait/landscape panels without any hardcoded business logic.
class SettingPanelManager {
  SettingPanelManager._();

  /// 显示设置面板（自动根据 orientation 选择横竖屏样式）
  ///
  /// Shows the settings panel, automatically selecting portrait or landscape
  /// style based on the current orientation.
  static Future<void> showSettingPanel({
    required BuildContext context,
    required AliPlayerWidgetController controller,
    required SceneType sceneType,
    required Map<SlotType, Set<String>>? hiddenSlotElements,
  }) {
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      return _showPortraitPanel(
        context: context,
        controller: controller,
        sceneType: sceneType,
        hiddenSlotElements: hiddenSlotElements,
      );
    } else {
      return _showLandscapePanel(
        context: context,
        controller: controller,
        sceneType: sceneType,
        hiddenSlotElements: hiddenSlotElements,
      );
    }
  }

  /// 按 elementKey 展示独立面板（通过 [SettingItemRegistry] 注册的面板动作）
  ///
  /// Shows an independent panel for the given elementKey via
  /// [SettingItemRegistry]'s registered panel action.
  static Future<void> showItemPanel({
    required BuildContext context,
    required AliPlayerWidgetController controller,
    required String elementKey,
  }) {
    final action = SettingItemRegistry.getPanelAction(elementKey);
    assert(action != null, 'No panel action registered for: $elementKey');
    return action!(context, controller);
  }

  // ---------------------------------------------------------------------------
  // 竖屏设置面板（底部 ModalBottomSheet，注册表驱动分组）
  // Portrait settings panel (bottom sheet, registry-driven grouping)
  // ---------------------------------------------------------------------------

  /// 竖屏设置面板
  ///
  /// Portrait settings panel via bottom modal sheet.
  static Future<void> _showPortraitPanel({
    required BuildContext context,
    required AliPlayerWidgetController controller,
    required SceneType sceneType,
    required Map<SlotType, Set<String>>? hiddenSlotElements,
  }) {
    final hiddenElements = hiddenSlotElements?[SlotType.settingMenu];
    final disposeBag = <ChangeNotifier>[];

    // 从注册表查询按分组归类的设置项定义
    final grouped = SettingItemRegistry.queryGrouped(
      sceneType: sceneType,
      hiddenElements: hiddenElements,
    );

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top margin
                      const SizedBox(
                        height: PlayerStyles.kPortraitSettingPanelTopMargin,
                      ),
                      // 按分组枚举顺序动态构建各 section
                      ...SettingItemGroup.values
                          .where((group) => grouped.containsKey(group))
                          .map(
                            (group) => _buildPortraitSection(
                              grouped[group]!,
                              controller,
                              disposeBag,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      for (final n in disposeBag) {
        n.dispose();
      }
    });
  }

  /// 从定义列表构建竖屏面板的单个分组区块
  ///
  /// 逐项判定可见性：组内每个定义各自解析其可见性监听（若有），
  /// 无可见性工厂的静态项恒显示。任一动态可见性变化时仅重算
  /// 当前可见的设置项集合，避免用单一项的可见性误伤整组
  /// （例如「倍速」与「清晰度」同组时，单轨道下不应隐藏倍速）。
  ///
  /// 所有 [SettingItem] 在构建期一次性预构建，可见性切换只重排已构建项，
  /// 不重复调用 [SettingItemRegistry.build]，避免重复注册监听器造成泄漏。
  ///
  /// Builds a single portrait panel section from a list of definitions.
  /// Visibility is resolved per-item: static items are always shown, while
  /// items with a visibility factory toggle individually, so one item's
  /// visibility never hides sibling items in the same group.
  static Widget _buildPortraitSection(
    List<SettingItemDefinition> definitions,
    AliPlayerWidgetController controller,
    List<ChangeNotifier> disposeBag,
  ) {
    // 逐项预构建：每个定义只构建一次 SettingItem 与其可见性监听
    final entries = definitions
        .map(
          (d) => _SectionEntry(
            item: SettingItemRegistry.build(d, controller, disposeBag),
            visibility: SettingItemRegistry.resolveVisibility(
              d,
              controller,
              disposeBag,
            ),
          ),
        )
        .toList();

    // 收集组内所有动态可见性监听源
    final listenables = entries
        .map((e) => e.visibility)
        .whereType<ValueListenable<bool>>()
        .toList();

    // 组内无动态可见性 → 静态区块，直接构建
    if (listenables.isEmpty) {
      final items = entries.map((e) => e.item).toList();
      if (items.isEmpty) return const SizedBox.shrink();
      return PortraitSettingPanel(settingItems: items);
    }

    // 组内存在动态可见性 → 监听全部可见性源，逐项判定当前可见集合
    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) {
        final items = entries
            .where((e) => e.visibility == null || e.visibility!.value)
            .map((e) => e.item)
            .toList();
        if (items.isEmpty) return const SizedBox.shrink();
        return PortraitSettingPanel(settingItems: items);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 横屏设置面板（右侧滑入，注册表驱动扁平列表）
  // Landscape settings panel (slide-in from right, registry-driven flat list)
  // ---------------------------------------------------------------------------

  /// 横屏设置面板
  ///
  /// Landscape settings panel via right slide-in dialog.
  static Future<void> _showLandscapePanel({
    required BuildContext context,
    required AliPlayerWidgetController controller,
    required SceneType sceneType,
    required Map<SlotType, Set<String>>? hiddenSlotElements,
  }) {
    final hiddenElements = hiddenSlotElements?[SlotType.settingMenu];
    final disposeBag = <ChangeNotifier>[];

    final definitions = SettingItemRegistry.query(
      sceneType: sceneType,
      hiddenElements: hiddenElements,
      orientation: Orientation.landscape,
    );

    // 横屏面板对动态可见性执行一次性检查
    final visibleDefs = definitions.where((d) {
      final visibility = SettingItemRegistry.resolveVisibility(
        d,
        controller,
        disposeBag,
      );
      if (visibility != null) {
        return visibility.value;
      }
      return true;
    }).toList();

    final items = visibleDefs
        .map((d) => SettingItemRegistry.build(d, controller, disposeBag))
        .toList();

    return showRightSlidePanel<void>(
      width: PlayerStyles.kLandscapeSettingPanelWidth,
      context: context,
      panel: LandScapeSettingPanel(settingItems: items),
    ).whenComplete(() {
      for (final n in disposeBag) {
        n.dispose();
      }
    });
  }
}

/// 竖屏分组内单个设置项的预构建结果。
///
/// 持有已构建的 [SettingItem] 及其可见性监听（无动态可见性时为 null）。
///
/// Pre-built result of a single setting item in a portrait section,
/// holding the built [SettingItem] and its optional visibility listenable.
class _SectionEntry {
  final SettingItem item;
  final ValueListenable<bool>? visibility;

  const _SectionEntry({required this.item, this.visibility});
}
