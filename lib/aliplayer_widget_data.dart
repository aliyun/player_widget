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
}

/// 视频资源类型
///
/// 定义了播放视频时支持的不同资源类型。
///
/// Playback source type
///
/// Defines the different types of playback sources supported for video playback.
enum SourceType {
  /// 表示通过 URL 播放视频资源。
  ///
  /// The video resource is played via a direct URL.
  url,

  /// 表示通过 VID（视频唯一标识符）和 STS（安全令牌服务）播放视频资源。
  ///
  /// The video resource is played using a Video ID (VID) and Security Token Service (STS).
  vidSts,

  /// 表示通过 VID 和 Auth（授权认证）播放视频资源。
  ///
  /// The video resource is played using a Video ID (VID) and Authorization (Auth).
  vidAuth,
}

/// 视频播放源基类
///
/// 定义了所有播放源类型的共同接口，支持不同类型的视频资源播放。
///
/// Video Playback Source Base Class
///
/// Defines the common interface for all playback source types, supporting different types of video resources.
abstract class VideoSource {
  /// 获取视频源类型
  ///
  /// Get the source type of the video
  SourceType get sourceType;

  /// 获取媒体唯一标识
  ///
  /// 用于在播放器池中标识和复用播放器实例，相同 mediaId 的视频源会复用同一播放器实例。
  /// 规则：“类型前缀:关键标识”，例如 "url:https://..." 或 "vidsts:abc123"。
  ///
  /// Unique media identifier for player pool reuse.
  /// Format: "type_prefix:key_identifier", e.g. "url:https://..." or "vidsts:abc123".
  String get mediaId;

  /// 转换为可用于播放器的配置映射
  ///
  /// Convert to a configuration map that can be used by the player
  Map<String, dynamic> toJson();

  /// 验证当前资源配置是否有效
  ///
  /// Validate if the current resource configuration is valid
  bool validate();
}

/// URL 类型的视频源
///
/// 通过直接URL播放视频的资源类型。
///
/// URL-based Video Source
///
/// Resource type for playing videos via direct URL.
class UrlVideoSource extends VideoSource {
  /// 视频URL地址
  ///
  /// Video URL address
  final String url;

  /// 构造函数
  ///
  /// Constructor
  UrlVideoSource({required this.url});

  @override
  SourceType get sourceType => SourceType.url;

  @override
  String get mediaId => 'url:$url';

  @override
  Map<String, dynamic> toJson() {
    return {
      'sourceType': sourceType.toString(),
      'url': url,
    };
  }

  @override
  bool validate() {
    return url.isNotEmpty;
  }

  @override
  String toString() =>
      'UrlVideoSource{url: ${PrivacyUtil.removeAuthKeyFromUrl(url)}}';
}

/// VidSts 类型的视频源
///
/// 通过VID和STS令牌播放视频的资源类型。
///
/// VidSts-based Video Source
///
/// Resource type for playing videos via VID and STS token.
class VidStsVideoSource extends VideoSource {
  /// 视频唯一标识符
  ///
  /// Video unique identifier
  final String vid;

  /// 访问密钥ID
  ///
  /// Access key ID
  final String accessKeyId;

  /// 访问密钥密文
  ///
  /// Access key secret
  final String accessKeySecret;

  /// 安全令牌
  ///
  /// Security token
  final String securityToken;

  /// 区域信息
  ///
  /// Region information
  final String region;

  /// 构造函数
  ///
  /// Constructor
  VidStsVideoSource({
    required this.vid,
    required this.accessKeyId,
    required this.accessKeySecret,
    required this.securityToken,
    required this.region,
  });

  @override
  SourceType get sourceType => SourceType.vidSts;

  @override
  String get mediaId => 'vidsts:$vid';

  @override
  Map<String, dynamic> toJson() {
    return {
      'sourceType': sourceType.toString(),
      'vid': vid,
      'accessKeyId': accessKeyId,
      'accessKeySecret': accessKeySecret,
      'securityToken': securityToken,
      'region': region,
    };
  }

  @override
  bool validate() {
    return vid.isNotEmpty &&
        accessKeyId.isNotEmpty &&
        accessKeySecret.isNotEmpty &&
        securityToken.isNotEmpty;
  }

  @override
  String toString() => 'VidStsVideoSource{vid: $vid, '
      'accessKeyId: ${PrivacyUtil.blur(accessKeyId)}, '
      'accessKeySecret: ${PrivacyUtil.blur(accessKeySecret)}, '
      'securityToken: ${PrivacyUtil.blur(securityToken)}, '
      'region: $region}';
}

/// VidAuth 类型的视频源
///
/// 通过VID和Auth认证播放视频的资源类型。
///
/// VidAuth-based Video Source
///
/// Resource type for playing videos via VID and Auth authentication.
class VidAuthVideoSource extends VideoSource {
  /// 视频唯一标识符
  ///
  /// Video unique identifier
  final String vid;

  /// 播放授权码
  ///
  /// Play authorization code
  final String playAuth;

  /// 构造函数
  ///
  /// Constructor
  VidAuthVideoSource({
    required this.vid,
    required this.playAuth,
  });

  @override
  SourceType get sourceType => SourceType.vidAuth;

  @override
  String get mediaId => 'vidauth:$vid';

