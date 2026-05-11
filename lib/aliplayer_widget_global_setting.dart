// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/14
// Brief: AliPlayer Widget 全局配置

part of 'aliplayer_widget_lib.dart';

/// 全局初始化自定义配置回调
///
/// Global initialization custom configuration callback.
///
/// 在 Widget 全局初始化完成后调用，允许用户执行自定义的全局设置操作，
/// 例如 setOption、mediaLoader 配置等。
///
/// 适用于全局级别的配置（如全局 setOption、mediaLoader 等），
/// 与实例级别的 [OnPlayerConfigCallback] 互补：
/// - 全局配置 → 使用 [OnGlobalInitCallback]，通过 [AliPlayerWidgetGlobalSetting.setOnGlobalInit] 注册
/// - 实例配置 → 使用 [OnPlayerConfigCallback]，通过 [AliPlayerWidgetData.onPlayerConfig] 注入
///
/// Called after Widget global initialization is complete, allowing users to perform
/// custom global setup operations such as setOption, mediaLoader configuration, etc.
///
/// This callback is designed for global-level configuration and complements
/// the instance-level [OnPlayerConfigCallback]:
/// - Global config → Use [OnGlobalInitCallback] via [AliPlayerWidgetGlobalSetting.setOnGlobalInit]
/// - Instance config → Use [OnPlayerConfigCallback] via [AliPlayerWidgetData.onPlayerConfig]
typedef OnGlobalInitCallback = void Function();

/// AliPlayer Widget Global Setting
///
/// AliPlayer Widget 全局配置
class AliPlayerWidgetGlobalSetting {
  /// Flutter Widget version
  ///
  /// Flutter Widget 版本号
  static const String kWidgetVersion = '7.14.0';

  /// whether to enable local cache
  ///
  /// 是否开启本地缓存
  static const _enableLocalCache = true;

  /// local cache max buffer memory
  ///
  /// 5.4.7.1及以后版本已废弃，暂无作用。
  static const int _localCacheMaxBufferMemoryKB = 10 * 1024;

  /// local cache expire time
  ///
  /// 5.4.7.1及以后版本已废弃，暂无作用。
  static const int _localCacheExpireTime = 30 * 24 * 60;

  /// local cache max capacity
  ///
  /// 最大缓存容量。单位：兆，默认值20GB
  /// 在清理时，如果缓存总容量超过此大小，则会以cacheItem为粒度，按缓存的最后时间排序，一个一个的删除最旧的缓存文件，直到小于等于最大缓存容量。
  static const int _localCacheMaxCapacityMb = 20 * 1024;

  /// local cache free storage
  ///
  /// 磁盘最小空余容量。单位：兆，默认值0
  /// 在清理时，同最大缓存容量，如果当前磁盘容量小于该值，也会按规则一个一个的删除缓存文件，直到freeStorage大于等于该值或者所有缓存都被清理掉。
  static const int _localCacheFreeStorageMb = 0;

  // 私有构造函数，防止实例化
  AliPlayerWidgetGlobalSetting._();

  /// 标志变量，用于确保全局配置只执行一次
  static bool _isInitialized = false;

  /// 全局初始化自定义配置回调
  ///
  /// Global initialization custom configuration callback
  static OnGlobalInitCallback? _onGlobalInitCallback;

  /// 注册全局初始化自定义配置回调
  ///
  /// Register a callback for custom global initialization configuration.
  ///
  /// 该回调会在 Widget 内部全局初始化完成后被调用，允许用户执行额外的全局设置操作。
  /// 建议在 Widget 使用前调用此方法（如 main() 中），确保全局配置在播放器创建前生效。
  ///
  /// 对于未通过 [AliPlayerWidgetGlobalSetting] 直接透出的全局接口
  /// （如自定义 setOption 等），建议在此回调中自行调用实现。
  ///
  /// The callback is invoked after the Widget's internal global initialization is complete,
  /// allowing users to perform additional global setup operations.
  /// It is recommended to call this method before using the Widget (e.g., in main())
  /// to ensure global configuration takes effect before any player is created.
  ///
  /// For global APIs not directly exposed by [AliPlayerWidgetGlobalSetting]
  /// (e.g., custom setOption etc.), it is recommended to call them
  /// within this callback.
  ///
  /// 使用示例 / Usage example:
  /// ```dart
  /// AliPlayerWidgetGlobalSetting.setOnGlobalInit(() {
  ///   // 其他全局配置...
  /// });
  /// ```
  static void setOnGlobalInit(OnGlobalInitCallback? callback) {
    _onGlobalInitCallback = callback;
  }

