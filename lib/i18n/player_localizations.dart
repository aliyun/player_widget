// Copyright 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/4/7
// Brief: Player localizations delegate

import 'package:flutter/widgets.dart';

import 'player_i18n.dart';

/// 播放器本地化代理
///
/// Flutter LocalizationsDelegate implementation for the player.
///
/// This allows the player to respond to app-level locale changes
/// automatically when used with MaterialApp's localizationsDelegates.
///
/// ## Usage / 使用示例
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: const [
///     PlayerLocalizationsDelegate(),
///     GlobalMaterialLocalizations.delegate,
///     GlobalWidgetsLocalizations.delegate,
///   ],
///   supportedLocales: AliPlayerWidgetGlobalSetting.supportedLocales,
///   home: const VideoPage(),
/// );
/// ```
class PlayerLocalizationsDelegate
    extends LocalizationsDelegate<PlayerLocalizations> {
  const PlayerLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return PlayerI18n.isLocaleSupported(locale);
  }

  @override
  Future<PlayerLocalizations> load(Locale locale) async {
    return PlayerLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<PlayerLocalizations> old) =>
      false;
}

/// 播放器本地化类
///
/// Player localizations class.
class PlayerLocalizations {
  /// 当前语言
  final Locale locale;

  PlayerLocalizations(this.locale);

  /// 获取翻译
  ///
  /// Get translation.
  String t(String key, [Map<String, dynamic>? args]) {
    return PlayerI18n.t(key, args);
  }
}

/// Localizations 扩展，方便从 BuildContext 获取翻译
///
/// Extension on BuildContext for easy access to translations.
extension PlayerLocalizationsExtension on BuildContext {
  /// 获取播放器本地化实例
  ///
  /// Get player localizations instance.
  PlayerLocalizations? get playerLocalizations {
    return Localizations.of<PlayerLocalizations>(this, PlayerLocalizations);
  }

  /// 快捷翻译方法
  ///
  /// Quick translation method.
  String playerT(String key, [Map<String, dynamic>? args]) {
    return playerLocalizations?.t(key, args) ?? PlayerI18n.t(key, args);
  }
}
