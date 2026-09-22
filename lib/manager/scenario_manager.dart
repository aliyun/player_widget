// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/4/30
// Brief: Scenario manager for playback experience optimization

import 'package:aliplayer_widget/aliplayer_widget_lib.dart';

/// 播放器能力识别管理
///
/// Player capability recognition manager.
///
/// 内部管理类，统一负责能力识别数据生成，用于播放体验优化和问题诊断。
///
/// Internal management class responsible for generating capability recognition
/// data, used for playback experience optimization and issue diagnosis.
class ScenarioManager {
  // 私有构造函数，防止实例化
  ScenarioManager._();

  // ======================== Global ========================

  /// 能力识别数据（播放体验优化，请勿覆盖）
  ///
  /// Capability recognition data for playback experience optimization, please do not override.
  static const String globalExtraData =
      '{"scene":"flutter-widget", "version":"${AliPlayerWidgetGlobalSetting.kWidgetVersion}"}';

  // ======================== Instance ========================

  /// 生成能力识别数据
  ///
  /// Generate capability recognition data.
  ///
  /// 基于当前播放场景和资源类型生成识别信息，用于播放体验优化。
  /// Generates recognition info based on current scene and source type
  /// for playback experience optimization.
  ///
  /// [sceneType] 播放场景类型
  /// [sourceType] 视频资源类型
  static String buildScenarioFlag({
    required SceneType sceneType,
    required SourceType sourceType,
  }) {
    final scene = _sceneTypeValue(sceneType);
    final source = _sourceTypeValue(sourceType);
    return '{"scene":"$scene", "source":"$source"}';
  }

  /// SceneType 值映射（switch 穷举，新增枚举时编译器会强制提示）
  ///
  /// SceneType value mapping (exhaustive switch ensures compile-time safety)
  static String _sceneTypeValue(SceneType sceneType) {
    return switch (sceneType) {
      SceneType.vod => 'vod',
      SceneType.live => 'live',
      SceneType.listPlayer => 'list-player',
      SceneType.restricted => 'restricted',
      SceneType.minimal => 'minimal',
      SceneType.aiVod => 'ai-vod',
    };
  }

  /// SourceType 值映射（switch 穷举，新增枚举时编译器会强制提示）
  ///
  /// SourceType value mapping (exhaustive switch ensures compile-time safety)
  static String _sourceTypeValue(SourceType sourceType) {
    return switch (sourceType) {
      SourceType.url => 'url',
      SourceType.vidSts => 'vid-sts',
      SourceType.vidAuth => 'vid-auth',
    };
  }
}
