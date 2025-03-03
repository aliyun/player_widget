// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/19
// Brief: HTTP 请求工具类

import 'package:dio/dio.dart';

/// HTTP 请求工具类
///
/// A utility class for handling HTTP requests using Dio.
class HTTPUtil {
  /// 单例模式：确保全局只有一个 Dio 实例
  static final HTTPUtil _instance = HTTPUtil._internal();

  factory HTTPUtil() => _instance;

  /// 获取单例实例
  ///
  /// Gets the singleton instance of HTTPUtil.
  static HTTPUtil get instance => _instance;

  HTTPUtil._internal() {
    // 默认初始化 Dio 实例
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
      responseType: ResponseType.json,
    ));

    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _log('REQ[${options.method}] => PATH: ${options.path}');
        return handler.next(options); // 继续请求
      },
      onResponse: (response, handler) {
        _log(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response); // 继续响应
      },
      onError: (DioException e, handler) {
        _log(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        return handler.next(e); // 继续错误处理
      },
    ));
  }

  /// 创建 Dio 实例
  late Dio _dio;

  /// 日志 TAG
  static const String _logTag = '[HTTPUtil]';

  /// 初始化配置（可选）
  ///
  /// Initializes the configuration for the Dio instance.
  void init({
    String baseUrl = '',
    int connectTimeout = 5000,
    int receiveTimeout = 3000,
    Map<String, dynamic>? headers,
  }) {
    // 配置 Dio 实例
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      headers: headers,
      responseType: ResponseType.json,
    );
  }

  /// GET 请求
  ///
  /// Sends a GET request.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow; // 抛出异常以便调用方处理
    }
  }

  /// POST 请求
  ///
  /// Sends a POST request.
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow; // 抛出异常以便调用方处理
    }
  }

  /// PUT 请求
  ///
  /// Sends a PUT request.
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow; // 抛出异常以便调用方处理
    }
  }

  /// DELETE 请求
  ///
  /// Sends a DELETE request.
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow; // 抛出异常以便调用方处理
    }
  }

  /// 错误处理
  ///
  /// Handles errors during HTTP requests.
  void _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      _log('连接超时');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      _log('接收超时');
    } else if (error.type == DioExceptionType.badResponse) {
      _log('服务器返回错误: ${error.response?.statusCode}, ${error.response?.data}');
    } else if (error.type == DioExceptionType.cancel) {
      _log('请求被取消');
    } else {
      _log('未知错误: ${error.message}');
    }
  }

  /// 统一日志输出
  ///
  /// Logs messages with a unified format.
  static void _log(String message) {
    print('$_logTag $message');
  }
}
