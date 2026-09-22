// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2026/5/8
// Brief: Barrel file for the strategy module.

/// 策略系统
///
/// 提供播放器策略的接口定义、生命周期管理和内置策略实现，
/// 支持首帧耗时统计、卡顿检测等可观测能力，并可自定义扩展。
///
/// Strategy system
///
/// Provides strategy interface definitions, lifecycle management, and built-in
/// strategy implementations for observability capabilities such as first frame
/// timing and stutter detection, with support for custom extensions.
library;

export 'strategy_base.dart';
export 'strategy_manager.dart';
export 'strategies/first_frame_strategy.dart';
export 'strategies/stutter_detect_strategy.dart';
