// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: wyq
// Date: 2026/9/2
// Brief: AI 内容加载器

import 'package:aliplayer_widget_example/pages/ai_education/ai_constants.dart';
import 'package:aliplayer_widget_example/pages/ai_education/data/ai_analysis_response.dart';
import 'package:aliplayer_widget_example/pages/ai_education/data/play_auth_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// AI 分析结果加载回调
///
/// [response] 服务端 DTO，失败或无有效内容时为 null。
typedef AiAnalysisCallback = void Function(AiAnalysisResponse? response);

/// PlayAuth 加载结果回调
///
/// [playAuth] PlayAuth 凭证，失败时为 null。
typedef PlayAuthCallback = void Function(String? playAuth);

/// AI 内容加载器
///
/// 封装 App Server HTTP 请求和 JSON 响应解析逻辑，
/// 将 App Server 返回的 AI 分析数据以 DTO ([AiAnalysisResponse]) 形式回调给消费侧。
/// 采用异步回调模式，网络请求在后台执行，通过事件循环在主 Isolate 回调结果。
class AiContentLoader {
  static const String _tag = 'AiContentLoader';

  /// HTTP 请求超时时间（秒）
  static const int _timeoutSeconds = 5;

  /// HTTP 客户端，用于执行异步请求
  late final Dio _dio;

  /// 取消令牌，用于取消进行中的请求
  final CancelToken _cancelToken = CancelToken();

  /// 取消标记，取消后不再触发回调
  bool _canceled = false;

  AiContentLoader() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: _timeoutSeconds),
      receiveTimeout: const Duration(seconds: _timeoutSeconds),
      responseType: ResponseType.json,
    ));
  }

  /// 异步加载 AI 内容（主线程安全）
  ///
  /// [mediaId] 媒体 ID（即视频 Vid）
  /// [callback] 加载结果回调
  Future<void> loadAiAnalysis(
    String mediaId,
    AiAnalysisCallback callback,
  ) async {
    if (_canceled) return;

    AiAnalysisResponse? result;
    try {
      // 构建请求 URI（不传 ResultType，默认返回所有类型数据）
      final url = AiContentConstants.buildApiUri(mediaId);

      // 执行异步 HTTP GET 请求
      final response = await _dio.get<Map<String, dynamic>>(
        url.toString(),
        cancelToken: _cancelToken,
      );

      if (_canceled) return;

      final data = response.data;
      if (data != null) {
        final apiResponse = AiAnalysisResponse.fromJson(data);
        if (_hasAnyContent(apiResponse)) {
          result = apiResponse;
        }
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _log('AI analysis request canceled');
      } else {
        _log('AI analysis request failed: $e');
      }
    } catch (e) {
      _log('loadAiAnalysis failed: $e');
    }

    // 回调置于 try-catch 之外，确保仅触发一次，且回调抛出的异常
    // 不会被误判为网络/解析失败。
    if (!_canceled) callback(result);
  }

  /// 异步加载 PlayAuth（主线程安全）
  ///
  /// [videoId] 视频 ID
  /// [callback] 加载结果回调
  Future<void> loadPlayAuth(String videoId, PlayAuthCallback callback) async {
    if (_canceled) return;

    String? result;
    try {
      final url = AiContentConstants.buildPlayAuthUrl(videoId);

      final response = await _dio.get<Map<String, dynamic>>(
        url,
        cancelToken: _cancelToken,
      );

      if (_canceled) return;

      final data = response.data;
      if (data != null) {
        final resp = PlayAuthResponse.fromJson(data);
        // 先校验业务结果，避免业务失败时仍把过期/无效的 playAuth 当作有效凭证
        final businessFailed =
            resp.success == false || (resp.code != null && resp.code != 0);
        if (businessFailed) {
          _log('PlayAuth business failed: '
              'code=${resp.code}, msg=${resp.message}');
        } else {
          result = resp.data?.playAuth;
        }
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _log('PlayAuth request canceled');
      } else {
        _log('PlayAuth request failed: $e');
      }
    } catch (e) {
      _log('loadPlayAuth failed: $e');
    }

    // 回调置于 try-catch 之外，确保仅触发一次。
    if (!_canceled) callback(result);
  }

  /// 取消所有进行中的加载任务
  ///
  /// 调用后：
  ///   - 已提交但未完成的请求会被取消；
  ///   - 所有回调（[AiAnalysisCallback] / [PlayAuthCallback]）不再触发；
  ///   - 本实例不可复用，后续调用 [loadAiAnalysis] / [loadPlayAuth] 将不会执行。
  ///
  /// 通常在页面销毁（如 State#dispose）时调用，避免内存泄漏和无效回调。
  void cancel() {
    _canceled = true;
    _cancelToken.cancel();
    // 关闭 Dio 实例，释放底层 HTTP 客户端连接池资源。
    _dio.close(force: true);
  }

  /// 判断 AI 分析结果是否包含有效内容（章节或摘要）。
  static bool _hasAnyContent(AiAnalysisResponse? response) {
    final results = response?.aiAnalysisResult;
    if (results == null || results.isEmpty) return false;
    return results.any((item) =>
        item.resultType == AiContentConstants.resultTypeChapter ||
        item.resultType == AiContentConstants.resultTypeSummary);
  }

  static void _log(String message) {
    debugPrint('$_tag: $message');
  }
}
