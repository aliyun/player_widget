// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/10/11
// Brief: File Manager for AliPlayerWidget

import 'package:aliplayer_widget/manager/storage_path_manager.dart';
import 'package:aliplayer_widget/utils/file_util.dart';
import 'package:aliplayer_widget/utils/log_util.dart';

/// 文件夹类型枚举，用于标识不同用途的本地存储目录。
///
/// Enum representing folder types for different purposes of local storage.
enum FolderType {
  /// 截图文件夹
  ///
  /// Folder for screenshots
  snapshot('Snapshot'),

  /// 下载文件夹
  ///
  /// Folder for downloads
  download('Download'),

  /// 预加载文件夹
  ///
  /// Folder for preload
  preload('Preload'),

  /// 日志文件夹
  ///
  /// Folder for logs
  logs('Logs'),
  ;

  const FolderType(
    this.folderName,
  );

  /// 文件夹名称
  final String folderName;
}

/// 文件管理器，提供统一的本地文件目录管理能力，包括路径获取、创建、清理和删除等操作。
///
/// A file manager that provides unified local directory management capabilities, including path retrieval, creation, clearing, and deletion.
class FileManager {
  // 私有构造函数，防止实例化
  FileManager._();

  // 文件夹路径缓存
  static final Map<FolderType, String> _folderCache = {};

  /// 获取指定类型的文件夹路径（带缓存）
  ///
  /// Gets the folder path for the specified type (with caching).
  static String? getFolderPath(FolderType type, [StorageType? storageType]) {
    // 先检查缓存
    if (_folderCache.containsKey(type)) {
      return _folderCache[type];
    }

    final basePath = StorageManager.getBasePath(storageType);
    if (basePath == null) {
      loge('getFolderPath: base path is null for $type');
      return null;
    }

    final folderPath = '$basePath/${type.folderName}';

    // 尝试创建文件夹
    final result = FileUtil.createDirectory(folderPath);
    if (result.success) {
      _folderCache[type] = folderPath;
      return folderPath;
    } else {
      loge('Failed to create folder $folderPath: ${result.error}');
      return null;
    }
  }

  /// 根据文件夹类型和文件名获取完整文件路径
  ///
  /// Gets the full file path based on folder type and file name.
  static String? getFilePath(FolderType type, String fileName,
      [StorageType? storageType]) {
    final folderPath = getFolderPath(type, storageType);
    if (folderPath == null) {
      loge('getFilePath: folder path is null for $type');
      return null;
    }

    return '$folderPath/$fileName';
  }

  /// 确保指定类型的文件夹存在，若不存在则尝试创建
  ///
  /// Ensures the folder of the specified type exists; creates it if it doesn't.
  static FileResult<String> ensureFolder(FolderType type,
      [StorageType? storageType]) {
    final folderPath = getFolderPath(type, storageType);
    if (folderPath == null) {
      return const FileResult.failure('Failed to get or create folder path');
    }

    return FileResult.success(folderPath);
  }

  /// 清空指定类型的文件夹内容（不删除文件夹本身）
  ///
  /// Clears the contents of the specified folder (without deleting the folder itself).
  static FileResult<void> clearFolder(FolderType type,
      [StorageType? storageType]) {
    final folderPath = getFolderPath(type, storageType);
    if (folderPath == null) {
      return const FileResult.failure('Folder path not found');
    }

    return FileUtil.clearDirectory(folderPath);
  }

  /// 删除指定类型的文件夹及其所有内容
  ///
  /// Deletes the specified folder and all its contents.
  static FileResult<void> deleteFolder(FolderType type,
      [StorageType? storageType]) {
    final folderPath = getFolderPath(type, storageType);
    if (folderPath == null) {
      return const FileResult.failure('Folder path not found');
    }

    final result = FileUtil.deleteDirectory(folderPath, recursive: true);
    if (result.success) {
      _folderCache.remove(type);
    }

    return result;
  }

  /// 清理缓存文件（目前仅清理预加载文件夹）
  ///
  /// Clears cache files (currently only clears the preload folder).
  static FileResult<Map<FolderType, bool>> clearCache() {
    final Map<FolderType, bool> results = {};
    final List<String> errors = [];

    final result = clearFolder(FolderType.preload);
    results[FolderType.preload] = result.success;
    if (!result.success) {
      errors.add('Preload: ${result.error}');
    }

    if (errors.isNotEmpty) {
      logw('Some cache clearing operations failed: ${errors.join(', ')}');
      return FileResult.failure(errors.join(', '));
    }

    return FileResult.success(results);
  }

  /// 初始化所有预定义类型的文件夹
  ///
  /// Initializes all predefined folder types.
  static FileResult<Map<FolderType, String>> initializeAllFolders(
      [StorageType? storageType]) {
    final Map<FolderType, String> results = {};
    final List<String> errors = [];

    for (final type in FolderType.values) {
      final folderPath = getFolderPath(type, storageType);
      if (folderPath != null) {
        results[type] = folderPath;
      } else {
        errors.add('Failed to initialize ${type.folderName}');
      }
    }

    if (errors.isNotEmpty) {
      return FileResult.failure(errors.join(', '));
    }

    return FileResult.success(results);
  }

  // 便捷方法 - 截图相关

  /// 获取截图文件夹路径
  ///
  /// Gets the snapshot folder path.
  static String? get snapshotPath => getFolderPath(FolderType.snapshot);

  /// 获取截图文件的完整路径
  ///
  /// Gets the full path of a snapshot file.
  static String? getSnapshotFilePath(String fileName) =>
      getFilePath(FolderType.snapshot, fileName);

  // 便捷方法 - 下载相关

  /// 获取下载文件夹路径
  ///
  /// Gets the download folder path.
  static String? get downloadPath => getFolderPath(FolderType.download);

  /// 获取下载文件的完整路径
  ///
  /// Gets the full path of a downloaded file.
  static String? getDownloadFilePath(String fileName) =>
      getFilePath(FolderType.download, fileName);

  // 便捷方法 - 预加载相关

  /// 获取预加载文件夹路径
  ///
  /// Gets the preload folder path.
  static String? get preloadPath => getFolderPath(FolderType.preload);

  /// 获取预加载文件的完整路径
  ///
  /// Gets the full path of a preload file.
  static String? getPreloadFilePath(String fileName) =>
      getFilePath(FolderType.preload, fileName);

  // 便捷方法 - 日志相关

  /// 获取日志文件夹路径
  ///
  /// Gets the logs folder path.
  static String? get logsPath => getFolderPath(FolderType.logs);

  /// 获取日志文件的完整路径
  ///
  /// Gets the full path of a log file.
  static String? getLogFilePath(String fileName) =>
      getFilePath(FolderType.logs, fileName);
}
