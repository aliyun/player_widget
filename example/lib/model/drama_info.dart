// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/3/12
// Brief: 剧集信息数据类

import 'video_info.dart';

/// 剧集信息数据类
///
/// A data class representing drama information.
class DramaInfo {
  /// 剧集id
  final int id;

  /// 剧集标题
  final String title;

  /// 剧集封面
  final String cover;

  /// 当前播放视频
  final VideoInfo drama;

  /// 剧集视频列表
  final List<VideoInfo> dramas;

  /// 构造函数
  ///
  /// Creates a new instance of [DramaInfo].
  const DramaInfo({
    required this.id,
    required this.title,
    required this.cover,
    required this.drama,
    required this.dramas,
  });

  /// 从JSON创建DramaInfo实例
  ///
  /// Creates a [DramaInfo] from JSON data.
  factory DramaInfo.fromJson(Map<String, dynamic> json) {
    return DramaInfo(
      id: json['id'] as int,
      title: json['title'] as String,
      cover: json['cover'] as String,
      drama: VideoInfo.fromJson(json['drama'] as Map<String, dynamic>),
      dramas: VideoInfo.fromJsonList(json['dramas'] as List<dynamic>),
    );
  }

  /// 将DramaInfo实例转换为JSON
  ///
  /// Converts this [DramaInfo] to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'cover': cover,
        'drama': drama.toJson(),
        'dramas': dramas.map((video) => video.toJson()).toList(),
      };

  /// 从JSON字符串列表创建DramaInfo列表
  ///
  /// Creates a list of [DramaInfo] from JSON data.
  static List<DramaInfo> fromJsonList(List<dynamic> jsonList) => jsonList
      .map((json) => DramaInfo.fromJson(json as Map<String, dynamic>))
      .toList();

  /// 创建DramaInfo的副本，但可以更新某些属性
  ///
  /// Creates a copy of this DramaInfo but with the given fields replaced with the new values.
  DramaInfo copyWith({
    int? id,
    String? title,
    String? cover,
    VideoInfo? drama,
    List<VideoInfo>? dramas,
  }) {
    return DramaInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      cover: cover ?? this.cover,
      drama: drama ?? this.drama,
      dramas: dramas ?? this.dramas,
    );
  }

  /// 获取特定id的剧集视频
  ///
  /// Get a drama video by id.
  VideoInfo? getDramaById(int videoId) {
    try {
      return dramas.firstWhere((video) => video.id == videoId);
    } catch (_) {
      return null;
    }
  }

  /// 获取剧集视频数量
  ///
  /// Get the number of drama videos.
  int get dramaCount => dramas.length;

  @override
  String toString() =>
      'DramaInfo{id: $id, title: $title, cover: $cover, drama: $drama, dramas: $dramaCount videos}';
}
