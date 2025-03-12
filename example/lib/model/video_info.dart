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
  const VideoInfo({
    required this.id,
    required this.videoUrl,
    required this.coverUrl,
    this.type = "video",
  });

  /// 从JSON创建VideoInfo实例
  ///
  /// Creates a [VideoInfo] from JSON data.
  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id'] as int,
      videoUrl: json['url'] as String,
      coverUrl: json['coverUrl'] as String,
      type: json['type'] as String? ?? 'video',
    );
  }

  /// 将VideoInfo实例转换为JSON
  ///
  /// Converts this [VideoInfo] to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'url': videoUrl,
        'coverUrl': coverUrl,
        'type': type,
      };

  /// 从JSON字符串列表创建VideoInfo列表
  ///
  /// Creates a list of [VideoInfo] from JSON data.
  static List<VideoInfo> fromJsonList(List<dynamic> jsonList) => jsonList
      .map((json) => VideoInfo.fromJson(json as Map<String, dynamic>))
      .toList();

  /// 创建VideoInfo的副本，但可以更新某些属性
  ///
  /// Creates a copy of this VideoInfo but with the given fields replaced with the new values.
  VideoInfo copyWith({
    int? id,
    String? videoUrl,
    String? coverUrl,
    String? type,
  }) {
    return VideoInfo(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      type: type ?? this.type,
    );
  }

  @override
  String toString() =>
      'VideoInfo{id: $id, videoUrl: $videoUrl, coverUrl: $coverUrl, type: $type}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          videoUrl == other.videoUrl &&
          coverUrl == other.coverUrl &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, videoUrl, coverUrl, type);
}
