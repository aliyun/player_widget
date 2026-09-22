// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/10
// Brief: 视频播放源类型定义与工厂

import 'package:aliplayer_widget/utils/privacy_util.dart';

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
  /// 规则："类型前缀:关键标识"，例如 "url:https://..." 或 "vidsts:abc123"。
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

  /// 是否为 VID 源
  ///
  /// Whether the source is a VID source
  bool get isVidSource =>
      sourceType == SourceType.vidSts || sourceType == SourceType.vidAuth;
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
