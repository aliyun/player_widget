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

/// 播放器组件数据，用于存储播放器所需的视频数据
///
/// Player Widget data, used to store the video data required by the player
class AliPlayerWidgetData {
  /// 播放场景类型，默认为点播 [SceneType.vod]
  ///
  /// Playback scene type, default is vod [SceneType.vod]
  SceneType sceneType = SceneType.vod;

  /// 视频地址，不能为空
  ///
  /// Video URL, must not be empty
  String videoUrl;

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

  /// 构造函数，用于创建 [AliPlayerWidgetData] 实例。
  ///
  /// Constructor to create an instance of [AliPlayerWidgetData].
  ///
  /// 参数：
  /// - [sceneType]：视频场景类型，默认为点播（VOD）。
  /// - [videoUrl]：视频播放地址，不能为空。
  /// - [coverUrl]：视频封面图片地址，默认为空字符串。
  /// - [videoTitle]：视频标题，默认为空字符串。
  /// - [thumbnailUrl]：视频缩略图地址，默认为空字符串。
  /// - [autoPlay]：是否自动播放，默认为 true。
  /// - [startTime]：视频起始播放时间（秒），必须为非负数，默认为 0。
  /// - [seekMode]：视频跳转模式，默认为精确跳转。
  ///
  /// Parameters:
  /// - sceneType: The type of video scene, defaulting to Video On Demand (VOD).
  /// - videoUrl: The URL of the video to be played, must not be empty.
  /// - coverUrl: The URL of the cover image for the video, defaulting to an empty string.
  /// - videoTitle: The title of the video, defaulting to an empty string.
  /// - thumbnailUrl: The URL of the thumbnail image for the video, defaulting to an empty string.
  /// - autoPlay: Whether to autoplay the video, defaulting to true.
  /// - startTime: The start time of video playback in seconds, must be non-negative, defaulting to 0.
  /// - seekMode: The seek mode for video playback, defaulting to accurate seeking.
  AliPlayerWidgetData({
    this.sceneType = SceneType.vod,
    this.videoUrl = "",
    this.coverUrl = "",
    this.videoTitle = "",
    this.thumbnailUrl = "",
    this.autoPlay = true,
    this.startTime = 0,
    this.seekMode = FlutterAvpdef.ACCURATE,
  })  : assert(videoUrl.isNotEmpty, "Video URL must not be empty"),
        assert(startTime >= 0, "Start time must be non-negative");
}
