// Copyright © 2025 Alibaba Cloud. All rights reserved.
//
// Author: keria
// Date: 2025/2/10
// Brief: Player widget controller, used to manage the initialization, playback, and destruction logic of Alibaba Cloud Player

part of 'aliplayer_widget_lib.dart';

/// 播放器组件控制器，用于管理阿里云播放器的初始化、播放和销毁逻辑
///
/// Player widget controller, used to manage the initialization, playback,
/// and destruction logic of Alibaba Cloud Player
class AliPlayerWidgetController {
  /// 日志标签
  static const _logTag = "AliPlayerWidgetController";

  final BuildContext _context;

  /// 播放器实例
  late FlutterAliplayer _aliPlayer;

  /// 下载器实例
  late FlutterAliDownloader _aliDownloader;

  /// 管理流订阅
  late StreamSubscription _subscription;

  /// 下载保存路径
  String? downloadSavePath = FileManager.getFolderPath(FolderType.download);

  /// 播放器唯一标识符
  late String _playerUniqueId;

  /// 是否已准备播放
  bool _isPrepared = false;

  /// 播放数据源准备开始时间
  int _prepareStartTime = 0;

  /// 外挂字幕
  late Subtitles subtitles;

  final Map<int, Subtitle> _activeSubtitles = {};

  /// 获取字幕配置
  SubtitleConfig get subtitleConfig =>
      _widgetData?.subtitleConfig ?? const SubtitleConfig();

  /// 获取字幕构建器
  SubtitleBuilder? get subtitleBuilder => _widgetData?.subtitleBuilder;

  /// 渲染状态变化通知器
  ///
  /// Value notifier for rendering status
  final SafeValueNotifier<bool> isRenderedNotifier = SafeValueNotifier(false);

  /// 视频尺寸变化通知器
  ///
  /// Value notifier for video size
  final SafeValueNotifier<Size> videoSizeNotifier =
      SafeValueNotifier(Size.zero);

  /// 播放状态变化通知器
  ///
  /// Value notifier for playback status
  final SafeValueNotifier<int> playStateNotifier =
      SafeValueNotifier(FlutterAvpdef.unknow);

  /// 播放错误信息变化通知器
  ///
  /// Value notifier for playback error
  final SafeValueNotifier<Map<int?, String?>?> playErrorNotifier =
      SafeValueNotifier(null);

  /// 播放进度变化通知器
  ///
  /// Value notifier for current position
  final SafeValueNotifier<Duration> currentPositionNotifier =
      SafeValueNotifier(Duration.zero);

  /// 播放缓冲进度变化通知器
  ///
  /// Value notifier for buffered position
  final SafeValueNotifier<Duration> bufferedPositionNotifier =
      SafeValueNotifier(Duration.zero);

  /// 播放总时长变化通知器
  ///
  /// Value notifier for total duration
  final SafeValueNotifier<Duration> totalDurationNotifier =
      SafeValueNotifier(Duration.zero);

  /// 播放亮度变化通知器
  ///
  /// Value notifier for brightness
  final SafeValueNotifier<double> brightnessNotifier =
      SafeValueNotifier(SettingConstants.defaultBrightness);

  /// 播放音量变化通知器
  ///
  /// Value notifier for volume
  final SafeValueNotifier<double> volumeNotifier =
      SafeValueNotifier(SettingConstants.defaultVolume);

  /// 播放速度变化通知器
  ///
  /// Value notifier for speed
  final SafeValueNotifier<double> speedNotifier =
      SafeValueNotifier(SettingConstants.defaultSpeed);

  /// 循环播放变化通知器
  ///
  /// Value notifier for loop playback
  final SafeValueNotifier<bool> isLoopNotifier =
      SafeValueNotifier(SettingConstants.defaultIsLoop);

  /// 静音播放变化通知器
  ///
  /// Value notifier for mute playback
  final SafeValueNotifier<bool> isMuteNotifier =
      SafeValueNotifier(SettingConstants.defaultIsMute);

  /// 镜像模式变化通知器
  ///
  /// Value notifier for mirror mode
  final SafeValueNotifier<int> mirrorModeNotifier =
      SafeValueNotifier(SettingConstants.defaultMirrorMode);

  /// 旋转角度变化通知器
  ///
  /// Value notifier for rotate mode
  final SafeValueNotifier<int> rotateModeNotifier =
      SafeValueNotifier(SettingConstants.defaultRotateMode);

  /// 渲染模式变化通知器
  ///
  /// Value notifier for render mode
  final SafeValueNotifier<int> scaleModeNotifier =
      SafeValueNotifier(SettingConstants.defaultScaleMode);

  /// 播放清晰度变化通知器
  ///
  /// Value notifier for track info
  final SafeValueNotifier<AVPTrackInfo?> currentTrackInfoNotifier =
      SafeValueNotifier(null);

  /// 播放清晰度信息列表变化通知器
  ///
  /// Value notifier for track info list
  final SafeValueNotifier<List<AVPTrackInfo>?> trackInfoListNotifier =
      SafeValueNotifier(null);

  /// 缩略图变化通知器
  ///
  /// Value notifier for thumbnail
  final SafeValueNotifier<MemoryImage?> thumbnailNotifier =
      SafeValueNotifier(null);

  /// 外挂字幕变化通知器
  ///
  /// Value notifier for externalSubtitle
  final SafeValueNotifier<Subtitles?> subtitleNotifier =
      SafeValueNotifier(null);

