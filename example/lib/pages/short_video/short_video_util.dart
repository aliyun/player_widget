// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/3/12
// Brief: 短视频工具类

import 'package:aliplayer_widget_example/model/drama_info.dart';
import 'package:aliplayer_widget_example/model/video_info.dart';
import 'package:aliplayer_widget_example/utils/http_util.dart';
import 'package:flutter/cupertino.dart';

/// 短视频工具类
///
/// Utility class for short video operations.
class ShortVideoUtil {
  // 私有构造函数，防止实例化
  ShortVideoUtil._();

  /// 加载普通视频列表数据
  ///
  /// Loads a list of video information from the given URL.
  /// If an error occurs, logs the error and returns an empty list.
  static Future<List<VideoInfo>> loadVideoInfoList(String url) async {
    try {
      // 发起 HTTP 请求获取普通视频列表数据
      final response = await HTTPUtil.instance.get(url);

      // 检查响应是否为空
      if (response == null) {
        debugPrint("Error: Video info response is null for URL: $url");
        return [];
      }

      // 检查响应是否为列表
      if (response is List) {
        final List<dynamic> jsonData = response;
        return jsonData.map((json) => VideoInfo.fromJson(json)).toList();
      } else {
        debugPrint("Error: Invalid video info list format for URL: $url");
        return [];
      }
    } catch (e) {
      // 打印错误日志并返回空数组
      debugPrint("Error loading video info list for URL: $url, Exception: $e");
      return [];
    }
  }

  /// 加载剧集信息列表数据
  ///
  /// Loads a list of drama information from the given URL.
  /// If an error occurs, logs the error and returns an empty list.
  static Future<List<DramaInfo>> loadDramaInfoList(String url) async {
    try {
      // 发起 HTTP 请求获取剧集信息列表数据
      final response = await HTTPUtil.instance.get(url);

      // 检查响应是否为空
      if (response == null) {
        debugPrint("Error: Drama info response is null for URL: $url");
        return [];
      }

      // 检查响应是否为非空列表
      if (response is List && response.isNotEmpty) {
        return response
            .map((dramaJson) => DramaInfo.fromJson(dramaJson))
            .toList();
      } else {
        debugPrint("Error: Invalid drama info list format for URL: $url");
        return [];
      }
    } catch (e) {
      // 打印错误日志并返回空数组
      debugPrint("Error loading drama info list for URL: $url, Exception: $e");
      return [];
    }
  }

  /// 从剧集信息中提取视频列表
  ///
  /// Extracts a list of video information from the given drama info.
  /// If dramaInfo is null or its dramas list is empty, returns an empty list.
  static List<VideoInfo> getVideoInfoListFromDramaInfo(DramaInfo? dramaInfo) {
    try {
      // 如果 dramaInfo 为空或其 dramas 列表为空，则返回空列表
      if (dramaInfo == null || dramaInfo.dramas.isEmpty) {
        return [];
      }

      // 返回 dramas 列表
      return dramaInfo.dramas;
    } catch (e) {
      // 打印错误日志并返回空数组
      debugPrint("Error extracting video info from drama info: $e");
      return [];
    }
  }
}