  /// Setup global configuration.
  /// Internally set, no need to call externally again.
  ///
  /// 设置全局配置，内部已设置，无需外部再调用
  static Future<void> setupConfig() async {
    if (_isInitialized) {
      return; // 如果已经初始化过，直接返回
    }

    // 标记为已初始化
    _isInitialized = true;

    // 设置业务标识
    _setupExtraData();

    // 自动初始化 i18n（跟随系统语言）
    PlayerI18n.initialize();

    // 调用客户自定义全局配置回调
    _onGlobalInitCallback?.call();
  }

  /// 配置能力识别数据
  ///
  /// Setup capability recognition data.
  static void _setupExtraData() {
    // 播放体验优化（用于 AliPlayerWidget 能力识别，请勿覆盖）
    FlutterAliPlayerGlobalSettings.setOption(
      AliPlayerGlobalSettings.SET_EXTRA_DATA,
      ScenarioManager.globalExtraData,
    );
  }

  /// Set storage paths
  ///
  /// 设置存储路径
  ///
  /// [cachePath] 缓存路径（可选）
  /// [filesPath] 文件路径（可选）
  static void setStoragePaths({
    String? cachePath,
    String? filesPath,
  }) {
    StorageManager.setStoragePaths(
      cachePath: cachePath,
      filesPath: filesPath,
    );

    // 初始化所有文件夹
    FileManager.initializeAllFolders();

    // 自动配置媒体加载器
    _setupMediaLoaderConfig();
  }

  /// Internal method to setup media loader config.
  ///
  /// 内部方法：设置播放器预加载配置
  ///
  /// [localCacheDir] 本地缓存目录，如果为null则使用默认路径
  static void _setupMediaLoaderConfig([String? localCacheDir]) {
    // 如果没有传入路径，使用默认路径（优先使用缓存路径）
    final cacheDir = localCacheDir ?? FileManager.preloadPath;

    if (cacheDir == null) {
      logw(
          'Warning: No cache directory available, media loader config not set');
      return;
    }

    // FIXME keria: Why do int values need to be passed as strings??? Niubility..
    // 设置本地缓存配置
    FlutterAliplayer.enableLocalCache(
      _enableLocalCache,
      "$_localCacheMaxBufferMemoryKB",
      cacheDir,
      DocTypeForIOS.documents,
    );

    // FIXME keria: Why do int values need to be passed as strings??? Niubility..
    // 设置缓存文件清理配置
    FlutterAliplayer.setCacheFileClearConfig(
      "$_localCacheExpireTime",
      "$_localCacheMaxCapacityMb",
      "$_localCacheFreeStorageMb",
    );
  }

