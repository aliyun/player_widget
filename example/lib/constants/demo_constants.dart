// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/17
// Brief: A utility class containing demo-related constants.

/// A utility class containing demo-related constants.
///
/// This class provides static constants for URLs used in demo scenarios.
/// It is designed to prevent instantiation by using a private constructor.
class DemoConstants {
  // 私有构造函数，防止实例化
  DemoConstants._();

  /// 描述 VOD 组件的功能和特点
  ///
  /// A detailed description of the VOD component's features and capabilities.
  static const String vodComponentDescription =
      'A powerful and flexible VOD component for Flutter applications.\n'
      'It integrates with flutter_aliplayer to provide high-quality video playback, seamless streaming, '
      'and a rich set of features for both live and on-demand video content.\n'
      'Whether you are building a video playback solution for education, entertainment, or any other application, '
      'it makes it easy to deliver an engaging video experience.\n';

  /// 示例视频地址
  ///
  /// URL of the sample video file
  static const String sampleVideoUrl =
      "https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4";

  /// Sample video info list URL - network video source (default)
  ///
  /// Convert to video info list
  static const String defaultVideoInfoListUrl =
      "https://alivc-demo-cms.alicdn.com/versionProduct/resources/shortdrama/video-info-list-default.json";

  /// Optional list of Sample drama info list URL - network drama source (total)
  static const String defaultDramaInfoListTotalUrl =
      "https://alivc-demo-cms.alicdn.com/versionProduct/resources/shortdrama/drama-info-list-total.json";

  /// Key of Sample drama info list URL
  static const String keyDramaInfoListUrl = "dramaInfoListUrl";

  /// URL of the sample external subtitle file
  static const String defaultExternalSubtitleUrl =
      "https://alivc-demo-cms.alicdn.com/versionProduct/resources/aliplayer_widget/long-video.srt";
}
