// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/17
// Brief: A utility class containing demo-related constants.

/// A utility class containing demo-related constants.
///
/// This class provides static constants for URLs used in demo scenarios.
/// It is designed to prevent instantiation by using a private constructor.
/// Client Player SDK Version Requirement: When using a local-signed playback credential (JWTPlayAuth) for playback, the client player SDK version must be ≥ 7.10.0; otherwise, playback authentication will fail.
class DemoConstants {
  // 私有构造函数，防止实例化
  DemoConstants._();

  /// 示例横屏VID
  ///
  /// VID of the sample landscape video file
  static const String sampleVid = "80b6301d909371f1aa965017f0e80402";

  /// 示例横屏播放凭证
  ///
  /// PLAY auth of the sample landscape video file
  static const String samplePlayAuth =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6ImFwcC0xMDAwMDAwIiwidmlkZW9JZCI6IjgwYjYzMDFkOTA5MzcxZjFhYTk2NTAxN2YwZTgwNDAyIiwiY3VycmVudFRpbWVTdGFtcCI6MTc4NTkwOTgxMTY4MiwiZXhwaXJlVGltZVN0YW1wIjoxOTQzNTg5ODExNjgyLCJyZWdpb25JZCI6ImNuLXNoYW5naGFpIiwicGxheUNvbnRlbnRJbmZvIjp7InN0cmVhbVR5cGUiOiJ2aWRlbyIsImFwaVZlcnNpb24iOiIxLjAuMiIsImF1dGhUaW1lb3V0IjoyODAwMH19.gQN7Iq7ufZXIUbJ8-JAfPI5NmDGIIfZhWUCSXFafMT0";

  /// 示例视频地址
  ///
  /// URL of the sample video file
  static const String sampleVideoUrl =
      "https://alivc-demo-vod.aliyuncs.com/6b357371ef3c45f4a06e2536fd534380/53733986bce75cfc367d7554a47638c0-fd.mp4";

  /// 示例竖屏VID
  ///
  /// VID of the sample portrait video file
  static const String sampleVidPortrait = "00e9b526d0d671f085715017f1e90402";

  /// 示例竖屏播放凭证
  ///
  /// PLAY auth of the sample portrait video file
  static const String samplePlayAuthPortrait =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6ImFwcC0xMDAwMDAwIiwidmlkZW9JZCI6IjAwZTliNTI2ZDBkNjcxZjA4NTcxNTAxN2YxZTkwNDAyIiwiY3VycmVudFRpbWVTdGFtcCI6MTc2ODE4ODIzNzAwNiwiZXhwaXJlVGltZVN0YW1wIjoxOTI1ODY4MjM3MDA2LCJyZWdpb25JZCI6ImNuLXNoYW5naGFpIiwicGxheUNvbnRlbnRJbmZvIjp7ImZvcm1hdHMiOiJtM3U4Iiwic3RyZWFtVHlwZSI6InZpZGVvIiwiYXV0aFRpbWVvdXQiOjE4MDB9fQ.AwXM5c8EsLJbhTPoNbEiB3uFVkl7heukuFbntHmC7no";

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