  @override
  Map<String, dynamic> toJson() {
    return {
      'sourceType': sourceType.toString(),
      'vid': vid,
      'playAuth': playAuth,
    };
  }

  @override
  bool validate() {
    return vid.isNotEmpty && playAuth.isNotEmpty;
  }

  @override
  String toString() => 'VidAuthVideoSource{vid: $vid, '
      'playAuth: ${PrivacyUtil.blur(playAuth)}}';
}

/// 视频源工厂类
///
/// 用于创建不同类型的视频源实例。
///
/// Video Source Factory
///
/// Used to create instances of different types of video sources.
class VideoSourceFactory {
  // 私有构造函数，防止实例化
  VideoSourceFactory._();

  /// 创建URL类型的视频源
  ///
  /// Create a URL-type video source
  static VideoSource createUrlSource(String url) {
    return UrlVideoSource(url: url);
  }

  /// 创建VidSts类型的视频源
  ///
  /// Create a VidSts-type video source
  static VideoSource createVidStsSource({
    required String vid,
    required String accessKeyId,
    required String accessKeySecret,
    required String securityToken,
    required String region,
  }) {
    return VidStsVideoSource(
      vid: vid,
      accessKeyId: accessKeyId,
      accessKeySecret: accessKeySecret,
      securityToken: securityToken,
      region: region,
    );
  }

  /// 创建VidAuth类型的视频源
  ///
  /// Create a VidAuth-type video source
  static VideoSource createVidAuthSource({
    required String vid,
    required String playAuth,
  }) {
    return VidAuthVideoSource(
      vid: vid,
      playAuth: playAuth,
    );
  }
}

// 下载状态基类
abstract class DownloadState {
  const DownloadState();
}

/// 未知状态
class UnknownState extends DownloadState {
  const UnknownState();
}

/// 下载中状态
class DownloadingState extends DownloadState {
  final int progress;

  const DownloadingState({required this.progress});
}

/// 下载完成状态
class DownloadCompletedState extends DownloadState {
  final String downloadFile;

  const DownloadCompletedState({required this.downloadFile});
}

/// 下载异常状态
class DownloadErrorState extends DownloadState {
  final String errorCode;
  final String errorMessage;

  const DownloadErrorState({
    required this.errorCode,
    required this.errorMessage,
  });
}

/// Android 播放器视图类型
///
/// Android player view type
///
/// 仅对 Android 平台生效，iOS 平台会忽略此配置。
/// Only takes effect on Android; iOS ignores this configuration.
enum AndroidViewType {
  /// SurfaceView 渲染
  ///
  /// 性能更优，但不支持动画变换和透明背景。
  ///
  /// Better performance, but does not support animated transitions or transparent backgrounds.
  surfaceView,

  /// TextureView 渲染
  ///
  /// 支持动画变换和透明背景，兼容性更好。
  ///
  /// Supports animated transitions and transparent backgrounds with better compatibility.
  textureView,

  /// DisplayView 渲染
  ///
  /// 基于 AliDisplayView 的视图类型。
  ///
  /// View type based on AliDisplayView.
  displayView;

  /// 默认视图类型
  ///
  /// Default view type
  static const AndroidViewType defaultValue = textureView;

  /// 转换为底层 SDK 的视图类型
  ///
  /// Convert to the underlying SDK view type
  AliPlayerViewTypeForAndroid toPlayerViewType() {
    return switch (this) {
      AndroidViewType.surfaceView => AliPlayerViewTypeForAndroid.surfaceview,
      AndroidViewType.textureView => AliPlayerViewTypeForAndroid.textureview,
      AndroidViewType.displayView => AliPlayerViewTypeForAndroid.displayview,
    };
  }
}

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
  /// - [isHardWareDecode]：是否开启硬解码，默认为true。
  /// - [subtitleConfig]：字幕配置，默认为默认配置。
  /// - [subtitleBuilder]：字幕构建器，可以为空。
  /// - [onPlayerConfig]：播放器自定义配置回调，在 prepare() 前调用，可以为空。
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
  /// - [isHardWareDecode]: Whether to enable hardwareDecoder , default is true.
  /// - [subtitleConfig]: Subtitle configuration, default is default configuration.
  /// - [subtitleBuilder]: Subtitle builder, can be null.
  /// - [onPlayerConfig]: Player custom configuration callback, called before prepare(), can be null.
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
    this.isHardWareDecode = true,
    this.subtitleConfig = const SubtitleConfig(),
    this.subtitleBuilder,
    this.onPlayerConfig,
  }) : assert(startTime >= 0, "Start time must be non-negative");

  /// 将 [AliPlayerWidgetData] 实例转换为字符串。
  ///
  /// Convert [AliPlayerWidgetData] instance to string.
  @override
  String toString() {
    return 'AliPlayerWidgetData{sceneType: $sceneType, videoSource: $videoSource, androidViewType: $androidViewType, coverUrl: $coverUrl, videoTitle: $videoTitle, thumbnailUrl: $thumbnailUrl, externalSubtitleUrl: $externalSubtitleUrl, autoPlay: $autoPlay, traceId: $traceId, startTime: $startTime, seekMode: $seekMode, isHardWareDecode: $isHardWareDecode, allowedScreenSleep: $allowedScreenSleep, subtitleConfig: $subtitleConfig, subtitleBuilder: $subtitleBuilder, onPlayerConfig: $onPlayerConfig}';
  }
}