  /// 外挂字幕trackIndex变化通知器
  ///
  /// The current displayed subtitle status
  final SafeValueNotifier<int?> subtitleTrackIndexNotifier =
      SafeValueNotifier(null);

  /// 当前显示的字幕状态
  ///
  /// The current displayed subtitle status
  final SafeValueNotifier<bool?> isSubtitleVisibleNotifier =
      SafeValueNotifier(false);

  /// 截图状态变化通知器
  ///
  ///
  final SafeValueNotifier<String?> snapFileStateNotifier =
      SafeValueNotifier(null);

  /// 当前下载状态
  ///
  ///
  final SafeValueNotifier<DownloadState> downloadStateNotifier =
      SafeValueNotifier(const UnknownState());

  /// 缩略图是否获取成功
  bool _thumbnailSuccess = false;

  /// 播放数据源
  AliPlayerWidgetData? _widgetData;

  /// 播放器组件控制器构造函数，用于创建 [AliPlayerWidgetController] 实例。
  ///
  /// Constructor to create an instance of [AliPlayerWidgetController].
  ///
  /// 参数：
  /// - [_context]：当前 Widget 的上下文，必须提供，用于初始化控制器并与 UI 层交互。
  ///
  /// Parameters:
  /// - _context: The context of the current widget, required for initializing the controller and interacting with the UI layer.
  AliPlayerWidgetController(this._context) {
    logi("[lifecycle] construct", tag: _logTag);
    _init();
  }

  /// 初始化操作
  void _init() {
    // 初始化全局配置
    AliPlayerWidgetGlobalSetting.setupConfig();

    // 初始化播放器实例
    _initializePlayer();

    _initializeDownloader();

    // 设置默认值
    _batchLoadDefaultValues();
  }

  /// 销毁播放控制器
  ///
  /// Destroy the player controller
  void destroy() {
    // 释放屏幕常亮
    if (_widgetData?.allowedScreenSleep == true) {
      WakelockPlus.disable();
    }

    // 销毁播放器实例
    Future.microtask(() => _destroyPlayer());

    // 销毁下载器实例
    Future.microtask(() => _destroyDownloader());

    // 销毁值监听器
    Future.microtask(() => _disposeValueNotifiers());
  }

