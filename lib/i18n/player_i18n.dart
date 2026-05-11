// Copyright 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/4/7
// Brief: Player internationalization manager

import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/foundation.dart' show visibleForTesting, ValueNotifier;

import 'player_translations.dart';
import 'translations/player_translations_zh.dart';
import 'translations/player_translations_en.dart';

/// 播放器国际化管理类
///
/// **内部使用说明 / Internal Use Note:**
/// 此类供 `aliplayer_widget` 内部组件调用。
/// 外部用户请使用 [AliPlayerWidgetGlobalSetting] 的相关方法。
///
/// This class is for internal `aliplayer_widget` components.
/// External users should use [AliPlayerWidgetGlobalSetting] methods instead.
///
/// - `AliPlayerWidgetGlobalSetting.t()` - 获取翻译 / Get translation
/// - `AliPlayerWidgetGlobalSetting.initI18n()` - 初始化 / Initialize
/// - `AliPlayerWidgetGlobalSetting.setLocale()` - 设置语言 / Set locale
/// - `AliPlayerWidgetGlobalSetting.registerTranslations()` - 注册语言包 / Register translations
///
/// ## Features / 功能特性
///
/// - 内置中英文支持 / Built-in Chinese and English support
/// - 支持外部语言包注入 / Support external language pack injection
/// - 支持覆盖内置翻译 / Support overriding built-in translations
/// - Fallback 机制 / Fallback mechanism
/// - 运行时切换语言 / Runtime language switching
/// - 自动跟随系统语言 / Auto-sync with system locale
class PlayerI18n {
  PlayerI18n._();

  /// 默认语言
  /// 缺失语言时降级到英文
  ///
  /// Default locale (fallback when system locale not supported)
  /// Fallback to English when language is missing
  static const Locale defaultLocale = Locale('en');

  /// 当前语言
  ///
  /// Current locale
  static Locale _currentLocale = defaultLocale;

  /// 内置翻译映射表
  ///
  /// Built-in translations map
  static final Map<String, PlayerTranslations> _builtInTranslations = {
    'zh': PlayerTranslationsZh(),
    'en': PlayerTranslationsEn(),
  };

  /// 外部注册的翻译映射表
  ///
  /// Registered translations map
  static final Map<String, PlayerTranslations> _registeredTranslations = {};

  /// 翻译覆盖映射表（按语言分组）
  ///
  /// Override translations map
  static final Map<String, Map<String, dynamic>> _overrideTranslations = {};

  /// Fallback 语言列表
  /// 优先级：内置中文 → 英文
  ///
  /// Fallback locale list
  /// Priority: Built-in Chinese → English
  static const List<String> _fallbackLocales = ['zh', 'en'];

  /// 当前翻译实例 / Current translations instance
  static PlayerTranslations? _currentTranslations;

  /// 语言变化监听器 / Locale change notifier
  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier(defaultLocale);

  /// 获取系统语言
  ///
  /// Get system locale.
  ///
  /// Returns the system's preferred locale, or null if unavailable.
  static Locale? get systemLocale {
    try {
      return PlatformDispatcher.instance.locale;
    } catch (_) {
      return null;
    }
  }

  /// 获取最佳匹配的语言
  ///
  /// Get the best matching locale.
  ///
  /// Priority:
  /// 1. [preferredLocale] - if provided and supported
  /// 2. System locale (exact match)
  /// 3. System locale language code match
  /// 4. Registered external language pack
  /// 5. Fallback to English
  static Locale _getBestLocale([Locale? preferredLocale]) {
    // 1. 优先使用传入的语言（如果支持）
    if (preferredLocale != null && isLocaleSupported(preferredLocale)) {
      return preferredLocale;
    }

    // 2. 尝试使用系统语言（完全匹配）
    final system = systemLocale;
    if (system != null && isLocaleSupported(system)) {
      return system;
    }

    // 3. 尝试匹配系统语言的语言代码（忽略国家代码）
    if (system != null) {
      final langCode = system.languageCode;
      if (isLocaleSupported(Locale(langCode))) {
        return Locale(langCode);
      }
    }

    // 4. 降级到英文（默认语言）
    return defaultLocale;
  }

  /// 初始化国际化
  ///
  /// Initialize internationalization.
  ///
  /// [locale] 初始语言，为空时自动跟随系统语言
  /// Initial locale, auto-syncs with system locale when null.
  static void initialize([Locale? locale]) {
    _currentLocale = _getBestLocale(locale);
    localeNotifier.value = _currentLocale;
    _updateCurrentTranslations();
  }

