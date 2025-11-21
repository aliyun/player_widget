// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/11/14
// Brief: Slot configuration

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

/// 插槽显示配置
///
/// Slot configuration
class SlotConfig {
  /// 排除的场景类型（在这些场景下不显示）
  final Set<SceneType> excludedScenes;

  /// 额外的显示条件
  final bool Function()? additionalCondition;

  const SlotConfig({
    this.excludedScenes = const {},
    this.additionalCondition,
  });
}
