// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/18
// Brief: 播放器组件场景工具类

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:flutter/foundation.dart';

/// 在指定场景中执行逻辑
///
/// Execute logic in specified scene or scene list
void executeIfScene(
  VoidCallback? action,
  AliPlayerWidgetData? widgetData, [
  dynamic targetScenes, // 支持 SceneType 或 List<SceneType>
]) {
  final scenes = _normalizeScenes(targetScenes);
  if (_shouldExecute(widgetData, scenes, true)) {
    action?.call();
  }
}

/// 在非指定场景中执行逻辑
///
/// Execute logic in non-specified scene or scene list
void executeIfNotScene(
  VoidCallback? action,
  AliPlayerWidgetData? widgetData, [
  dynamic targetScenes, // 支持 SceneType 或 List<SceneType>
]) {
  final scenes = _normalizeScenes(targetScenes);
  if (_shouldExecute(widgetData, scenes, false)) {
    action?.call();
  }
}

/// 判断当前场景是否属于指定场景
///
/// Check if the current scene matches the specified scene or scene list
bool isScene(
  AliPlayerWidgetData? widgetData,
  dynamic targetScenes, // 支持 SceneType 或 List<SceneType>
) {
  final scenes = _normalizeScenes(targetScenes);
  return widgetData != null && scenes.contains(widgetData.sceneType);
}

/// 判断当前场景是否不属于指定场景
///
/// Check if the current scene does not match the specified scene or scene list
bool isNotScene(
  AliPlayerWidgetData? widgetData,
  dynamic targetScenes, // 支持 SceneType 或 List<SceneType>
) {
  final scenes = _normalizeScenes(targetScenes);
  return widgetData == null || !scenes.contains(widgetData.sceneType);
}

// 检查是否需要执行逻辑
bool _shouldExecute(
  AliPlayerWidgetData? widgetData,
  Set<SceneType>? targetScenes,
  bool isMatched,
) {
  // 如果 targetScenes 为空或 null，则默认执行逻辑
  if (targetScenes == null || targetScenes.isEmpty) {
    return true;
  }

  return widgetData != null &&
      targetScenes.contains(widgetData.sceneType) == isMatched;
}

// 将场景参数标准化为集合
Set<SceneType> _normalizeScenes(dynamic targetScenes) {
  if (targetScenes is SceneType) {
    return {targetScenes}; // 单值转为集合
  } else if (targetScenes is List<SceneType>) {
    return targetScenes.toSet(); // 列表转为集合
  } else {
    return {}; // 默认返回空集合
  }
}