  /// 清除 Widget 缓存
  ///
  /// Clear widget cache
  static Future<void> clearCaches() async {
    // 清除视频缓存
    await FlutterAliplayer.clearCaches();

    // 清除文件缓存
    FileManager.clearCache();

    // 清除图片缓存
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  // ======================== 国际化 (i18n) ========================

  /// 获取翻译文本
  ///
  /// Get translated text.
  ///
  /// **对外公开 API**，供应用层调用。
  /// `aliplayer_widget` 内部组件请使用 `PlayerI18n.t()`。
  ///
  /// **Public API** for application layer.
  /// Internal `aliplayer_widget` components should use `PlayerI18n.t()`.
  ///
  /// [key] 翻译键，支持嵌套格式（如 'player.settings.volume'）
  /// [args] 可选参数，用于插值替换
  ///
  /// ## 示例 / Example
  /// ```dart
  /// // 基础使用 / Basic usage
  /// final text = AliPlayerWidgetGlobalSetting.t('player.settings.volume');
  ///
  /// // 带参数插值 / With parameter interpolation
  /// final speedText = AliPlayerWidgetGlobalSetting.t(
  ///   'player.speed.format',
  ///   {'speed': '1.5'},
  /// );
  /// ```
  static String t(String key, [Map<String, dynamic>? args]) {
    return PlayerI18n.t(key, args);
  }

  /// 初始化国际化
  ///
  /// Initialize internationalization.
  ///
  /// [locale] 初始语言，为空时自动跟随系统语言
  /// Initial locale, auto-syncs with system locale when null.
  ///
  /// ## 示例 / Example
  /// ```dart
  /// // 自动跟随系统语言
  /// AliPlayerWidgetGlobalSetting.initI18n();
  ///
  /// // 手动指定语言
  /// AliPlayerWidgetGlobalSetting.initI18n(const Locale('en'));
  /// ```
  static void initI18n([Locale? locale]) {
    PlayerI18n.initialize(locale);
  }

  /// 设置当前语言
  ///
  /// Set current locale.
  ///
  /// 用于运行时切换语言，UI 会自动刷新。
  /// Used for runtime language switching, UI will auto-refresh.
  static void setLocale(Locale locale) {
    PlayerI18n.setLocale(locale);
  }

  /// 获取当前语言
  ///
  /// Get current locale.
  static Locale get locale => PlayerI18n.locale;

  /// 语言变化监听器
  ///
  /// Locale change notifier.
  ///
  /// 用于监听语言变化，配合 ValueListenableBuilder 实现响应式 UI。
  /// Used to listen for locale changes, works with ValueListenableBuilder for reactive UI.
  static ValueNotifier<Locale> get localeNotifier => PlayerI18n.localeNotifier;

  /// 获取系统语言
  ///
  /// Get system locale.
  static Locale? get systemLocale => PlayerI18n.systemLocale;

  /// 获取支持的语言列表
  ///
  /// Get supported locales list.
  static List<Locale> get supportedLocales => PlayerI18n.supportedLocales;

  /// 检查语言是否支持
  ///
  /// Check if locale is supported.
  static bool isLocaleSupported(Locale locale) {
    return PlayerI18n.isLocaleSupported(locale);
  }

  /// 注册外部语言包
  ///
  /// Register external language pack.
  ///
  /// 用于添加新的语言支持，如日语、韩语等。
  /// Used to add new language support, such as Japanese, Korean, etc.
  ///
  /// ## 示例 / Example
  /// ```dart
  /// AliPlayerWidgetGlobalSetting.registerTranslations(PlayerTranslationsKo());
  /// AliPlayerWidgetGlobalSetting.setLocale(const Locale('ko'));
  /// ```
  static void registerTranslations(PlayerTranslations translations) {
    PlayerI18n.registerTranslations(translations);
  }

  /// 批量注册外部语言包
  ///
  /// Register multiple external language packs.
  static void registerAllTranslations(
    List<PlayerTranslations> translationsList,
  ) {
    PlayerI18n.registerAllTranslations(translationsList);
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
  ///
  /// ## 示例 / Example
  /// ```dart
  /// AliPlayerWidgetGlobalSetting.overrideTranslations('zh', {
  ///   'player': {
  ///     'settings': {
  ///       'volume': '音量',
  ///     },
  ///   },
  /// });
  /// ```
  static void overrideTranslations(
    String langCode,
    Map<String, dynamic> overrides,
  ) {
    PlayerI18n.overrideTranslations(langCode, overrides);
  }

  /// 更新为系统语言
  ///
  /// Update to system locale.
  ///
  /// 当系统语言发生变化时调用，用于重新同步语言设置。
  /// Called when system locale changes, used to re-sync language settings.
  static void updateFromSystemLocale() {
    PlayerI18n.updateFromSystemLocale();
  }
}
