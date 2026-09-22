// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: junHuiYe
// Date: 2026/05/06
// Brief: 设置项注册表，统一管理设置项元数据定义与运行时绑定逻辑

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:aliplayer_widget/constants/setting_constants.dart';
import 'package:aliplayer_widget/ui/common/right_slide_panel.dart';
import 'package:aliplayer_widget/ui/common/right_wheel_panel.dart';
import 'package:aliplayer_widget/utils/format_util.dart';
import 'package:aliplayer_widget/utils/track_info_util.dart';
import 'setting_item.dart';
import 'setting_item_definition.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'setting_item_defaults.dart';

/// 设置项构建工厂函数签名
///
/// Factory function signature for building a [SettingItem] at runtime.
typedef SettingItemBuildFn = SettingItem Function(
  AliPlayerWidgetController controller,
  List<ChangeNotifier> disposeBag,
);

/// 设置项动态可见性工厂函数签名
///
/// Factory function signature for creating a visibility [ValueListenable].
///
/// [disposeBag] 用于托管工厂内部创建的 notifier，面板关闭时统一释放。
typedef SettingVisibilityFn = ValueListenable<bool> Function(
  AliPlayerWidgetController controller,
  List<ChangeNotifier> disposeBag,
);

/// 独立面板动作工厂函数签名
///
/// Factory function signature for showing an independent panel
/// for a specific setting item.
typedef PanelActionFn = Future<void> Function(
  BuildContext context,
  AliPlayerWidgetController controller,
);

/// 设置项注册表，统一管理设置项元数据定义与运行时绑定逻辑
///
/// 单一入口管理元数据（[SettingItemDefinition]）、运行时构建工厂、
/// 可见性工厂和独立面板动作，提供按场景/方向/隐藏元素过滤查询的能力。
///
/// Unified setting item registry that manages metadata definitions,
/// runtime build factories, visibility factories, and panel actions.
///
/// Provides lazy-initialized default registrations, custom extension
/// registration, and query capabilities filtered by scene, orientation,
/// and hidden elements.
class SettingItemRegistry {
  SettingItemRegistry._();

  // ---------------------------------------------------------------------------
  // 数据存储
  // Data storage
  // ---------------------------------------------------------------------------

  /// 内部存储：设置项定义、构建工厂、可见性工厂和面板动作
  static final List<SettingItemDefinition> _definitions = [];

  /// 内部存储：设置项构建工厂
  static final Map<String, SettingItemBuildFn> _factories = {};

  /// 内部存储：设置项可见性工厂
  static final Map<String, SettingVisibilityFn> _visibilityFactories = {};

  /// 内部存储：设置项面板动作
  static final Map<String, PanelActionFn> _panelActions = {};

  /// 内部存储：初始化标志
  static bool _initialized = false;

  /// 确保默认设置项已注册（懒初始化）
  ///
  /// Ensures default setting items are registered (lazy initialization).
  static void _ensureInitialized() {
    if (_initialized) return;
    _registerBuiltInDefaults();
    _initialized = true;
  }

  // ---------------------------------------------------------------------------
  // 运行时 API（构建 / 可见性 / 面板动作）
  // Runtime API (build / visibility / panel action)
  // ---------------------------------------------------------------------------

  /// 根据定义构建运行时 [SettingItem]
  ///
  /// 查找 [def.elementKey] 对应的工厂函数并调用，返回构建好的 [SettingItem]。
  ///
  /// Builds a runtime [SettingItem] from the given definition.
  ///
  /// Looks up the factory by [def.elementKey], asserts it exists, and invokes it.
  static SettingItem build(
    SettingItemDefinition def,
    AliPlayerWidgetController controller,
    List<ChangeNotifier> disposeBag,
  ) {
    _ensureInitialized();
    final factory = _factories[def.elementKey];
    assert(
      factory != null,
      'No factory registered for elementKey: ${def.elementKey}',
    );
    return factory!(controller, disposeBag);
  }

  /// 解析定义的动态可见性条件
  ///
  /// 查找 [def.elementKey] 对应的可见性工厂，若存在则调用并返回
  /// [ValueListenable<bool>]；若无注册则返回 null。
  ///
  /// Resolves the dynamic visibility for the given definition.
  ///
  /// Looks up the visibility factory by [def.elementKey]; returns the
  /// [ValueListenable<bool>] if found, or null if none is registered.
  static ValueListenable<bool>? resolveVisibility(
    SettingItemDefinition def,
    AliPlayerWidgetController controller,
    List<ChangeNotifier> disposeBag,
  ) {
    _ensureInitialized();
    final factory = _visibilityFactories[def.elementKey];
    if (factory == null) return null;
    return factory(controller, disposeBag);
  }

  /// 检查指定 elementKey 是否注册了动态可见性工厂
  ///
  /// Checks whether a visibility factory is registered for the given elementKey.
  static bool hasVisibility(String elementKey) {
    _ensureInitialized();
    return _visibilityFactories.containsKey(elementKey);
  }

