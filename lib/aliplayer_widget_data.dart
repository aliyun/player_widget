// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/10
// Brief: Player Widget data, used to store the video data required by the player

part of 'aliplayer_widget_lib.dart';

/// 实例级别播放器自定义配置回调
///
/// Instance-level player custom configuration callback.
///
/// 在播放器 prepare() 之前调用，允许用户对播放器实例进行自定义配置，
/// 例如 setPlayConfig（设置缓冲、referer 等）、setOption 等。
/// 支持异步操作（如 getPlayConfig/setPlayConfig），Widget 会等待回调完成后再执行 prepare()。
///
/// 适用于实例级别的播放器配置，与全局级别的 [OnGlobalInitCallback] 互补：
/// - 实例配置 → 使用 [OnPlayerConfigCallback]，通过 [AliPlayerWidgetData.onPlayerConfig] 注入
/// - 全局配置 → 使用 [OnGlobalInitCallback]，通过 [AliPlayerWidgetGlobalSetting.setOnGlobalInit] 注册
///
/// Called before player prepare(), allowing users to customize the player instance,
/// such as setPlayConfig (buffer, referer, etc.), setOption, etc.
/// Supports async operations (e.g., getPlayConfig/setPlayConfig). The Widget will await
/// the callback completion before calling prepare().
///
/// This callback is designed for instance-level player configuration and complements
/// the global-level [OnGlobalInitCallback]:
/// - Instance config → Use [OnPlayerConfigCallback] via [AliPlayerWidgetData.onPlayerConfig]
/// - Global config → Use [OnGlobalInitCallback] via [AliPlayerWidgetGlobalSetting.setOnGlobalInit]
typedef OnPlayerConfigCallback = FutureOr<void> Function(
  FlutterAliplayer player,
);

/// 播放器组件数据，用于存储播放器所需的视频数据
///
/// Player Widget data, used to store the video data required by the player
class AliPlayerWidgetData {
  /// 播放场景类型，默认为点播 [SceneType.vod]
  ///
  /// Playback scene type, default is vod [SceneType.vod]
  final SceneType sceneType;

  /// 视频资源对象，用于定义播放源（必填，不可变）
  ///
  /// Video source object, used to define the playback source (required, immutable)
  final VideoSource videoSource;

  /// Android 播放器视图类型，默认为 [AndroidViewType.defaultValue]
  ///
  /// Android player view type, defaults to [AndroidViewType.defaultValue]
  ///
  /// 仅对 Android 平台生效，iOS 平台会忽略此配置。
  /// Only takes effect on Android; iOS ignores this configuration.
  final AndroidViewType androidViewType;

  /// 封面图地址，可以为空
  ///
  /// Cover URL, can be empty
  final String coverUrl;

  /// 视频标题，可以为空
  ///
  /// Video title, can be empty
  final String videoTitle;

  /// 缩略图地址，可以为空
  ///
  /// Thumbnail URL, can be empty
  final String thumbnailUrl;

  /// 外挂字幕地址，可以为空
  ///
  /// ExternalSubtitle URL, can be empty
  final String externalSubtitleUrl;

  /// 是否自动播放，默认为 false
  ///
  /// Whether to play automatically, default is false
  final bool autoPlay;

  /// 用于跟踪视频播放的 ID，可以为空
  ///
  /// Trace ID for tracking video playback, can be empty
  final String traceId;

  /// 视频开始时间，单位毫秒，必须为非负数
  ///
  /// Video start time in milliseconds, must be non-negative
  final int startTime;

  /// 视频 seek 模式，默认为精确模式 [FlutterAvpdef.ACCURATE]
  ///
  /// Video seek mode, default is accurate mode [FlutterAvpdef.ACCURATE]
  final int seekMode;

  /// 视频解码，默认为true
  ///
  /// Setting video decoding which is enable by default.
  final bool isHardWareDecode;

  /// 是否允许屏幕休眠，默认为 false（即默认保持屏幕常亮）
  ///
  /// Whether to allow the screen to sleep during playback.
  /// When set to `false` (default), the screen stays awake while playing.
  /// When set to `true`, the system is allowed to turn off the screen normally.
  final bool allowedScreenSleep;

  /// 应用进入后台时是否自动暂停播放。
  ///
  /// Whether to automatically pause playback when the app goes to
  /// the background.
  ///
  /// 设置为 `true` 时，应用进入后台后视频将自动暂停，返回前台后自动恢复播放。
  /// 设置为 `false` 时，应用进入后台后不会自动暂停。
  ///
  /// When set to `true`, the video will be automatically paused when
  /// the app enters the background, and automatically resumed when
  /// the app returns to the foreground.
  /// When set to `false`, playback will not be automatically paused
  /// when entering the background.
  ///
  /// 默认值为 `true`。
  ///
  /// Defaults to `true`.
  final bool pauseOnBackground;

  /// 字幕配置
  ///
  /// Subtitle configuration
  SubtitleConfig subtitleConfig;

