// Copyright 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/4/7
// Brief: Player translations interface

import 'dart:ui' show Locale;

/// 播放器翻译接口
///
/// Abstract interface for player translations.
/// Implement this class to provide custom translations.
///
/// ## 实现示例 / Implementation Example
///
/// ```dart
/// class PlayerTranslationsJa with PlayerTranslationsMixin {
///   @override
///   Locale get locale => const Locale('ja');
///
///   @override
///   Map<String, dynamic> get translations => {
///     'player': {
///       'settings': {
///         'volume': '音量',
///         // ...
///       },
///     },
///   };
/// }
/// ```
abstract class PlayerTranslations {
  /// 语言代码 (如 'zh', 'en', 'ja')
  Locale get locale;

  /// 获取翻译文本
  ///
  /// [key] 翻译键，支持嵌套格式如 'player.settings.volume'
  /// [args] 可选参数，用于插值替换
  String translate(String key, [Map<String, dynamic>? args]);

  /// 获取完整的翻译 Map
  Map<String, dynamic> get translations;
}

/// 翻译 Mixin，提供通用实现逻辑
///
/// Translation mixin that provides common implementation logic.
mixin PlayerTranslationsMixin implements PlayerTranslations {
  @override
  String translate(String key, [Map<String, dynamic>? args]) {
    String text = _getNestedValue(translations, key) ?? key;

    if (args != null && args.isNotEmpty) {
      text = _interpolate(text, args);
    }

    return text;
  }

  /// 获取嵌套值
  ///
  /// Supports nested key format like 'player.settings.volume'
  String? _getNestedValue(Map<String, dynamic> map, String key) {
    final keys = key.split('.');
    dynamic current = map;

    for (final k in keys) {
      if (current is Map<String, dynamic> && current.containsKey(k)) {
        current = current[k];
      } else {
        return null;
      }
    }

    return current is String ? current : null;
  }

  /// 参数插值
  ///
  /// Replaces placeholders like {speed} with actual values.
  String _interpolate(String text, Map<String, dynamic> args) {
    return text.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (match) {
        final key = match.group(1);
        if (key != null && args.containsKey(key)) {
          return args[key].toString();
        }
        return match.group(0) ?? '';
      },
    );
  }
}
