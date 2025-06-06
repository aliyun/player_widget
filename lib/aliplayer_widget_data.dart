// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/10
// Brief: Player Widget data, used to store the video data required by the player

part of 'aliplayer_widget_lib.dart';

/// 播放场景类型
///
/// Playback scene type
enum SceneType {
  /// 点播场景
  ///
  /// VOD Scene
  vod,

  /// 直播场景
  ///
  /// Live Scene
  live,

  /// 列表播放场景
  ///
  /// List Player Scene
  listPlayer;
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

/// 播放器组件数据，用于存储播放器所需的视频数据
///
/// Player Widget data, used to store the video data required by the player
class AliPlayerWidgetData {
  /// 播放场景类型，默认为点播 [SceneType.vod]
  ///
  /// Playback scene type, default is vod [SceneType.vod]
  SceneType sceneType = SceneType.vod;

  /// 视频资源对象，用于定义播放源
  ///
  /// Video source object, used to define the playback source
  VideoSource? videoSource;

  /// 视频URL地址
  ///
  /// 此属性已过时，请使用 [videoSource] 代替。
  /// 例如: 使用 `VideoSourceFactory.createUrlSource(url)` 创建视频源。
  /// 为了向后兼容而保留。
  ///
  /// Video URL address
  ///
  /// This property is deprecated. Please use [videoSource] instead.
  /// For example: use `VideoSourceFactory.createUrlSource(url)` to create a video source.
  /// Kept for backward compatibility.
  @Deprecated('Use videoSource or AliPlayerWidgetData.fromUrl() instead.')
  String get videoUrl => videoSource?.sourceType == SourceType.url
      ? (videoSource as UrlVideoSource).url
      : '';

  @Deprecated('Use videoSource or AliPlayerWidgetData.fromUrl() instead.')
  set videoUrl(String value) {
    if (value.isNotEmpty) {
      videoSource = VideoSourceFactory.createUrlSource(value);
    }
  }

  /// 封面图地址，可以为空
  ///
  /// Cover URL, can be empty
  String coverUrl;

  /// 视频标题，可以为空
  ///
  /// Video title, can be empty
  String videoTitle;

  /// 缩略图地址，可以为空
  ///
  /// Thumbnail URL, can be empty
  String thumbnailUrl;

  /// 是否自动播放，默认为 false
  ///
  /// Whether to play automatically, default is false
  bool autoPlay;

  /// 视频开始时间，单位毫秒，必须为非负数
  ///
  /// Video start time in milliseconds, must be non-negative
  int startTime;

  /// 视频 seek 模式，默认为精确模式 [FlutterAvpdef.ACCURATE]
  ///
  /// Video seek mode, default is accurate mode [FlutterAvpdef.ACCURATE]
  int seekMode = FlutterAvpdef.ACCURATE;

  /// 视频解码，默认为true
  ///
  /// Setting video decoding which is enable by default.
  bool isHardWareDecode = true;

  /// 是否允许屏幕休眠，默认为 false
  ///
  /// Whether to allow screen sleep, default is false
  bool allowedScreenSleep = false;

