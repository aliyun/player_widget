// Copyright © 2026 Alibaba Cloud. All rights reserved.
//
// Author: wyq
// Date: 2026/5/21
// Brief: Download manager for AliPlayerWidget

part of 'package:aliplayer_widget/aliplayer_widget_lib.dart';

/// 视频下载管理器
///
/// 封装下载器生命周期、进度监听和状态通知，与 Controller 通过构造参数解耦。
class DownloadManager {
  static const _logTag = "DownloadManager";

  late FlutterAliDownloader _downloader;
  StreamSubscription? _subscription;

  /// 下载保存路径
  String? savePath = FileManager.getFolderPath(FolderType.download);

  /// 当前下载状态
  final SafeValueNotifier<DownloadState> stateNotifier =
      SafeValueNotifier(const UnknownState());

  final SafeValueNotifier<AVPTrackInfo?> _currentTrackInfoNotifier;
  final AliPlayerWidgetData? Function() _widgetDataGetter;
  final void Function(String) _showSuccess;
  final void Function(String) _showInfo;
  final void Function(String) _showError;

  DownloadManager({
    required SafeValueNotifier<AVPTrackInfo?> currentTrackInfoNotifier,
    required AliPlayerWidgetData? Function() widgetDataGetter,
    required void Function(String) showSuccess,
    required void Function(String) showInfo,
    required void Function(String) showError,
  })  : _currentTrackInfoNotifier = currentTrackInfoNotifier,
        _widgetDataGetter = widgetDataGetter,
        _showSuccess = showSuccess,
        _showInfo = showInfo,
        _showError = showError {
    _downloader = FlutterAliDownloader.init();
  }

  /// 启动视频下载流程
  void startVideoDownload() {
    // 没有数据源
    if (_widgetDataGetter() == null) {
      logw(
        "Download skipped: player not configured. "
        "Call configure() before startVideoDownload().",
        tag: _logTag,
      );
      return;
    }

    // 没有设置保存路径
    if (savePath == null || savePath!.isEmpty) {
      _showError(PlayerI18n.t(PlayerI18nKeys.downloadStoragePathNotSet));
      return;
    }

    final currentState = stateNotifier.value;
    if (currentState is DownloadCompletedState) {
      _showSuccess(
        PlayerI18n.t(
          PlayerI18nKeys.downloadAlreadySaved,
          {"path": currentState.downloadFile},
        ),
      );
      return;
    }
    if (currentState is DownloadingState) {
      _showInfo(
        PlayerI18n.t(
          PlayerI18nKeys.downloadProgress,
          {"progress": currentState.progress},
        ),
      );
      return;
    }

    _downloader.setSaveDir(savePath!);

    final prepared = _prepareDownload();
    if (prepared == null) {
      stateNotifier.value = const DownloadErrorState(
        errorCode: "SOURCE_TYPE_UNSUPPORTED",
        errorMessage: "Download only supports VidSts or VidAuth source. "
            "UrlSource does not provide vid for download. "
            "Please switch to VidSts/VidAuth video source.",
      );
      return;
    }

    final (vid, downloadAction) = prepared;
    downloadAction.then((value) {
      _showInfo(PlayerI18n.t(PlayerI18nKeys.downloadStart));
      _executeDownloadWithMediaInfo(vid, value);
    }).catchError((error, stack) {
      _handleDownloadError(error);
    });
  }

  (String, Future<dynamic>)? _prepareDownload() {
    final source = _widgetDataGetter()?.videoSource;
    if (source is VidStsVideoSource) {
      return (
        source.vid,
        _downloader.prepare(
          FlutterAvpdef.DOWNLOADTYPE_STS,
          source.vid,
          accessKeyId: source.accessKeyId,
          accessKeySecret: source.accessKeySecret,
          securityToken: source.securityToken,
        ),
      );
    }
    if (source is VidAuthVideoSource) {
      return (
        source.vid,
        _downloader.prepare(
          FlutterAvpdef.DOWNLOADTYPE_AUTH,
          source.vid,
          playAuth: source.playAuth,
        ),
      );
    }
    return null;
  }

  void _handleDownloadError(dynamic error) {
    if (error is PlatformException) {
      stateNotifier.value = DownloadErrorState(
        errorCode: "PREPARE_SDK_${error.code}",
        errorMessage: error.message ??
            'SDK prepare failed. '
                'Check network connectivity, STS/Auth token validity, '
                'and vid correctness.',
      );
    } else {
      stateNotifier.value = DownloadErrorState(
        errorCode: "PREPARE_UNEXPECTED",
        errorMessage: '${error?.toString() ?? 'Unknown error'}. '
            'This is an unexpected Dart-layer exception during download '
            'prepare. Check stack trace in logs for details.',
      );
    }
  }