  /// 初始化播放器实例
  ///
  /// initialize the player
  void _initializePlayer() {
    logi("Initializing player");

    /// 1、创建播放器
    _aliPlayer = FlutterAliPlayerFactory.createAliPlayer();
    _playerUniqueId = _aliPlayer.playerId;
    _playerLog("[api][lifecycle][create]");

    /// 2、设置播放器事件回调
    // 设置播放器事件回调，准备完成事件
    _aliPlayer.setOnPrepared((String playerId) {
      // 创建外挂字幕（方式1）
      Future.microtask(() => _createExternalSubtitleWhenPrepared());
      _isPrepared = true;

      int cost = DateTime.now().millisecondsSinceEpoch - _prepareStartTime;
      _playerLog("[cbk][onPrepared]: costTime: $cost");

      // 创建清晰度信息
      Future.microtask(() => _createTrackInfoWhenPrepared());

      // 创建缩略图（方式1）
      Future.microtask(() => _createThumbnailWhenPrepared());
    });

    // 设置播放器事件回调，首帧显示事件
    _aliPlayer.setOnRenderingStart((String playerId) async {
      int cost = DateTime.now().millisecondsSinceEpoch - _prepareStartTime;
      _playerLog("[cbk][renderingStart]: costTime: $cost");

      // 更新渲染状态
      isRenderedNotifier.value = true;

      final totalDuration = await _aliPlayer.getDuration();

      if (totalDuration == 0) {
        return;
      }
      totalDurationNotifier.value = Duration(milliseconds: totalDuration);
    });

    // 设置播放器事件回调，播放完成事件
    _aliPlayer.setOnCompletion((String playerId) {
      _isPrepared = false;
      _prepareStartTime = 0;
    });

    // 设置视频大小变化回调
    _aliPlayer.setOnVideoSizeChanged((
      int width,
      int height,
      int? rotation,
      String playerId,
    ) async {
      _playerLog("[cbk][videoSizeChanged]: $width, $height, $rotation");
      // 更新视频尺寸
      _updateVideoSize();
    });

    // 设置视频当前播放位置回调
    _aliPlayer.setOnInfo(
        (int? infoCode, int? extraValue, String? extraMsg, String playerId) {
      if (infoCode == 1) {
        // _playerLog("[cbk][bufferedPosition]: $extraValue, $extraMsg");

        final bufferedPosition = extraValue ?? 0;
        bufferedPositionNotifier.value =
            Duration(milliseconds: bufferedPosition);
      } else if (infoCode == 2) {
        // _playerLog("[cbk][currentPosition]: $extraValue, $extraMsg");

        final currentPosition = extraValue ?? 0;
        currentPositionNotifier.value = Duration(milliseconds: currentPosition);
      }
    });

    // 设置获取 track 信息回调
    _aliPlayer.setOnTrackReady((String playerId) async {
      _playerLog("[cbk][setOnTrackReady]");

      // 更新视频尺寸
      _updateVideoSize();

      // 创建清晰度信息
      Future.microtask(() => _createTrackInfoWhenPrepared());

      // 创建缩略图（方式2）
      Future.microtask(() => _createThumbnailWhenTrackReady());
    });

    // 设置track切换完成回调
    _aliPlayer.setOnTrackChanged((dynamic value, String playerId) {
      final trackInfoList = trackInfoListNotifier.value;
      final selectedTrackInfo = TrackInfoUtil.getTrackInfoByIndex(
        trackInfoList,
        value["trackIndex"],
      );

      // 如果没有找到对应的清晰度信息，则不处理
      if (selectedTrackInfo == null) {
        return;
      }

      // 更新当前清晰度信息
      currentTrackInfoNotifier.value = selectedTrackInfo;

      // 显示提示信息
      String quality = TrackInfoUtil.getQuality(selectedTrackInfo);
      SnackBarUtil.success(_context, "selectTrack: $quality");
    });

    // 设置错误代理回调
    _aliPlayer.setOnError((
      int errorCode,
      String? errorExtra,
      String? errorMsg,
      String playerId,
    ) {
      _playerLog("[cbk][error]: errorCode: $errorCode, errorMsg: $errorMsg");

      playErrorNotifier.value = {errorCode: errorMsg};

      // If occurs error, update video size as default.
      if (videoSizeNotifier.value == Size.zero) {
        final videoSize = ScreenUtil.calculateDefaultDimensions(_context);
        videoSizeNotifier.value = videoSize;
      }
    });

    // 设置播放器状态改变回调
    _aliPlayer.setOnStateChanged((int newState, String playerId) {
      final oldState = playStateNotifier.value;
      _playerLog("[cbk][stateChanged]: state: $oldState->$newState");

      // Update play state
      playStateNotifier.value = newState;
    });

    // 设置缩略图代理回调
    _aliPlayer.setOnThumbnailPreparedListener(
      preparedSuccess: (playerId) {
        _playerLog("[cbk][thumbnailPrepared]: preparedSuccess, $playerId");
        _thumbnailSuccess = true;
      },
      preparedFail: (playerId) {
        _playerLog("[cbk][thumbnailPrepared]: preparedFail, $playerId");
        _thumbnailSuccess = false;
      },
    );

    // 设置缩略图获取代理回调
    _aliPlayer.setOnThumbnailGetListener(
      onThumbnailGetSuccess: (bitmap, range, playerId) {
        var provider = MemoryImage(bitmap);
        thumbnailNotifier.value = provider;
      },
      onThumbnailGetFail: (playerId) {},
    );

    // 设置外挂字幕代理回调
    _aliPlayer.setOnSubtitleExtAdded(
      (trackIndex, String url, playerId) async {
        if (trackIndex < 0) {
          debugPrint('外挂字幕添加失败');
        }
        await _aliPlayer.selectExtSubtitle(trackIndex, true);
      },
    );

    /// 外挂字幕显示回调
    _aliPlayer.setOnSubtitleShow(
      (trackIndex, subtitleID, subtitle, playerId) {
        // 添加字幕到活跃字幕集合中
        _activeSubtitles[subtitleID] = Subtitle(
          index: trackIndex,
          text: subtitle,
        );

        // 更新显示
        _updateSubtitleDisplay(trackIndex);
      },
    );

    /// 外挂字幕隐藏回调
    _aliPlayer.setOnSubtitleHide(
      (trackIndex, subtitleID, playerId) {
        // 从活跃字幕集合中移除
        _activeSubtitles.remove(subtitleID);
        // 更新显示
        _updateSubtitleDisplay(trackIndex);
      },
    );

    /// 截图代理回调
    _aliPlayer.setOnSnapShot((path, playerId) {
      SnackBarUtil.success(_context, "Snapshot taken: $path");
      snapFileStateNotifier.value = path;
    });

    /// 3. 其它配置
    _aliPlayer.setScalingMode(1);

    logi("Player initialization completed.");
  }

  /// 更新字幕显示
  void _updateSubtitleDisplay(int trackIndex) {
    // 获取当前轨道的所有活跃字幕
    List<Subtitle> currentSubtitles = [];

    _activeSubtitles.forEach((subtitleID, subtitle) {
      if (subtitle.index == trackIndex) {
        currentSubtitles.add(subtitle);
      }
    });

    // 创建新的字幕对象
    subtitles = Subtitles(currentSubtitles);

    // 通知UI更新
    subtitleNotifier.value = subtitles;
    subtitleTrackIndexNotifier.value = trackIndex;
    isSubtitleVisibleNotifier.value = currentSubtitles.isNotEmpty;
  }

  /// 销毁播放器实例
  ///
  /// Destroy the player
  void _destroyPlayer() {
    logi("destroy player");

    // 暂停播放
    pause();
    // 停止播放
    stop();

    // 异步释放播放器
    _playerLog("[api][lifecycle][releaseAsync]");
    _aliPlayer.releaseAsync();

    // 重置播放状态
    _isPrepared = false;
    _prepareStartTime = 0;

    // 重置渲染状态
    isRenderedNotifier.value = false;

    logi("Player destroyed.");
  }

  /// 销毁 ValueNotifier
  void _disposeValueNotifiers() {
    isRenderedNotifier.dispose();

    videoSizeNotifier.dispose();

    playStateNotifier.dispose();
    playErrorNotifier.dispose();

    currentPositionNotifier.dispose();
    bufferedPositionNotifier.dispose();
    totalDurationNotifier.dispose();

    brightnessNotifier.dispose();
    volumeNotifier.dispose();
    speedNotifier.dispose();
    isLoopNotifier.dispose();
    isMuteNotifier.dispose();

    mirrorModeNotifier.dispose();
    rotateModeNotifier.dispose();
    scaleModeNotifier.dispose();

    currentTrackInfoNotifier.dispose();
    trackInfoListNotifier.dispose();

    thumbnailNotifier.dispose();
    subtitleNotifier.dispose();
    subtitleTrackIndexNotifier.dispose();

    snapFileStateNotifier.dispose();
  }

