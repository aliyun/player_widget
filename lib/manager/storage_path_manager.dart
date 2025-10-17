// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/14
// Brief: AliPlayerWidget Storage Manager

import 'dart:io';

import 'package:aliplayer_widget/utils/log_util.dart';

/// 存储类型枚举
enum StorageType {
  /// 缓存存储 - 用于临时文件，系统可能会清理
  /// Android: cache directory
  /// iOS: Library/Caches
  cache,

  /// 文件存储 - 用于持久化文件
  /// Android: files directory
  /// iOS: Documents
  files,
}

/// 存储路径配置
class StorageConfig {
  /// 缓存存储路径
  final String? cachePath;

  /// 文件存储路径
  final String? filesPath;

  const StorageConfig({
    this.cachePath,
    this.filesPath,
  });

  /// 根据存储类型获取对应路径
  String? getPath(StorageType type) {
    switch (type) {
      case StorageType.cache:
        return cachePath;
      case StorageType.files:
        return filesPath;
    }
  }

  /// 获取默认路径（优先使用缓存路径）
  String? get defaultPath => cachePath ?? filesPath;

  /// 检查是否有任何路径被设置
  bool get hasAnyPath => cachePath != null || filesPath != null;

  /// 复制并更新配置
  StorageConfig copyWith({
    String? cachePath,
    String? filesPath,
  }) {
    return StorageConfig(
      cachePath: cachePath ?? this.cachePath,
      filesPath: filesPath ?? this.filesPath,
    );
  }

  @override
  String toString() {
    return 'StorageConfig{cachePath: $cachePath, filesPath: $filesPath}';
  }
}

/// AliPlayer 存储管理器
class StorageManager {
  /// cache directory name
  ///
  /// 存储文件相对目录
  static const String _defaultStorageDirectoryName = 'aliplayer_widget';

  // 私有构造函数，防止实例化
  StorageManager._();

  /// 存储路径配置
  static StorageConfig? _storageConfig;

  /// 默认使用的存储类型
  static StorageType _defaultStorageType = StorageType.files;

  /// 处理路径：拼接子目录并创建目录
  static String? _processPath(String? basePath) {
    if (basePath == null) {
      loge('_processPath: basePath is null, returning null');
      return null;
    }

    final fullPath = "$basePath/$_defaultStorageDirectoryName";

    try {
      final directory = Directory(fullPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
    } catch (e, stack) {
      loge('Failed to create directory at $fullPath: $e\n$stack');
      // 创建失败时仍返回路径，由上层决定是否使用
    }

    return fullPath;
  }

  /// Set storage configuration
  ///
  /// 设置存储配置
  ///
  /// [config] 存储路径配置
  static void setStorageConfig(StorageConfig config) {
    _storageConfig = StorageConfig(
      cachePath: _processPath(config.cachePath),
      filesPath: _processPath(config.filesPath),
    );
    logi('Updated _storageConfig to: $_storageConfig');
  }

  /// Set storage paths
  static void setStoragePaths({
    String? cachePath,
    String? filesPath,
  }) {
    _storageConfig = StorageConfig(
      cachePath: _processPath(cachePath),
      filesPath: _processPath(filesPath),
    );
    logi('Updated _storageConfig to: $_storageConfig');
  }

  /// Set cache path
  static void setCachePath(String path) {
    _storageConfig = (_storageConfig ?? const StorageConfig()).copyWith(
      cachePath: _processPath(path),
    );
    logi('Updated cachePath to: ${_storageConfig?.cachePath}');
  }

  /// Set files path
  static void setFilesPath(String path) {
    loge('setFilesPath called with: $path');
    _storageConfig = (_storageConfig ?? const StorageConfig()).copyWith(
      filesPath: _processPath(path),
    );
    logi('Updated filesPath to: ${_storageConfig?.filesPath}');
  }

  /// Set default storage type
  ///
  /// 设置默认存储类型
  ///
  /// [type] 存储类型
  static void setDefaultStorageType(StorageType type) {
    _defaultStorageType = type;
  }

  /// Get current storage configuration
  ///
  /// 获取当前存储配置
  static StorageConfig? get storageConfig => _storageConfig;

  /// Get cache path (已包含子目录)
  ///
  /// 获取缓存路径
  static String? get cachePath => _storageConfig?.cachePath;

  /// Get files path (已包含子目录)
  ///
  /// 获取文件路径
  static String? get filesPath => _storageConfig?.filesPath;

  /// Get default storage type
  ///
  /// 获取默认存储类型
  static StorageType get defaultStorageType => _defaultStorageType;

  /// Get base path by storage type (已包含子目录)
  ///
  /// 根据存储类型获取基础路径
  ///
  /// [type] 存储类型，如果为null则使用默认类型
  static String? getBasePath([StorageType? type]) {
    if (_storageConfig == null) {
      loge('getBasePath: _storageConfig is null');
      return null;
    }

    final targetType = type ?? _defaultStorageType;
    final path = _storageConfig!.getPath(targetType);

    if (path != null) {
      logi('getBasePath: type=$targetType, path=$path');
      return path;
    }

    // 回退到默认路径
    final fallback = _storageConfig!.defaultPath;
    logw('getBasePath: no path for $targetType, falling back to: $fallback');
    return fallback;
  }

  /// Get full path with subdirectory (alias for getBasePath)
  ///
  /// 获取包含子目录的完整路径
  ///
  /// [type] 存储类型，如果为null则使用默认类型
  static String? getFullPath([StorageType? type]) {
    return getBasePath(type);
  }

  /// Check if storage is configured
  ///
  /// 检查存储是否已配置
  static bool get isConfigured => _storageConfig?.hasAnyPath ?? false;

  /// Validate storage configuration
  ///
  /// 验证存储配置
  ///
  /// [type] 要验证的存储类型，如果为null则验证默认类型
  ///
  /// 返回验证结果和错误信息
  static (bool isValid, String? errorMessage) validateStorage(
      [StorageType? type]) {
    if (_storageConfig == null) {
      const msg = 'Storage configuration is not set';
      loge('validateStorage failed: $msg');
      return (false, msg);
    }

    final targetType = type ?? _defaultStorageType;
    final basePath = getBasePath(targetType);

    if (basePath == null || basePath.isEmpty) {
      final msg = 'Storage path for type $targetType is not set';
      loge('validateStorage failed: $msg');
      return (false, msg);
    }

    return (true, null);
  }
}
