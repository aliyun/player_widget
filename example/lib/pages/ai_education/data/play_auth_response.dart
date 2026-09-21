// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: wyq
// Date: 2026/9/2
// Brief: 获取视频播放凭证（PlayAuth）接口的响应实体类

/// 获取视频播放凭证（PlayAuth）接口的响应实体类。
///
/// 该类用于解析从服务器获取的 JSON 响应数据，包含播放凭证相关数据。
/// 对应 App Server 接口：获取视频播放凭证。
class PlayAuthResponse {
  /// 业务状态码
  /// 0 表示成功，非 0 表示失败。
  final int? code;

  /// HTTP 状态码
  /// 字符串类型，例如 "200"。
  final String? httpCode;

  /// 请求是否成功
  /// true 表示成功，false 表示失败。
  final bool? success;

  /// 提示信息
  /// 成功时通常为 "success"，失败时为具体错误描述。
  final String? message;

  /// 请求唯一标识
  /// 用于问题排查追踪，可能为 null。
  final String? requestId;

  /// 播放凭证相关数据
  /// 仅在请求成功时返回。
  final PlayAuthData? data;

  PlayAuthResponse({
    this.code,
    this.httpCode,
    this.success,
    this.message,
    this.requestId,
    this.data,
  });

  factory PlayAuthResponse.fromJson(Map<String, dynamic> json) {
    return PlayAuthResponse(
      code: json['code'] as int?,
      httpCode: json['httpCode'] as String?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      requestId: json['requestId'] as String?,
      data: json['data'] == null
          ? null
          : PlayAuthData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'httpCode': httpCode,
      'success': success,
      'message': message,
      'requestId': requestId,
      'data': data?.toJson(),
    };
  }
}

/// 播放凭证数据体
///
/// 包含视频 ID 与播放授权凭证。
class PlayAuthData {
  /// 视频唯一标识 ID
  final String? videoId;

  /// Base64 编码的播放授权凭证字符串，用于播放器鉴权获取视频播放地址，
  /// 具有有效期，过期后需重新获取。
  final String? playAuth;

  PlayAuthData({this.videoId, this.playAuth});

  factory PlayAuthData.fromJson(Map<String, dynamic> json) {
    return PlayAuthData(
      videoId: json['videoId'] as String?,
      playAuth: json['playAuth'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'playAuth': playAuth,
    };
  }
}