  void _initializeDownloader() {
    _aliDownloader = FlutterAliDownloader.init();
  }

  /// 销毁下载器实例
  ///
  /// 释放下载器资源，根据当前视频源类型和选择的清晰度索引释放对应的下载资源。
  /// 该方法会在控制器销毁时被调用，确保下载器资源得到正确释放。
  void _destroyDownloader() {
    int selectVideoIndex = 0;

    if (null != currentTrackInfoNotifier.value) {
      // 获取当前选择清晰度信息
      selectVideoIndex = currentTrackInfoNotifier.value!.trackIndex!;
    }

    if (_widgetData?.videoSource is VidStsVideoSource) {
      final stsSource = _widgetData?.videoSource as VidStsVideoSource;
      String vid = stsSource.vid;
      _aliDownloader.release(vid, selectVideoIndex);
    } else if (_widgetData?.videoSource is VidAuthVideoSource) {
      final authSource = _widgetData?.videoSource as VidAuthVideoSource;
      String vid = authSource.vid;
      _aliDownloader.release(vid, selectVideoIndex);
    }
  }

  /// 设置默认值
  Future<void> _batchLoadDefaultValues() async {
    // 核心任务
    // final coreResults = await Future.wait([]);

    // 非核心任务
    Future(() async {
      // TODO keria: brightness feature to be implemented
      double brightness = SettingConstants.defaultBrightness;
      brightnessNotifier.value = brightness;

      final nonCoreResults = await Future.wait([
        _aliPlayer.getVolume(),
        _aliPlayer.getRate(),
        _aliPlayer.isLoop(),
        _aliPlayer.isMuted(),
        _aliPlayer.getMirrorMode(),
        _aliPlayer.getRotateMode(),
        _aliPlayer.getScalingMode(),
      ]);

      volumeNotifier.value = nonCoreResults[0];
      speedNotifier.value = nonCoreResults[1];
      isLoopNotifier.value = nonCoreResults[2];
      isMuteNotifier.value = nonCoreResults[3];
      mirrorModeNotifier.value = nonCoreResults[4];
      rotateModeNotifier.value = nonCoreResults[5];
      scaleModeNotifier.value = nonCoreResults[6];
    });
  }

  /// 设置播放器视图
  ///
  /// Set the rendering view for the player.
  ///
  /// [playerViewId] The ID of the player view to be set.
  void _setPlayerView(int playerViewId) {
    _playerLog("[api][setPlayerView]: $playerViewId");
    _aliPlayer.setPlayerView(playerViewId);
    // 配置预渲染
    _configureAllowPreRender();
  }

  /// 配置播放控制器
  ///
  /// Configure the player controller with the given data.
  ///
  /// [data] The configuration data for the player, including video URL and other settings.
  void configure(AliPlayerWidgetData data) {
    logi("[api][configure]: $data");

    _widgetData = data;

    // 可选：推荐使用`播放器单点追查`功能，当使用阿里云播放器 SDK 播放视频发生异常时，可借助单点追查功能针对具体某个用户或某次播放会话的异常播放行为进行全链路追踪，以便您能快速诊断问题原因，可有效改善播放体验治理效率。
    // traceId 值由您自行定义，需为您的用户或用户设备的唯一标识符，例如传入您业务的 userid 或者 IMEI、IDFA 等您业务用户的设备 ID。
    // 传入 traceId 后，埋点日志上报功能开启，后续可以使用播放质量监控、单点追查和视频播放统计功能。
    // 文档：https://help.aliyun.com/zh/vod/developer-reference/single-point-tracing
    if (_widgetData?.traceId.isNotEmpty ?? false) {
      _aliPlayer.setTraceID(_widgetData!.traceId);
    }

    // 配置预渲染
    _configureAllowPreRender();

    // 配置播放源
    _configurePlayerSource(data);

    _aliPlayer.setEnableHardwareDecoder(data.isHardWareDecode);

    _aliPlayer.setStartTime(data.startTime, data.seekMode);

    _aliPlayer.setAutoPlay(data.autoPlay);

    // 准备播放
    prepare();

    // 允许屏幕常亮
    if (_widgetData?.allowedScreenSleep == true) {
      WakelockPlus.enable();
    }
  }

  /// 根据视频源配置播放器
  ///
  /// Configure the player based on video source
  void _configurePlayerSource(AliPlayerWidgetData data) {
    if (data.videoSource == null || !data.videoSource!.validate()) {
      throw ArgumentError("Invalid video source");
    }

    final videoSource = data.videoSource;

    // 确保视频源不为空
    if (videoSource == null) {
      return;
    }

    // 根据视频源类型设置播放器
    switch (videoSource.sourceType) {
      case SourceType.url:
        // 对于URL类型，直接使用videoUrl设置
        final urlSource = videoSource as UrlVideoSource;
        _aliPlayer.setUrl(urlSource.url);
        break;

      case SourceType.vidSts:
        // 对于VidSts类型，提取所需参数
        final stsSource = videoSource as VidStsVideoSource;
        _aliPlayer.setVidSts(
          vid: stsSource.vid,
          region: stsSource.region,
          accessKeyId: stsSource.accessKeyId,
          accessKeySecret: stsSource.accessKeySecret,
          securityToken: stsSource.securityToken,
        );
        break;

      case SourceType.vidAuth:
        // 对于VidAuth类型，提取所需参数
        final authSource = videoSource as VidAuthVideoSource;
        _aliPlayer.setVidAuth(
          vid: authSource.vid,
          playAuth: authSource.playAuth,
        );
        break;
    }
  }

