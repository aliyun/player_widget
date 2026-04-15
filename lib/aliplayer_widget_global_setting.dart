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
  static const String kWidgetVersion = '7.12.2';

  /// extra data for global settings
  /// 业务场景信息的 JSON 字符串
  ///
  /// used by AliPlayerWidget for capability recognition, please do not override
  /// 用于 AliPlayerWidget 能力识别，请勿覆盖
  static const String _extraData =
      "{\"scene\":\"flutter-widget\", \"version\":\"$kWidgetVersion\"}";

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

    // 调用客户自定义全局配置回调
    _onGlobalInitCallback?.call();
  }

  /// Setup extra data for global settings.
  ///
  /// 配置全局缓存设置的额外数据
  static void _setupExtraData() {
    // 设置业务标识（用于 AliPlayerWidget 能力识别，请勿覆盖）
    FlutterAliPlayerGlobalSettings.setOption(
      AliPlayerGlobalSettings.SET_EXTRA_DATA,
      _extraData,
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

  /// Setup media loader config.
  ///
  /// 设置播放器预加载配置
  ///
  /// [localCacheDir] 本地缓存目录，如果为null则使用默认路径
  ///
  /// @deprecated 此方法已废弃，请使用 [setStoragePaths] 方法，它会自动配置媒体加载器
  @Deprecated(
      'Use setStoragePaths() instead, which automatically configures the media loader')
  static void setupMediaLoaderConfig([String? localCacheDir]) {
    _setupMediaLoaderConfig(localCacheDir);
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
}
