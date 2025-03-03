// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/19
// Brief: 视频信息数据类

/// 视频信息数据类
///
/// A data class representing video information.
class VideoInfo {
  /// 视频id
  final int id;

  /// 视频源地址
  final String videoUrl;

  /// 视频封面图
  final String coverUrl;

  /// 视频类型
  final String type;

  /// 构造函数
  ///
  /// Creates a new instance of [VideoInfo].
  VideoInfo({
    required this.id,
    required this.videoUrl,
    required this.coverUrl,
    this.type = "video",
  });

  @override
  String toString() {
    return 'VideoInfo{id: $id, videoUrl: $videoUrl, coverUrl: $coverUrl, type: $type}';
  }
}