  /// 配置预渲染
  ///
  /// Configure pre rendering
  void _configureAllowPreRender() {
    // 列表播放模式下，允许预渲染
    if (isSceneType(_widgetData?.sceneType, [
      SceneType.listPlayer,
    ])) {
      _aliPlayer.setOption(FlutterAvpdef.ALLOW_PRE_RENDER, 1);
    }
  }

  /// 准备播放
  ///
  /// Prepare the player for playback.
  void prepare() {
    _playerLog("[api][prepare]");
    _aliPlayer.prepare();

    // 记录准备开始时间
    _prepareStartTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// 继续播放
  ///
  /// Start or resume playback of the player.
  void play() {
    _playerLog("[api][play]");
    _aliPlayer.play();
  }

  /// 暂停播放
  ///
  /// Pause the player's playback.
  void pause() {
    _playerLog("[api][pause]");
    _aliPlayer.pause();
  }

  /// 停止播放
  ///
  /// Stop the player's playback.
  void stop() {
    _playerLog("[api][stop]");
    _aliPlayer.stop();
  }

  /// 切换播放状态
  ///
  /// Toggle between play and pause states.
  void togglePlayState() {
    final playState = playStateNotifier.value;
    logi("togglePlayState: $playState");

    if (playState == FlutterAvpdef.started) {
      pause();
    } else if (playState == FlutterAvpdef.completion) {
      replay();
    } else if (_isPrepared) {
      play();
    }
  }

  /// 重新播放
  ///
  /// Restart playback from the beginning.
  void replay() async {
    prepare();
    play();
  }

  /// 跳转播放位置
  ///
  /// Seek to a specific position in the video.
  ///
  /// [position] The target playback position.
  void seek(Duration position) {
    currentPositionNotifier.value = position;

    _aliPlayer.seekTo(
      position.inMilliseconds,
      _widgetData?.seekMode ?? FlutterAvpdef.ACCURATE,
    );
  }

  /// 设置播放速度
  ///
  /// Set the playback speed of the player.
  ///
  /// [speed] The target playback speed. Defaults to [SettingConstants.defaultSpeed].
  void setSpeed({double speed = SettingConstants.defaultSpeed}) async {
    // Validate the speed value.
    if (speed <= 0) {
      return;
    }

    await _aliPlayer.setSpeed(speed);

    speedNotifier.value = speed;
  }

  /// 设置亮度
  ///
  /// Set the brightness level of the player.
  ///
  /// [brightness] The target brightness value, clamped between 0 and 1.
  void setBrightness(double brightness) {
    final value = clampDouble(brightness, 0, 1);

    // TODO keria: brightness feature to be implemented
    logi("setBrightness: ${brightnessNotifier.value} -> $value");

    brightnessNotifier.value = value;
  }

  /// 设置亮度（增量）
  ///
  /// Adjust the brightness level by a delta value.
  ///
  /// [delta] The amount by which to adjust the brightness.
  void setBrightnessWithDelta(double delta) {
    final brightness = brightnessNotifier.value;
    final sum = brightness + delta;

    logi("setBrightnessWithDelta: $brightness, $delta, sum: $sum");

    setBrightness(sum);
  }

  /// 设置音量
  ///
  /// Set the volume level of the player.
  ///
  /// [volume] The target volume value, clamped between 0 and 1.
  void setVolume(double volume) async {
    final value = clampDouble(volume, 0, 1);

    await _aliPlayer.setVolume(value);
    double newValue = await _aliPlayer.getVolume();

    logi("setVolume: $volume, real: $newValue");

    volumeNotifier.value = newValue;
  }

  /// 设置音量（增量）
  ///
  /// Adjust the volume level by a delta value.
  ///
  /// [delta] The amount by which to adjust the volume.
  void setVolumeWithDelta(double delta) {
    final oldVolume = volumeNotifier.value;
    final sum = oldVolume + delta;

    logi("setVolumeWithDelta: $oldVolume, $delta, sum: $sum");

    setVolume(sum);
  }

  /// 设置循环播放
  ///
  /// Enable or disable loop playback.
  ///
  /// [loop] Whether to enable loop playback.
  Future<void> setLoop(bool loop) async {
    await _aliPlayer.setLoop(loop);
    bool newValue = await _aliPlayer.isLoop();

    logi("setLoop: $loop, real: $newValue");

    isLoopNotifier.value = newValue;
  }

  /// 设置静音
  ///
  /// Enable or disable mute mode.
  ///
  /// [mute] Whether to enable mute mode.
  Future<void> setMute(bool mute) async {
    await _aliPlayer.setMuted(mute);
    bool newValue = await _aliPlayer.isMuted();

    logi("setMute: $mute, real: $newValue");

    isMuteNotifier.value = newValue;
  }

  /// 设置镜像模式
  ///
  /// Set the mirror mode of the player.
  ///
  /// [mirrorMode] The target mirror mode.
  Future<void> setMirrorMode(int mirrorMode) async {
    await _aliPlayer.setMirrorMode(mirrorMode);
    int newValue = await _aliPlayer.getMirrorMode();

    logi("setMirrorMode: $mirrorMode, real: $newValue");

    mirrorModeNotifier.value = newValue;
  }

  /// 设置旋转角度
  ///
  /// Set the rotation angle of the player.
  ///
  /// [rotateMode] The target rotation angle.
  Future<void> setRotateMode(int rotateMode) async {
    await _aliPlayer.setRotateMode(rotateMode);
    int newValue = await _aliPlayer.getRotateMode();

    logi("setRotateMode: $rotateMode, real: $newValue");

    rotateModeNotifier.value = newValue;
  }

  /// 设置渲染填充模式
  ///
  /// Set the scaling mode of the player.
  ///
  /// [scaleMode] The target scaling mode.
  Future<void> setScaleMode(int scaleMode) async {
    await _aliPlayer.setScalingMode(scaleMode);
    int newValue = await _aliPlayer.getScalingMode();

    logi("setScaleMode: $scaleMode, real: $newValue");

    scaleModeNotifier.value = newValue;
  }

  /// 获取当前播放位置
  ///
  /// Get the current video playback position
  Future<int> getCurrentPosition() async {
    int currentPosition = await _aliPlayer.getCurrentPosition() ?? 0;
    return currentPosition;
  }

  /// 更新视频尺寸
  ///
  /// Update the video size based on the current media information.
  void _updateVideoSize() async {
    // 获取视频尺寸
    final videoWidth = await _aliPlayer.getVideoWidth() as int;
    final videoHeight = await _aliPlayer.getVideoHeight() as int;

    // 如果视频高度没有变化，则不更新视频尺寸
    final oldSize = videoSizeNotifier.value;
    if (videoHeight == oldSize.height && videoWidth == oldSize.width) {
      return;
    }

    // 如果视频尺寸发生变化，则更新视频尺寸
    final newSize = Size(
      videoWidth.toDouble(),
      videoHeight.toDouble(),
    );
    logi("_updateVideoSize: $oldSize -> $newSize");

    videoSizeNotifier.value = newSize;
  }

  /// 获取播放清晰度信息
  ///
  /// Retrieve and update the track information when the player is prepared.
  Future<void> _createTrackInfoWhenPrepared() async {
    // update track info list when player is prepared
    var mediaInfo = await _aliPlayer.getMediaInfo();
    var tracks = mediaInfo["tracks"];

    // 过滤出视频清晰度信息
    final trackInfoList = TrackInfoUtil.filterVideoTrackInfoList(tracks);
    final trackInfo = (trackInfoList.isNotEmpty) ? trackInfoList.first : null;

    // 更新当前清晰度信息
    trackInfoListNotifier.value = trackInfoList;
    currentTrackInfoNotifier.value = trackInfo;
  }

  /// 切换清晰度
  ///
  /// Switch to a specific track for playback.
  ///
  /// [trackInfo] The target track information.
  void selectTrack(AVPTrackInfo? trackInfo) {
    if (trackInfo == null || trackInfo.trackIndex == null) {
      return;
    }

    // 切换清晰度
    _aliPlayer.selectTrack(
      trackInfo.trackIndex!,
      accurate: 1,
    );

    // 显示清晰度信息
    String quality = TrackInfoUtil.getQuality(trackInfo);
    SnackBarUtil.show(_context, "selectTrack: $quality");
  }

  /// 创建缩略图（方式1）
  ///
  /// Create a thumbnail using method 1 (external URL).
  void _createThumbnailWhenPrepared() {
    // 如果外部配置了缩略图地址，则使用方式1创建缩略图
    if (_widgetData == null || _widgetData!.thumbnailUrl.isEmpty) {
      return;
    }

    // 创建缩略图
    _aliPlayer.createThumbnailHelper(_widgetData!.thumbnailUrl);
  }

  /// 创建缩略图（方式2）
  ///
  /// Create a thumbnail using method 2 (media info).
  void _createThumbnailWhenTrackReady() {
    if (_widgetData != null && _widgetData!.thumbnailUrl.isNotEmpty) {
      // 如果外部配置了缩略图地址，则使用方式1创建缩略图
      return;
    }
    _aliPlayer.getMediaInfo().then((value) {
      final thumbnails = value['thumbnails'];
      if (thumbnails?.isNotEmpty ?? false) {
        _aliPlayer.createThumbnailHelper(thumbnails[0]['url']);
      } else {
        _thumbnailSuccess = false;
      }
    });
  }

  /// 外挂字幕 （方式1）
  ///
  /// Create a externalSubtitle using method 1 (external URL).
  Future<void> _createExternalSubtitleWhenPrepared() async {
    // 如果外部配置了外挂字幕地址，则使用方式1创建外挂字幕
    if (_widgetData == null || _widgetData!.externalSubtitleUrl.isEmpty) {
      return;
    }

    // 创建外挂字幕
    await _aliPlayer.addExtSubtitle(_widgetData!.externalSubtitleUrl);
  }

  /// 请求缩略图
  ///
  /// Request a thumbnail bitmap at a specific position.
  ///
  /// [position] The target playback position for the thumbnail.
  void requestThumbnailBitmap(Duration position) {
    if (_thumbnailSuccess) {
      _aliPlayer.requestBitmapAtPosition(position.inMilliseconds);
    }
  }

  /// 设置字幕配置
  ///
  /// Set the subtitle configuration for the player.
  /// [config] The subtitle configuration to be set
  void setSubtitleConfig(SubtitleConfig config) {
    if (_widgetData == null) {
      return;
    }

    _widgetData!.subtitleConfig = config;
  }

  /// 设置字幕构建器
  ///
  /// Set the subtitle builder for custom subtitle rendering.
  /// [builder] The subtitle builder to be set, null to use default builder
  void setSubtitleBuilder(SubtitleBuilder? builder) {
    if (_widgetData == null) {
      return;
    }

    _widgetData!.subtitleBuilder = builder;
  }

  /// 更新字幕样式配置
  ///
  /// Update the subtitle style configuration.
  /// [styleConfig] The subtitle style configuration to be updated
  void updateSubtitleStyle(SubtitleStyleConfig styleConfig) {
    if (_widgetData == null) return;

    final updateSubtitleConfig =
        _widgetData!.subtitleConfig.copyWith(styleConfig: styleConfig);
    _widgetData!.subtitleConfig = updateSubtitleConfig;
  }

  /// 更新字幕位置配置
  ///
  /// Update the subtitle position configuration.
  /// [positionConfig] The subtitle position configuration to be updated
  void updateSubtitlePosition(SubtitlePositionConfig positionConfig) {
    if (_widgetData == null) {
      return;
    }
    _widgetData!.subtitlePositionConfig = positionConfig;
  }

  /// Player log information with a consistent format.
  ///
  /// 使用统一格式记录播放器信息
  void _playerLog(String message, {bool isError = false}) {
    final logMessage = "[$_playerUniqueId][player]$message";
    if (isError) {
      loge(logMessage, tag: _logTag);
    } else {
      logi(logMessage, tag: _logTag);
    }
  }

  /// Takes a snapshot of the current video frame and saves it as a PNG file.
  /// 截取当前视频画面并保存为 PNG 文件。
  ///
  /// - On iOS: saves with filename only (e.g., `1234567890.png`).
  ///   iOS：仅使用文件名（如 `1234567890.png`）。
  /// - On Android: saves to `$_snapShotPath/snapshot_1234567890.png`.
  ///   Android：保存至 `$_snapShotPath/snapshot_1234567890.png`。
  ///
  /// Filename includes a timestamp to ensure uniqueness.
  /// 文件名含时间戳，确保唯一性。
  void snapshot(String path) {
    _aliPlayer.snapshot(path);
  }

  /// 启动视频下载流程
  ///
  /// 根据视频源类型初始化并开始下载视频。支持两种授权类型：
  /// 1. STS授权方式 (VidStsVideoSource)
  /// 2. 授权码方式 (VidAuthVideoSource)
  ///
  /// 下载前会检查视频是否已下载，避免重复下载。
  void startVideoDownload() {
    // 检查视频源是否存在
    if (_widgetData?.videoSource == null) return;

    // 检查下载保存目录是否存在
    if (downloadSavePath == null || downloadSavePath!.isEmpty) {
      SnackBarUtil.error(
        _context,
        "Please set AliPlayerWidgetGlobalSetting.setStoragePaths first.",
      );
      return;
    }

    // 检查是否已经下载完成，如果已完成则提示用户
    if (downloadStateNotifier.value is DownloadCompletedState) {
      final DownloadCompletedState state =
          downloadStateNotifier.value as DownloadCompletedState;
      SnackBarUtil.success(_context,
          "This video has already been downloaded. SavePath: ${state.downloadFile}");
      return;
    } else if (downloadStateNotifier.value is DownloadingState) {
      // 如果处于加载状态，直接return
      return;
    }

    // 设置下载保存目录
    _aliDownloader.setSaveDir(downloadSavePath!);

    String? vid; // 视频ID
    Future<dynamic>? downloadAction;

    // 根据不同视频源类型执行相应下载逻辑
    if (_widgetData?.videoSource is VidStsVideoSource) {
      // 处理 STS 类型视频源的下载准备
      final stsSource = _widgetData?.videoSource as VidStsVideoSource;
      vid = stsSource.vid;
      String accessKeyId = stsSource.accessKeyId;
      String accessKeySecret = stsSource.accessKeySecret;
      String securityToken = stsSource.securityToken;

      downloadAction = _aliDownloader.prepare(
        FlutterAvpdef.DOWNLOADTYPE_STS,
        vid,
        accessKeyId: accessKeyId,
        accessKeySecret: accessKeySecret,
        securityToken: securityToken,
      );
    } else if (_widgetData?.videoSource is VidAuthVideoSource) {
      // 处理 Auth 类型视频源的下载准备
      final authSource = _widgetData?.videoSource as VidAuthVideoSource;
      vid = authSource.vid;
      String playAuth = authSource.playAuth;

      downloadAction = _aliDownloader.prepare(
        FlutterAvpdef.DOWNLOADTYPE_AUTH,
        vid,
        playAuth: playAuth,
      );
    }

    if (vid != null && vid.isNotEmpty) {
      downloadAction?.then((value) {
        _executeDownloadWithMediaInfo(vid!, value);
      }).catchError((error, stack) {
        _handleDownloadError(error);
      });
    } else {
      // UrlVideoSource is not support;
      downloadStateNotifier.value = const DownloadErrorState(
        errorCode: "Video Source Error",
        errorMessage: "Unsupported video source. Only vid source is supported.",
      );
    }
  }

  /// 处理下载错误
  void _handleDownloadError(dynamic error) {
    if (error is PlatformException) {
      // 返回错误
      downloadStateNotifier.value = DownloadErrorState(
        errorCode: error.code,
        errorMessage: error.message!,
      );
    } else {
      downloadStateNotifier.value = DownloadErrorState(
        errorCode: "Download Error",
        errorMessage: error,
      );
    }
  }

  /// 根据媒体信息执行实际的下载操作
  ///
  /// 解析媒体信息并选择合适的视频轨道进行下载，同时监听下载过程中的各种状态变化：
  /// - 下载进度更新
  /// - 下载完成处理
  /// - 下载错误处理
  ///
  /// 该方法会优先使用当前选择的清晰度，如果没有则使用默认的第一个视频轨道进行下载。
  ///
  /// [vid] 视频ID，用于标识要下载的视频资源
  /// [mediaInfoValue] 媒体信息JSON字符串，包含视频轨道等信息
  void _executeDownloadWithMediaInfo(String vid, dynamic mediaInfoValue) {
    // 默认为 0
    int selectVideoIndex = 0;
    if (null != currentTrackInfoNotifier.value) {
      // 获取当前选择清晰度信息
      selectVideoIndex = currentTrackInfoNotifier.value!.trackIndex!;
    } else {
      // 获取OnPrepared清晰度信息
      Map<String, dynamic> jsonMap = json.decode(mediaInfoValue);
      AliMediaInfo info = AliMediaInfo.fromJson(jsonMap);
      if (null != info.trackInfos && info.trackInfos!.isNotEmpty) {
        selectVideoIndex = info.trackInfos![0].index!;
      }
    }
    _aliDownloader.selectItem(vid, selectVideoIndex);

    // 创建监听流控制器
    StreamController<dynamic> controller = StreamController<dynamic>();
    controller.addStream(_aliDownloader.start(vid, selectVideoIndex)!);

    if (!controller.hasListener) {
      _subscription = controller.stream.listen((event) {
        String downloadEvent = event[EventChanneldef.TYPE_KEY];
        if (downloadEvent == DownloadEvent.DOWNLOAD_PROGRESS) {
          // 更新下载进度
          String progress = event[EventChanneldef.DOWNLOAD_PROGRESS];
          downloadStateNotifier.value = DownloadingState(
            progress: int.parse(progress),
          );
        } else if (downloadEvent == DownloadEvent.DOWNLOAD_COMPLETION) {
          // 下载完成处理
          String fileSavePath = event['savePath'];
          downloadStateNotifier.value = DownloadCompletedState(
            downloadFile: fileSavePath,
          );
          // 关闭监听
          _subscription.cancel();
        } else if (downloadEvent == DownloadEvent.DOWNLOAD_ERROR) {
          // 错误处理
          String errorCode = event['errorCode'];
          String errorMsg = event['errorMsg'];
          // 更新状态
          downloadStateNotifier.value = DownloadErrorState(
            errorCode: errorCode,
            errorMessage: errorMsg,
          );
          // 关闭监听
          _subscription.cancel();
        }
      });
    }
  }

  /// 判断视频源是否为 VID
  bool isVideoSourceVid() {
    var videoSource = _widgetData?.videoSource;
    return videoSource is VidStsVideoSource ||
        videoSource is VidAuthVideoSource;
  }

  /// 获取 Flutter Widget 版本号
  ///
  /// Get Flutter Widget version
  ///
  /// Deprecated:
  /// Use [AliPlayerWidgetGlobalSetting.kWidgetVersion] directly instead.
  ///
  /// This method will be removed in a future release.
  @Deprecated('Use AliPlayerWidgetGlobalSetting.kWidgetVersion directly.')
  static String getWidgetVersion() =>
      AliPlayerWidgetGlobalSetting.kWidgetVersion;

  /// 清除 Widget 缓存
  ///
  /// Clear widget cache.
  ///
  /// Deprecated:
  /// Use [AliPlayerWidgetGlobalSetting.clearCaches] instead.
  ///
  /// This method will be removed in a future release.
  @Deprecated('Use AliPlayerWidgetGlobalSetting.clearCaches instead.')
  static Future<void> clearCaches() =>
      AliPlayerWidgetGlobalSetting.clearCaches();

  /// 播放器横竖屏切换
  Future<void> enterFullScreen(
      AliPlayerWidgetController controller, int currentPosition) async {
    final data = controller._widgetData;
    if (data == null) return;
    data.startTime = currentPosition;

    // 进入全屏播放器
    AliPlayerWidgetData result = await Navigator.of(_context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 100), // 动画持续时间
        pageBuilder: (context, animation, secondaryAnimation) {
          return AliPlayerFullScreenWidget(controller, data);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 淡入淡出动画
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
    final int fullScreenPosition = result.startTime;
    await _aliPlayer.seekTo(fullScreenPosition, result.seekMode);
    controller.play();
  }

  /// 播放器退出全屏
  Future<void> exitFullScreen() async {
    // 恢复状态栏和导航栏
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // 正常竖屏
      DeviceOrientation.portraitDown, // 倒置竖屏
    ]);

    final data = _fullController._widgetData;

    if (data == null) return;

    _fullController.getCurrentPosition().then((position) {
      data.startTime = position;
      // 先暂停播放器
      _fullController.stop();

      // 销毁全屏播放器
      _fullController.destroy();

      // 返回竖屏播放器
      Navigator.pop(_context, data);
    });
  }
}