  /// 外挂字幕构建器
  ///
  /// External subtitle builder
  SubtitleBuilder? subtitleBuilder;

  /// 播放器自定义配置回调
  ///
  /// Player custom configuration callback.
  ///
  /// 在播放器 prepare() 之前调用，允许用户对播放器实例进行自定义配置，
  /// 例如通过 setPlayConfig 设置缓冲策略、refer 等。
  /// 支持异步操作（如 getPlayConfig/setPlayConfig），Widget 会等待回调完成后再执行 prepare()。
  ///
  /// 对于未通过 [AliPlayerWidgetController] 直接透出的播放器接口
  /// （如 setPlayConfig、setOption、setFilterConfig 等），建议在此回调中自行调用实现。
  ///
  /// Called before player prepare(), allowing users to customize the player instance,
  /// such as setting buffer strategy, referer via setPlayConfig, etc.
  /// Supports async operations (e.g., getPlayConfig/setPlayConfig). The Widget will await
  /// the callback completion before calling prepare().
  ///
  /// For player APIs not directly exposed by [AliPlayerWidgetController]
  /// (e.g., setPlayConfig, setOption, setFilterConfig, etc.), it is recommended
  /// to call them within this callback.
  ///
  /// 使用示例 / Usage example:
  /// ```dart
  /// AliPlayerWidgetData(
  ///   videoSource: ...,
  ///   onPlayerConfig: (player) async {
  ///     // 设置缓冲策略和 Referer
  ///     var config = await player.getPlayConfig();
  ///     config.maxBufferDuration = 2000;
  ///     config.referer = "your referer";
  ///     await player.setPlayConfig(config);
  ///
  ///     // 设置其他选项
  ///     player.setOption(FlutterAvpdef.ALLOW_PRE_RENDER, 1);
  ///   },
  /// );
  /// ```
  final OnPlayerConfigCallback? onPlayerConfig;

  /// 自定义可选的播放速度列表。
  ///
  /// Custom playback speed options.
  ///
  /// 建议速度范围控制在 0.3 到 3.0 之间，但不强制限制。
  /// 所有值必须大于 0，否则会触发断言错误。
  ///
  /// 建议列表中包含 1.0（正常速度），以确保设置面板中的
  /// 选中状态与默认播放速度一致。
  ///
  /// Recommended speed range is 0.3 to 3.0, but not strictly enforced.
  /// All values must be greater than 0, otherwise an assertion error will be triggered.
  ///
  /// It is recommended to include 1.0 (normal speed) in the list to ensure
  /// the selected state in the settings panel matches the default playback speed.
  ///
  /// 默认值为 [SettingConstants.speedOptions]。
  ///
  /// Defaults to [SettingConstants.speedOptions].
  final List<double> playbackSpeeds;

  /// 播放控件自动隐藏的持续时间。
  ///
  /// Duration before the playback controls are automatically hidden.
  ///
  /// 值必须大于零，否则控件将瞬间隐藏导致无法交互。
  ///
  /// The value must be greater than zero, otherwise the controls will
  /// hide instantly and become non-interactive.
  ///
  /// 默认值为 [SettingConstants.defaultAutoHideControlsDuration]。
  ///
  /// Defaults to [SettingConstants.defaultAutoHideControlsDuration].
  final Duration autoHideControlsDuration;

  /// 章节信息列表（可选）
  ///
  /// 当传入章节数据时使用。
  /// 提供后，BottomBarSlot 会自动在进度条上绘制章节标记点，
  /// 并在用户 Seek 时显示当前章节信息。
  /// 默认为空列表，表示无章节数据。
  ///
  /// Chapter info list.
  ///
  /// Used when chapter data is provided.
  /// When provided, BottomBarSlot will automatically draw chapter markers on the progress bar
  /// and display chapter info during seek.
  /// Defaults to an empty list, indicating no chapter data.
  final List<ChapterInfo> chapters;