  void _executeDownloadWithMediaInfo(String vid, dynamic mediaInfoValue) {
    int selectVideoIndex = 0;
    if (null != _currentTrackInfoNotifier.value) {
      selectVideoIndex = _currentTrackInfoNotifier.value!.trackIndex ?? 0;
    } else {
      Map<String, dynamic> jsonMap = json.decode(mediaInfoValue);
      AliMediaInfo info = AliMediaInfo.fromJson(jsonMap);
      if (null != info.trackInfos && info.trackInfos!.isNotEmpty) {
        selectVideoIndex = info.trackInfos![0].index ?? 0;
      }
    }
    _downloader.selectItem(vid, selectVideoIndex);

    _subscription?.cancel();
    _subscription = _downloader.start(vid, selectVideoIndex)!.listen(
      (event) {
        // 事件解析涉及类型转换与 int.parse，可能抛出异常；
        // 统一在此兜底，避免异常逃逸到 zone 导致下载状态卡死。
        try {
          final map = Map<String, dynamic>.from(event as Map);
          String downloadEvent = map[EventChanneldef.TYPE_KEY] as String;
          if (downloadEvent == DownloadEvent.DOWNLOAD_PROGRESS) {
            String progress = map[EventChanneldef.DOWNLOAD_PROGRESS] as String;
            stateNotifier.value = DownloadingState(
              progress: int.parse(progress),
            );
          } else if (downloadEvent == DownloadEvent.DOWNLOAD_COMPLETION) {
            String fileSavePath = map['savePath'] as String;
            stateNotifier.value = DownloadCompletedState(
              downloadFile: fileSavePath,
            );
            _showSuccess(
              PlayerI18n.t(
                PlayerI18nKeys.downloadAlreadySaved,
                {"path": fileSavePath},
              ),
            );
            _subscription?.cancel();
            _subscription = null;
          } else if (downloadEvent == DownloadEvent.DOWNLOAD_ERROR) {
            final errorCode = 'TRANSFER_${map['errorCode'] ?? 'UNKNOWN'}';
            final rawErrorMessage = map['errorMsg']?.toString().trim();
            final errorMessage = rawErrorMessage?.isNotEmpty == true
                ? rawErrorMessage!
                : 'Download transfer failed. '
                    'Check storage space, file permissions, and network stability.';
            stateNotifier.value = DownloadErrorState(
              errorCode: errorCode,
              errorMessage: errorMessage,
            );
            _showError(errorMessage);
            _subscription?.cancel();
            _subscription = null;
          }
        } catch (error, stack) {
          _handleDownloadStreamError(error, stack);
        }
      },
      onError: (Object error, StackTrace stack) {
        _handleDownloadStreamError(error, stack);
      },
    );
  }

  /// 处理下载事件流的异常（事件解析异常或流层错误）
  ///
  /// 统一记录日志、更新错误状态、提示用户并释放订阅，
  /// 避免异常导致下载状态停留在 [DownloadingState] 无法恢复。
  void _handleDownloadStreamError(Object error, StackTrace stack) {
    loge(
      "Download stream error: $error\n$stack",
      tag: _logTag,
    );
    stateNotifier.value = DownloadErrorState(
      errorCode: "STREAM_EXCEPTION",
      errorMessage: '${error.toString()}. '
          'Unexpected exception while handling download events. '
          'Check logs for stack trace.',
    );
    _showError(PlayerI18n.t(PlayerI18nKeys.downloadFailed));
    _subscription?.cancel();
    _subscription = null;
  }

  /// 释放下载器资源
  void destroy() {
    _subscription?.cancel();
    _subscription = null;

    int selectVideoIndex = 0;
    if (null != _currentTrackInfoNotifier.value) {
      selectVideoIndex = _currentTrackInfoNotifier.value!.trackIndex ?? 0;
    }

    final source = _widgetDataGetter()?.videoSource;
    if (source is VidStsVideoSource) {
      _downloader.release(source.vid, selectVideoIndex);
    } else if (source is VidAuthVideoSource) {
      _downloader.release(source.vid, selectVideoIndex);
    }

    stateNotifier.dispose();
  }
}
