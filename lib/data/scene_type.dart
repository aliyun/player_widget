// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/10
// Brief: 播放场景类型

/// 播放场景类型
///
/// Playback scene type
enum SceneType {
  /// 点播场景
  ///
  /// 适用场景：常规视频播放
  /// 功能特性：支持所有播放控制功能，包括播放/暂停、进度拖拽、快进/快退、
  ///         倍速播放、音量/亮度调节、全屏切换、设置菜单等
  ///
  /// VOD Scene
  ///
  /// Use case: Regular video playback
  /// Features: Supports all playback controls including play/pause, seek,
  ///          fast forward/rewind, speed control, volume/brightness adjustment,
  ///          fullscreen toggle, settings menu, etc.
  vod,

  /// 直播场景
  ///
  /// 适用场景：实时直播流播放
  /// 功能特性：支持播放/暂停、刷新、音量/亮度调节、全屏切换、设置菜单等，
  ///         但不支持进度拖拽、快进/快退、倍速播放等时间轴相关操作
  ///
  /// Live Scene
  ///
  /// Use case: Real-time live stream playback
  /// Features: Supports play/pause, refresh, volume/brightness adjustment, fullscreen toggle,
  ///          settings menu, but excludes timeline-related operations like seek,
  ///          fast forward/rewind, speed control
  live,

  /// 列表播放场景
  ///
  /// 适用场景：视频列表中的播放器，如信息流、短视频列表等
  /// 功能特性：支持基本播放控制，但禁用垂直手势（音量/亮度调节），
  ///         避免与列表滚动手势冲突
  ///
  /// List Player Scene
  ///
  /// Use case: Player in video lists, such as feeds or short video lists
  /// Features: Supports basic playback controls but disables vertical gestures
  ///          (volume/brightness adjustment) to avoid conflicts with list scrolling
  listPlayer,

  /// 受限播放场景（限制时间轴操作）
  ///
  /// 适用场景：教育培训、考试监控、演示展示等需要限制用户跳跃播放的场景
  /// 功能特性：支持播放/暂停、音量/亮度调节、全屏切换、设置菜单、字幕显示等，
  ///         但禁用进度拖拽、快进/快退、倍速播放等时间轴相关操作，
  ///         确保用户只能按正常速度顺序观看，无法跳过内容
  ///
  /// Restricted Scene (Timeline operations restricted)
  ///
  /// Use case: Educational training, exam monitoring, demonstrations where
  ///          timeline manipulation needs to be restricted
  /// Features: Supports play/pause, volume/brightness adjustment, fullscreen toggle,
  ///          settings menu, subtitle display, but disables timeline-related operations
  ///          like seek, fast forward/rewind, speed control, ensuring users can only
  ///          watch content at normal speed in sequence without skipping
  restricted,

  /// 最小化播放场景（仅播放视图，无任何UI）
  ///
  /// 适用场景：背景视频、装饰性视频、嵌入式播放器、自定义UI覆盖等
  /// 功能特性：仅显示纯净的视频播放画面，不显示任何UI元素，
  ///         包括封面图、字幕、播放状态、控制界面等，
  ///         适合需要完全自定义UI或作为背景元素的场景
  ///
  /// Minimal Scene (Only surface view, no UI)
  ///
  /// Use case: Background videos, decorative videos, embedded players,
  ///          custom UI overlays
  /// Features: Only displays pure video playback surface without any UI elements
  ///          including cover image, subtitles, play state, control interfaces,
  ///          suitable for scenarios requiring completely custom UI or
  ///          background elements
  minimal,

  /// AI 增强点播场景
  ///
  /// 适用于教育课程、知识视频、内容分析与内容理解等需要 AI 能力增强的点播场景。
  ///
  /// 功能特性：继承 VOD 场景的基础播放能力，包括 Seek、倍速播放和手势操作等；
  ///         同时支持进度条按章节拆分、章节导航、Seek 过程中的章节信息展示，
  ///         以及章节解析、图文解析等 AI 内容解析能力。
  ///
  /// 前提条件：章节相关功能需通过 [AliPlayerWidgetData.chapters] 提供章节数据。
  ///
  /// AI-Enhanced VOD Scene
  ///
  /// Designed for AI-enhanced video-on-demand scenarios such as educational courses,
  /// knowledge-based videos, content analysis, and content understanding.
  ///
  /// Features: Inherits the standard playback capabilities of the VOD scene,
  ///          including seeking, playback speed control, and gesture controls.
  ///          It also supports chapter-based progress bar segmentation,
  ///          chapter navigation, chapter information display while seeking,
  ///          and AI-powered content analysis such as chapter analysis
  ///          and illustrated content analysis.
  ///
  /// Prerequisite: Chapter-related features require chapter data to be provided
  ///              through [AliPlayerWidgetData.chapters].
  aiVod,
}
