// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/10/11
// Brief: File Utility Functions

import 'dart:io';

import 'log_util.dart';

/// 文件操作结果封装类
///
/// A wrapper class for file operation results
class FileResult<T> {
  final bool success;
  final T? data;
  final String? error;

  const FileResult.success(this.data)
      : success = true,
        error = null;

  const FileResult.failure(this.error)
      : success = false,
        data = null;
}

/// 文件工具类
///
/// File utility class
class FileUtil {
  // 私有构造函数，防止实例化
  FileUtil._();

  /// 创建目录（若不存在）
  ///
  /// Creates a directory if it does not exist
  static FileResult<Directory> createDirectory(String path) {
    try {
      final directory = Directory(path);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      return FileResult.success(directory);
    } catch (e, stack) {
      loge('Failed to create directory $path: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 删除目录
  ///
  /// Deletes a directory
  static FileResult<void> deleteDirectory(String path,
      {bool recursive = false}) {
    try {
      final directory = Directory(path);
      if (directory.existsSync()) {
        directory.deleteSync(recursive: recursive);
      }
      return const FileResult.success(null);
    } catch (e, stack) {
      loge('Failed to delete directory $path: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 创建文件
  ///
  /// Creates a file
  static FileResult<File> createFile(String path, {String? content}) {
    try {
      final file = File(path);
      // 确保父目录存在
      final parentDir = file.parent;
      if (!parentDir.existsSync()) {
        parentDir.createSync(recursive: true);
      }

      if (content != null) {
        file.writeAsStringSync(content);
      } else if (!file.existsSync()) {
        file.createSync();
      }

      return FileResult.success(file);
    } catch (e, stack) {
      loge('Failed to create file $path: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 删除文件
  ///
  /// Deletes a file
  static FileResult<void> deleteFile(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
      return const FileResult.success(null);
    } catch (e, stack) {
      loge('Failed to delete file $path: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 复制文件
  ///
  /// Copies a file
  static FileResult<File> copyFile(String sourcePath, String targetPath) {
    try {
      final sourceFile = File(sourcePath);
      if (!sourceFile.existsSync()) {
        return const FileResult.failure('Source file does not exist');
      }

      final targetFile = File(targetPath);
      // 确保目标目录存在
      final targetDir = targetFile.parent;
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final copiedFile = sourceFile.copySync(targetPath);
      return FileResult.success(copiedFile);
    } catch (e, stack) {
      loge('Failed to copy file from $sourcePath to $targetPath: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 移动文件
  ///
  /// Moves a file
  static FileResult<File> moveFile(String sourcePath, String targetPath) {
    try {
      final sourceFile = File(sourcePath);
      if (!sourceFile.existsSync()) {
        return const FileResult.failure('Source file does not exist');
      }

      final targetFile = File(targetPath);
      // 确保目标目录存在
      final targetDir = targetFile.parent;
      if (!targetDir.existsSync()) {
        targetDir.createSync(recursive: true);
      }

      final movedFile = sourceFile.renameSync(targetPath);
      return FileResult.success(movedFile);
    } catch (e, stack) {
      loge('Failed to move file from $sourcePath to $targetPath: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 检查文件或目录是否存在
  ///
  /// Check if file or directory exists
  static bool exists(String path) {
    return File(path).existsSync() || Directory(path).existsSync();
  }

  /// 获取文件大小
  ///
  /// Gets the file size
  static FileResult<int> getFileSize(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return const FileResult.failure('File does not exist');
      }
      return FileResult.success(file.lengthSync());
    } catch (e, stack) {
      loge('Failed to get file size for $path: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 获取目录大小
  ///
  /// Gets the directory size
  static FileResult<int> getDirectorySize(String path) {
    try {
      final directory = Directory(path);
      if (!directory.existsSync()) {
        return const FileResult.failure('Directory does not exist');
      }

      int totalSize = 0;
      final entities = directory.listSync(recursive: true);

      for (final entity in entities) {
        if (entity is File) {
          totalSize += entity.lengthSync();
        }
      }

      return FileResult.success(totalSize);
    } catch (e, stack) {
      loge('Failed to get directory size for $path: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 列出目录内容
  ///
  /// Lists directory contents
  static FileResult<List<FileSystemEntity>> listDirectory(String path,
      {bool recursive = false}) {
    try {
      final directory = Directory(path);
      if (!directory.existsSync()) {
        return const FileResult.failure('Directory does not exist');
      }

      final entities = directory.listSync(recursive: recursive);
      return FileResult.success(entities);
    } catch (e, stack) {
      loge('Failed to list directory $path: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 清空目录内容
  ///
  /// Clears the contents of a directory
  static FileResult<void> clearDirectory(String path) {
    try {
      final directory = Directory(path);
      if (!directory.existsSync()) {
        return const FileResult.success(null);
      }

      final entities = directory.listSync();
      for (final entity in entities) {
        if (entity is File) {
          entity.deleteSync();
        } else if (entity is Directory) {
          entity.deleteSync(recursive: true);
        }
      }

      return const FileResult.success(null);
    } catch (e, stack) {
      loge('Failed to clear directory $path: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 读取文件内容
  ///
  /// Reads the content of a file
  static FileResult<String> readFile(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return const FileResult.failure('File does not exist');
      }

      final content = file.readAsStringSync();
      return FileResult.success(content);
    } catch (e, stack) {
      loge('Failed to read file $path: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }

  /// 写入文件内容
  ///
  /// Writes content to a file
  static FileResult<File> writeFile(String path, String content) {
    try {
      final file = File(path);
      // 确保父目录存在
      final parentDir = file.parent;
      if (!parentDir.existsSync()) {
        parentDir.createSync(recursive: true);
      }

      file.writeAsStringSync(content);
      return FileResult.success(file);
    } catch (e, stack) {
      loge('Failed to write file $path: $e\n$stack');
      return FileResult.failure(e.toString());
    }
  }
}