  /// 构造函数，用于创建 [AliPlayerWidgetData] 实例。
  ///
  /// Constructor to create an instance of [AliPlayerWidgetData].
  ///
  /// 参数：
  /// - [sceneType]：视频场景类型，默认为点播（VOD）。
  /// - [videoSource]: 视频资源对象，定义播放源（推荐使用）。
  /// - [videoUrl]：视频播放地址，已过时，建议使用 videoSource 代替。
  /// - [coverUrl]：视频封面图片地址，默认为空字符串。
  /// - [videoTitle]：视频标题，默认为空字符串。
  /// - [thumbnailUrl]：视频缩略图地址，默认为空字符串。
  /// - [autoPlay]：是否自动播放，默认为 true。
  /// - [startTime]：视频起始播放时间（秒），必须为非负数，默认为 0。
  /// - [seekMode]：视频跳转模式，默认为精确跳转。
  /// - [allowedScreenSleep]：是否允许屏幕休眠，默认为 false。
  /// - [isHardWareDecode]：是否开启硬解码，默认为true。
  ///
  /// Parameters:
  /// - [sceneType]: The type of video scene, defaulting to Video On Demand (VOD).
  /// - [videoSource]: Video source object defining the playback source (recommended).
  /// - [videoUrl]: The URL of the video to be played, deprecated, use videoSource instead.
  /// - [coverUrl]: The URL of the cover image for the video, defaulting to an empty string.
  /// - [videoTitle]: The title of the video, defaulting to an empty string.
  /// - [thumbnailUrl]: The URL of the thumbnail image for the video, defaulting to an empty string.
  /// - [autoPlay]: Whether to autoplay the video, defaulting to true.
  /// - [startTime]: The start time of video playback in seconds, must be non-negative, defaulting to 0.
  /// - [seekMode]: The seek mode for video playback, defaulting to accurate seeking.
  /// - [allowedScreenSleep]: Whether to allow screen sleep, default is false.
  /// - [isHardWareDecode]: Whether to enable hardwareDecoder , default is true.
  AliPlayerWidgetData({
    this.sceneType = SceneType.vod,
    VideoSource? videoSource,
    @Deprecated('Use videoSource or AliPlayerWidgetData.fromUrl() instead.')
    String videoUrl = "", // 标记参数为过时
    this.coverUrl = "",
    this.videoTitle = "",
    this.thumbnailUrl = "",
    this.autoPlay = true,
    this.startTime = 0,
    this.seekMode = FlutterAvpdef.ACCURATE,
    this.allowedScreenSleep = false,
    this.isHardWareDecode = true,
  }) : assert(startTime >= 0, "Start time must be non-negative") {
    // 初始化 videoSource：
    // 1. 如果提供了 videoSource，则直接使用
    // 2. 如果提供了 videoUrl，则创建 URL 类型的 videoSource
    // 3. 如果两者都没提供，则抛出异常
    if (videoSource != null) {
      this.videoSource = videoSource;
    } else if (videoUrl.isNotEmpty) {
      this.videoSource = VideoSourceFactory.createUrlSource(videoUrl);
    } else {
      throw ArgumentError("Either videoSource or videoUrl must be provided");
    }
  }

  /// 使用URL创建播放器数据的便捷构造函数
  ///
  /// Convenience constructor to create player data using a URL
  factory AliPlayerWidgetData.fromUrl({
    required String videoUrl,
    SceneType sceneType = SceneType.vod,
    String coverUrl = "",
    String videoTitle = "",
    String thumbnailUrl = "",
    bool autoPlay = true,
    int startTime = 0,
    int seekMode = FlutterAvpdef.ACCURATE,
    bool allowedScreenSleep = false,
    bool isHardWareDecode = true,
  }) {
    return AliPlayerWidgetData(
      videoSource: VideoSourceFactory.createUrlSource(videoUrl),
      sceneType: sceneType,
      coverUrl: coverUrl,
      videoTitle: videoTitle,
      thumbnailUrl: thumbnailUrl,
      autoPlay: autoPlay,
      startTime: startTime,
      seekMode: seekMode,
      allowedScreenSleep: allowedScreenSleep,
      isHardWareDecode: isHardWareDecode,
    );
  }

  /// 将 [AliPlayerWidgetData] 实例转换为字符串。
  ///
  /// Convert [AliPlayerWidgetData] instance to string.
  @override
  String toString() {
    return 'AliPlayerWidgetData{sceneType: $sceneType, videoSource: $videoSource, coverUrl: $coverUrl, videoTitle: $videoTitle, thumbnailUrl: $thumbnailUrl, autoPlay: $autoPlay, startTime: $startTime, seekMode: $seekMode, isHardWareDecode: $isHardWareDecode, allowedScreenSleep: $allowedScreenSleep}';
  }
}