  /// 构造函数，用于创建 [AliPlayerWidgetData] 实例。
  ///
  /// Constructor to create an instance of [AliPlayerWidgetData].
  ///
  /// 参数：
  /// - [sceneType]：视频场景类型，默认为点播（VOD）。
  /// - [videoSource]: 视频资源对象，定义播放源（必填）。
  /// - [androidViewType]：Android 播放器视图类型，默认为 [AndroidViewType.defaultValue]。
  /// - [coverUrl]：视频封面图片地址，默认为空字符串。
  /// - [videoTitle]：视频标题，默认为空字符串。
  /// - [thumbnailUrl]：视频缩略图地址，默认为空字符串。
  /// - [autoPlay]：是否自动播放，默认为 true。
  /// - [traceId]：用于跟踪视频播放的 ID，默认为空字符串。
  /// - [startTime]：视频起始播放时间（秒），必须为非负数，默认为 0。
  /// - [seekMode]：视频跳转模式，默认为精确跳转。
  /// - [allowedScreenSleep]：是否允许屏幕休眠，默认为 false（保持屏幕常亮）。
  /// - [pauseOnBackground]：是否在进入后台时自动暂停播放，默认为 true（进入后台自动暂停）。
  /// - [isHardWareDecode]：是否开启硬解码，默认为true。
  /// - [subtitleConfig]：字幕配置，默认为默认配置。
  /// - [subtitleBuilder]：字幕构建器，可以为空。
  /// - [onPlayerConfig]：播放器自定义配置回调，在 prepare() 前调用，可以为空。
  /// - [playbackSpeeds]：自定义可选播放速度列表，默认为 [SettingConstants.speedOptions]。
  /// - [autoHideControlsDuration]：播放控件自动隐藏时间，默认为 [SettingConstants.defaultAutoHideControlsDuration]。
  /// - [chapters]：章节信息列表，默认为空列表。
  ///
  /// Parameters:
  /// - [sceneType]: The type of video scene, defaulting to Video On Demand (VOD).
  /// - [videoSource]: Video source object defining the playback source (required).
  /// - [androidViewType]: Android player view type, defaults to [AndroidViewType.defaultValue].
  /// - [coverUrl]: The URL of the cover image for the video, defaulting to an empty string.
  /// - [videoTitle]: The title of the video, defaulting to an empty string.
  /// - [thumbnailUrl]: The URL of the thumbnail image for the video, defaulting to an empty string.
  /// - [externalSubtitleUrl]: The URL of the external subtitle for the video, defaulting to an empty string.
  /// - [autoPlay]: Whether to autoplay the video, defaulting to true.
  /// - [traceId]: The ID used to track video playback, defaulting to an empty string.
  /// - [startTime]: The start time of video playback in seconds, must be non-negative, defaulting to 0.
  /// - [seekMode]: The seek mode for video playback, defaulting to accurate seeking.
  /// - [allowedScreenSleep]: Whether to allow screen sleep, default is false (keeps screen awake).
  /// - [pauseOnBackground]: Whether to auto-pause on background, default is true (auto-pause on background).
  /// - [isHardWareDecode]: Whether to enable hardwareDecoder , default is true.
  /// - [subtitleConfig]: Subtitle configuration, default is default configuration.
  /// - [subtitleBuilder]: Subtitle builder, can be null.
  /// - [onPlayerConfig]: Player custom configuration callback, called before prepare(), can be null.
  /// - [playbackSpeeds]: Custom playback speed options, defaults to [SettingConstants.speedOptions].
  /// - [autoHideControlsDuration]: Duration before controls auto-hide, defaults to [SettingConstants.defaultAutoHideControlsDuration].
  /// - [chapters]: Chapter info list, defaults to an empty list.
  AliPlayerWidgetData({
    this.sceneType = SceneType.vod,
    required this.videoSource,
    this.androidViewType = AndroidViewType.defaultValue,
    this.coverUrl = "",
    this.videoTitle = "",
    this.thumbnailUrl = "",
    this.externalSubtitleUrl = "",
    this.autoPlay = true,
    this.traceId = "",
    this.startTime = 0,
    this.seekMode = FlutterAvpdef.ACCURATE,
    this.allowedScreenSleep = false,
    this.pauseOnBackground = true,
    this.isHardWareDecode = true,
    this.subtitleConfig = const SubtitleConfig(),
    this.subtitleBuilder,
    this.onPlayerConfig,
    this.playbackSpeeds = SettingConstants.speedOptions,
    this.autoHideControlsDuration =
        SettingConstants.defaultAutoHideControlsDuration,
    this.chapters = const [],
  })  : assert(startTime >= 0, "Start time must be non-negative"),
        assert(
          playbackSpeeds.isNotEmpty,
          'playbackSpeeds must contain at least one value',
        ),
        assert(
          playbackSpeeds.every((s) => s > 0),
          'All playback speeds must be greater than 0',
        ),
        assert(
          autoHideControlsDuration > Duration.zero,
          'autoHideControlsDuration must be positive',
        );

  /// 将 [AliPlayerWidgetData] 实例转换为字符串。
  ///
  /// Convert [AliPlayerWidgetData] instance to string.
  @override
  String toString() {
    return 'AliPlayerWidgetData{sceneType: $sceneType, videoSource: $videoSource, androidViewType: $androidViewType, coverUrl: $coverUrl, videoTitle: $videoTitle, thumbnailUrl: $thumbnailUrl, externalSubtitleUrl: $externalSubtitleUrl, autoPlay: $autoPlay, traceId: $traceId, startTime: $startTime, seekMode: $seekMode, isHardWareDecode: $isHardWareDecode, allowedScreenSleep: $allowedScreenSleep, pauseOnBackground: $pauseOnBackground, subtitleConfig: $subtitleConfig, subtitleBuilder: $subtitleBuilder, onPlayerConfig: $onPlayerConfig, playbackSpeeds: $playbackSpeeds, autoHideControlsDuration: $autoHideControlsDuration, chapters: $chapters}';
  }
}
