// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/14
// Brief: AliPlayer Widget 全局配置

part of 'aliplayer_widget_lib.dart';

/// AliPlayer Widget Global Setting
///
/// AliPlayer Widget 全局配置
class AliPlayerWidgetGlobalSetting {
  /// Flutter Widget version
  ///
  /// Flutter Widget 版本号
  static const String kWidgetVersion = '7.3.0';

  /// extra data for global settings
  ///
  /// 业务场景信息的 JSON 字符串
  static const String _extraData =
      "{\"scene\":\"flutter-widget\", \"version\":\"$kWidgetVersion\"}";

  /// cache directory name
  ///
  /// 缓存相对目录
  static const String _cacheDirectoryName = 'aliplayer_widget';

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
  }

  /// Setup extra data for global settings.
  ///
  /// 配置全局缓存设置的额外数据
  static void _setupExtraData() {
    // 设置业务标识
    FlutterAliPlayerGlobalSettings.setOption(
      AliPlayerGlobalSettings.SET_EXTRA_DATA,
      _extraData,
    );
  }

  /// Setup media loader config.
  ///
  /// 设置播放器预加载配置
  static void setupMediaLoaderConfig(String fullPath) {
    String localCacheDir = "$fullPath/$_cacheDirectoryName";

    // FIXME keria: Why do int values need to be passed as strings??? Niubility..
    // 设置本地缓存配置
    FlutterAliplayer.enableLocalCache(
      _enableLocalCache,
      "$_localCacheMaxBufferMemoryKB",
      localCacheDir,
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
}
