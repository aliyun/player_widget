// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: wyq
// Date: 2025/2/10
// Brief: 下载状态模型

// 下载状态基类
abstract class DownloadState {
  const DownloadState();
}

/// 未知状态
class UnknownState extends DownloadState {
  const UnknownState();
}

/// 下载中状态
class DownloadingState extends DownloadState {
  final int progress;

  const DownloadingState({required this.progress});
}

/// 下载完成状态
class DownloadCompletedState extends DownloadState {
  final String downloadFile;

  const DownloadCompletedState({required this.downloadFile});
}

/// 下载异常状态
class DownloadErrorState extends DownloadState {
  final String errorCode;
  final String errorMessage;

  const DownloadErrorState({
    required this.errorCode,
    required this.errorMessage,
  });
}
