// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/13
// Brief: 多视频轨播放（可变清晰度）工具类

import 'package:flutter_aliplayer/flutter_avpdef.dart';

import 'log_util.dart';

/// A utility class for managing multi-track video playback with variable resolutions.
///
/// 多视频轨播放（可变清晰度）工具类。
class TrackInfoUtil {
  // 私有构造函数，防止实例化
  TrackInfoUtil._();

  /// 定义分辨率与对应宽高的映射
  static Map<String, List<int>> trackInfoResolutions = {
    "144P": [144, 256],
    "240P": [240, 426],
    "360P": [360, 640],
    "480P": [480, 854],
    "540P": [540, 960],
    "720P": [720, 1280],
    "1080P": [1080, 1920],
    "1440P": [1440, 2560],
    "2160P": [2160, 3840],
    "4320P": [4320, 7680],
  };

  /// 自动清晰度标识 key
  ///
  /// Quality key representing automatic quality selection.
  static const String autoQualityKey = 'AUTO';

  /// 未知清晰度标识 key
  ///
  /// Quality key representing unknown quality.
  static const String unknownQualityKey = 'unknown';

  /// 定义多清晰度可支持的类型
  static final _validTrackTypes = {
    FlutterAvpdef.AVPTRACK_TYPE_VIDEO,
    FlutterAvpdef.AVPTRACK_TYPE_SAAS_VOD,
  };

  /// 清晰度标识映射
  ///
  /// UI 层负责将 [autoQualityKey] 和 [unknownQualityKey] 转换为本地化文案。
  static const Map<String, String> qualityDescriptions = {
    autoQualityKey: autoQualityKey,
    unknownQualityKey: unknownQualityKey,
  };

  /// 过滤视频清晰度轨
  static List<AVPTrackInfo> filterVideoTrackInfoList(
    List<dynamic>? trackInfoList,
  ) {
    final List<AVPTrackInfo> videoTrackInfoList = [];
    if (trackInfoList == null || trackInfoList.isEmpty) {
      return videoTrackInfoList;
    }
    for (var value in trackInfoList) {
      try {
        AVPTrackInfo trackInfo = AVPTrackInfo.fromJson(value);
        final int? width = trackInfo.videoWidth;
        final int? height = trackInfo.videoHeight;
        if ((width ?? 0) <= 0 || (height ?? 0) <= 0) {
          continue;
        }
        if (!_validTrackTypes.contains(trackInfo.trackType)) {
          continue;
        }
        videoTrackInfoList.add(trackInfo);
      } catch (e) {
        loge("Error parsing track info: $e");
      }
    }
    return videoTrackInfoList;
  }

  /// 根据索引获取视频轨信息
  static AVPTrackInfo? getTrackInfoByIndex(
    List<AVPTrackInfo>? trackInfos,
    int? trackIndex,
  ) {
    if (trackInfos == null || trackInfos.isEmpty) {
      return null;
    }
    for (var trackInfo in trackInfos) {
      if (trackInfo.trackIndex == trackIndex) {
        return trackInfo;
      }
    }
    return null;
  }

  /// 获取视频轨的清晰度
  static String getQuality(AVPTrackInfo? trackInfo) {
    return trackInfo != null
        ? findResolution(trackInfo)
        : qualityDescriptions[autoQualityKey]!;
  }

  /// 遍历最接近的清晰度
  static String findResolution(AVPTrackInfo? trackInfo) {
    String nearestResolution = qualityDescriptions[unknownQualityKey]!;
    if (trackInfo == null || !_validTrackTypes.contains(trackInfo.trackType)) {
      return nearestResolution;
    }
    final int? width = trackInfo.videoWidth;
    final int? height = trackInfo.videoHeight;
    if ((width ?? -1) <= 0 || (height ?? -1) <= 0) {
      return nearestResolution;
    }
    int minDifference = double.maxFinite.toInt();
    for (final MapEntry<String, List<int>> entry
        in trackInfoResolutions.entries) {
      final int resWidth = entry.value[0];
      final int resHeight = entry.value[1];
      final int difference =
          (resWidth - width!).abs() + (resHeight - height!).abs();
      if (difference < minDifference) {
        minDifference = difference;
        nearestResolution = entry.key;
      }
    }
    return nearestResolution;
  }

  /// 获取视频轨索引
  static int getTrackIndex(AVPTrackInfo? trackInfo) {
    return trackInfo?.trackIndex ?? -1;
  }

  /// 从视频轨信息列表中提取索引
  static List<int> getIndexesFromTrackInfos(
    List<AVPTrackInfo> trackInfos,
  ) {
    return trackInfos.map((trackInfo) => getTrackIndex(trackInfo)).toList();
  }

  /// 从视频轨信息列表中提取清晰度描述
  static List<String> getQualitiesFromTrackInfos(
    List<AVPTrackInfo> trackInfos,
  ) {
    return trackInfos.map((trackInfo) => getQuality(trackInfo)).toList();
  }
}