  /// 更新语言（跟随系统语言变化）
  ///
  /// Update locale (follow system locale changes).
  ///
  /// Call this when the system locale changes, e.g., in a listener.
  static void updateFromSystemLocale() {
    final newLocale = _getBestLocale();
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      localeNotifier.value = newLocale;
      _updateCurrentTranslations();
    }
  }

  /// 设置当前语言
  ///
  /// Set current locale.
  static void setLocale(Locale locale) {
    if (_currentLocale == locale) return;

    _currentLocale = locale;
    localeNotifier.value = locale;
    _updateCurrentTranslations();
  }

  /// 获取当前语言
  ///
  /// Get current locale.
  static Locale get locale => _currentLocale;

  /// 注册外部语言包
  ///
  /// Register external language pack.
  ///
  /// 用于添加新的语言支持，如日语、韩语等。
  /// Used to add new language support, such as Japanese, Korean, etc.
  static void registerTranslations(PlayerTranslations translations) {
    final langCode = translations.locale.languageCode;
    _registeredTranslations[langCode] = translations;

    // 如果当前语言匹配，更新翻译实例
    if (_currentLocale.languageCode == langCode) {
      _updateCurrentTranslations();
    }
  }

  /// 批量注册外部语言包
  ///
  /// Register multiple external language packs.
  static void registerAllTranslations(
      List<PlayerTranslations> translationsList) {
    for (final translations in translationsList) {
      registerTranslations(translations);
    }
  }

  /// 覆盖内置翻译
  ///
  /// Override built-in translations.
  ///
  /// 用于修改特定语言的某些翻译项。
  /// Used to modify specific translation items for a language.
  ///
  /// [langCode] 语言代码（如 'zh', 'en'）
  /// [overrides] 覆盖的翻译内容
  static void overrideTranslations(
    String langCode,
    Map<String, dynamic> overrides,
  ) {
    _overrideTranslations[langCode] = {
      ...(_overrideTranslations[langCode] ?? {}),
      ...overrides,
    };

    // 如果当前语言匹配，更新翻译实例
    if (_currentLocale.languageCode == langCode) {
      _updateCurrentTranslations();
    }
  }

  /// 获取翻译文本
  ///
  /// Get translated text.
  ///
  /// **注意**：此方法供 `aliplayer_widget` 内部组件使用。
  /// 外部用户请使用 `AliPlayerWidgetGlobalSetting.t()`。
  ///
  /// **Note**: This method is for internal `aliplayer_widget` components.
  /// External users should use `AliPlayerWidgetGlobalSetting.t()`.
  ///
  /// [key] 翻译键，支持嵌套格式
  /// [args] 可选参数，用于插值替换
  static String t(String key, [Map<String, dynamic>? args]) {
    // 1. 检查覆盖翻译 / Check override translations
    final overrideText = _getFromOverride(key);
    if (overrideText != null) {
      return _interpolateIfNeeded(overrideText, args);
    }

    // 2. 检查当前语言翻译 / Check current translations
    final translations = _currentTranslations;
    if (translations != null) {
      final text = translations.translate(key, args);
      if (text != key) return text;
    }

    // 3. Fallback 到其他语言 / Fallback to other languages
    // 优先级：内置中文 → 内置英文 → 其他已注册语言
    final fallbackLocaleList = [..._fallbackLocales];

    // 添加外部注册的语言（排除当前语言）
    for (final langCode in _registeredTranslations.keys) {
      if (langCode != _currentLocale.languageCode &&
          !fallbackLocaleList.contains(langCode)) {
        fallbackLocaleList.add(langCode);
      }
    }

    for (final fallbackLang in fallbackLocaleList) {
      final fallbackTranslations = _getTranslationsForLang(fallbackLang);
      if (fallbackTranslations != null) {
        final text = fallbackTranslations.translate(key, args);
        if (text != key) return text;
      }
    }

    // 4. 返回 key 本身作为最后 fallback / Return key as final fallback
    return key;
  }

  /// 获取支持的 Locale 列表
  ///
  /// Get supported locales list.
  static List<Locale> get supportedLocales {
    final locales = <Locale>[];

    // 添加内置语言 / Add built-in languages
    for (final langCode in _builtInTranslations.keys) {
      locales.add(Locale(langCode));
    }

    // 添加注册的语言 / Add registered languages
    for (final langCode in _registeredTranslations.keys) {
      if (!locales.any((l) => l.languageCode == langCode)) {
        locales.add(Locale(langCode));
      }
    }

    return locales;
  }

  /// 检查语言是否支持
  ///
  /// Check if locale is supported.
  static bool isLocaleSupported(Locale locale) {
    final langCode = locale.languageCode;
    return _builtInTranslations.containsKey(langCode) ||
        _registeredTranslations.containsKey(langCode);
  }

  /// 更新当前翻译实例
  ///
  /// Update current translations instance.
  static void _updateCurrentTranslations() {
    _currentTranslations = _getTranslationsForLang(_currentLocale.languageCode);
  }

  /// 获取指定语言的翻译实例
  ///
  /// Get translations instance for specified language.
  static PlayerTranslations? _getTranslationsForLang(String langCode) {
    // 优先使用注册的翻译 / Prefer registered translations
    if (_registeredTranslations.containsKey(langCode)) {
      return _registeredTranslations[langCode];
    }

    // 其次使用内置翻译 / Use built-in translations
    return _builtInTranslations[langCode];
  }

  /// 从覆盖翻译中获取文本
  ///
  /// Get text from override translations.
  static String? _getFromOverride(String key) {
    final langCode = _currentLocale.languageCode;
    final overrides = _overrideTranslations[langCode];
    if (overrides == null) return null;

    return _getNestedValue(overrides, key);
  }

  /// 获取嵌套值
  ///
  /// Get nested value from map.
  static String? _getNestedValue(Map<String, dynamic> map, String key) {
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

  /// 如果需要则进行插值
  ///
  /// Interpolate if needed.
  static String _interpolateIfNeeded(String text, Map<String, dynamic>? args) {
    if (args == null || args.isEmpty) return text;

    return text.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (match) {
        final key = match.group(1);
        if (key != null && args.containsKey(key)) {
          final value = args[key];
          if (value != null) {
            return value.toString();
          }
        }
        return match.group(0) ?? '';
      },
    );
  }

  /// 重置所有状态（用于测试）
  ///
  /// Reset all states (for testing).
  @visibleForTesting
  static void reset() {
    _currentLocale = defaultLocale;
    _registeredTranslations.clear();
    _overrideTranslations.clear();
    _currentTranslations = null;
    localeNotifier.value = defaultLocale;
  }
}