  /// 获取指定 elementKey 的独立面板动作
  ///
  /// Returns the panel action for the given elementKey, or null if none is registered.
  static PanelActionFn? getPanelAction(String elementKey) {
    _ensureInitialized();
    return _panelActions[elementKey];
  }

  // ---------------------------------------------------------------------------
  // 查询 API
  // Query API
  // ---------------------------------------------------------------------------

  /// 按条件查询设置项定义列表
  ///
  /// 根据场景类型、隐藏元素集合和屏幕方向过滤并排序设置项定义。
  ///
  /// Queries setting item definitions filtered by scene type, hidden elements,
  /// and screen orientation, sorted by group index (insertion order preserved
  /// within the same group since Dart's List.sort is stable).
  static List<SettingItemDefinition> query({
    required SceneType sceneType,
    Set<String>? hiddenElements,
    Orientation? orientation,
  }) {
    _ensureInitialized();

    final results = _definitions.where((def) {
      // 1. SceneType 过滤
      if (def.excludedScenes.contains(sceneType)) {
        return false;
      }

      // 2. hiddenElements 过滤
      if (hiddenElements != null &&
          hiddenElements.isNotEmpty &&
          !hiddenElements.isElementVisible(def.elementKey)) {
        return false;
      }

      // 3. Orientation 过滤
      if (orientation == Orientation.portrait && !def.showInPortraitPanel) {
        return false;
      }
      if (orientation == Orientation.landscape && !def.showInLandscapePanel) {
        return false;
      }

      return true;
    }).toList();

    // 按 group 枚举顺序排序，同组内保持注册插入顺序（Dart List.sort 是稳定排序）
    results.sort((a, b) => a.group.index.compareTo(b.group.index));

    return results;
  }

  /// 按分组查询竖屏设置面板的设置项定义
  ///
  /// 返回以 [SettingItemGroup] 为 key 的分组映射，
  /// 仅包含竖屏可见的设置项，按组枚举顺序排列。
  ///
  /// Queries portrait panel definitions grouped by [SettingItemGroup].
  ///
  /// Returns a map keyed by group with only portrait-visible definitions,
  /// ordered by group enum index.
  static Map<SettingItemGroup, List<SettingItemDefinition>> queryGrouped({
    required SceneType sceneType,
    Set<String>? hiddenElements,
  }) {
    final items = query(
      sceneType: sceneType,
      hiddenElements: hiddenElements,
      orientation: Orientation.portrait,
    );

    final grouped = <SettingItemGroup, List<SettingItemDefinition>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.group, () => []).add(item);
    }

    return grouped;
  }

  // ---------------------------------------------------------------------------
  // 测试 API
  // Testing API
  // ---------------------------------------------------------------------------

  /// 重置所有注册（仅用于测试）
  ///
  /// Resets all registrations (testing only).
  @visibleForTesting
  static void resetForTesting() {
    _definitions.clear();
    _factories.clear();
    _visibilityFactories.clear();
    _panelActions.clear();
    _initialized = false;
  }

  // ---------------------------------------------------------------------------
  // 工具方法
  // Utility methods
  // ---------------------------------------------------------------------------

  /// 将源 [ValueListenable<T>] 包装为独立的 [ValueNotifier<T>]，
  /// 并注册同步监听器，同时将包装后的 notifier 加入 [disposeBag]
  ///
  /// 包装后的 notifier 拥有独立的生命周期，面板关闭时通过 disposeBag 统一释放。
  ///
  /// Wraps a source [ValueListenable<T>] into a standalone [ValueNotifier<T>],
  /// registering a sync listener, and adds it to [disposeBag].
  ///
  /// The wrapped notifier has its own lifecycle and is disposed via disposeBag.
  static ValueNotifier<T> wrapNotifier<T>(
    ValueListenable<T> source,
    List<ChangeNotifier> disposeBag,
  ) {
    final wrapped = ValueNotifier<T>(source.value);

    void listener() {
      wrapped.value = source.value;
    }

    source.addListener(listener);

    // 将 wrapped notifier 加入 disposeBag，
    // 同时在 dispose 时移除对 source 的监听
    disposeBag.add(
      _DisposableNotifier<T>(
        wrapped: wrapped,
        source: source,
        listener: listener,
      ),
    );

    return wrapped;
  }
}

// ---------------------------------------------------------------------------
// 私有 Disposable Notifier 类
// Private disposable notifier classes
// ---------------------------------------------------------------------------

/// 可释放的包装 Notifier，在 dispose 时自动移除源监听器并释放包装的 notifier
///
/// Disposable wrapper that removes the source listener and disposes
/// the wrapped notifier on disposal.
class _DisposableNotifier<T> extends ChangeNotifier {
  final ValueNotifier<T> wrapped;
  final Listenable source;
  final void Function() listener;

  _DisposableNotifier({
    required this.wrapped,
    required this.source,
    required this.listener,
  });

  @override
  void dispose() {
    source.removeListener(listener);
    wrapped.dispose();
    super.dispose();
  }
}
