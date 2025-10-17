// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/18
// Brief: 播放器组件场景工具类

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';
import 'package:flutter/foundation.dart';

/// 直接通过 SceneType 判断是否属于指定场景
///
/// Check if the scene type matches the specified scene or scene list
bool isSceneType(
  SceneType? currentScene,
  dynamic targetScenes, // 支持 SceneType 或 List<SceneType>
) {
  final scenes = _normalizeScenes(targetScenes);
  return currentScene != null && scenes.contains(currentScene);
}

/// 直接通过 SceneType 判断是否不属于指定场景
///
/// Check if the scene type does not match the specified scene or scene list
bool isNotSceneType(
  SceneType? currentScene,
  dynamic targetScenes, // 支持 SceneType 或 List<SceneType>
) {
  final scenes = _normalizeScenes(targetScenes);
  return currentScene == null || !scenes.contains(currentScene);
}

/// 直接通过 SceneType 在指定场景中执行逻辑
///
/// Execute logic in specified scene using SceneType directly
void executeIfSceneType(
  VoidCallback? action,
  SceneType? currentScene, [
  dynamic targetScenes, // 支持 SceneType 或 List<SceneType>
]) {
  if (isSceneType(currentScene, targetScenes)) {
    action?.call();
  }
}

/// 直接通过 SceneType 在非指定场景中执行逻辑
///
/// Execute logic in non-specified scene using SceneType directly
void executeIfNotSceneType(
  VoidCallback? action,
  SceneType? currentScene, [
  dynamic targetScenes, // 支持 SceneType 或 List<SceneType>
]) {
  if (isNotSceneType(currentScene, targetScenes)) {
    action?.call();
  }
}

/// 判断多个场景是否有任意一个匹配
///
/// Check if any of the current scenes matches any of the target scenes
bool isAnyScene(
  List<SceneType>? currentScenes,
  dynamic targetScenes,
) {
  if (currentScenes == null || currentScenes.isEmpty) return false;

  final scenes = _normalizeScenes(targetScenes);
  return currentScenes.any((scene) => scenes.contains(scene));
}

/// 判断多个场景是否全部匹配
///
/// Check if all current scenes match the target scenes
bool isAllScenes(
  List<SceneType>? currentScenes,
  dynamic targetScenes,
) {
  if (currentScenes == null || currentScenes.isEmpty) return false;

  final scenes = _normalizeScenes(targetScenes);
  return currentScenes.every((scene) => scenes.contains(scene));
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
