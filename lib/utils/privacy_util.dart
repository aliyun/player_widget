// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: keria's coding agent
// Date: 2026/5/18
// Brief: 隐私保护工具类

/// 隐私保护工具类
///
/// 提供隐私信息处理相关的工具方法，包括 URL 鉴权参数移除、字符串模糊化等功能。
/// 用于在日志输出、错误上报等场景中保护敏感信息。
///
/// Privacy Protection Utility Class
///
/// Provides utility methods for privacy information processing, including URL
/// authentication parameter removal, string blurring, etc. Used to protect
/// sensitive information in scenarios such as log output and error reporting.
class PrivacyUtil {
  PrivacyUtil._();

  static const String _mask = '***';
  static const int _minBlurLength = 4;

  /// 模糊化字符串
  ///
  /// 根据字符串长度采用不同的模糊策略：
  /// - 长度 <= 4：直接返回 "***"
  /// - 长度 5~8：保留首字符和尾字符，中间用 "***" 替代
  /// - 长度 > 8：保留前三位和后两位，中间用 "***" 替代
  ///
  /// Blur string based on length:
  /// - Length <= 4: Returns "***" directly
  /// - Length 5~8: Keeps first and last character, replaces middle with "***"
  /// - Length > 8: Keeps first 3 and last 2 characters, replaces middle with "***"
  static String blur(String? value) {
    if (value == null) return 'null';

    final len = value.length;
    if (len <= _minBlurLength) return _mask;
    if (len <= 8) return '${value[0]}$_mask${value[len - 1]}';
    return '${value.substring(0, 3)}$_mask${value.substring(len - 2)}';
  }

  /// 从 URL 中移除鉴权参数 (auth_key)
  ///
  /// Remove authentication parameter (auth_key) from URL
  static String? removeAuthKeyFromUrl(String? url) {
    if (url == null || url.isEmpty) return url;

    try {
      final uri = Uri.parse(url);
      if (!uri.queryParameters.containsKey('auth_key')) return url;

      final params = Map<String, String>.from(uri.queryParameters)
        ..remove('auth_key');
      return uri
          .replace(
            queryParameters: params.isEmpty ? null : params,
            query: params.isEmpty ? '' : null,
          )
          .toString();
    } catch (_) {
      return url;
    }
  }
}
